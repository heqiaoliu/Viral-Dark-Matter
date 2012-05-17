function y = screenMsg(this, arg)
%SCREENMSG Display a text message centered in the scope window
%  screenMsg('text') turns on and display 'text' in the
%     center of the MPlay window
%  screenMsg(false) and ScreenMsg(true) turn off and on the
%     current screen message.
%  y = this.screenMsg returns true if screen message is on

%   Copyright 2007-2010 The MathWorks, Inc.
%   2007/07/24 20:50:11 $

htxt = this.MessageText;

if nargin>1
    % Change screen message state
    
    hdis = getDisplayHandles(this);
    if ~ishghandle(hdis)
        hdis = [];
    end
    
    if ischar(arg) || iscell(arg)
        
        % If the text object has not be rendered, just cache the screen
        % message that we received and we'll show it later.
        if ~ishghandle(htxt)
            this.ScreenMessageCache = arg;
            return;
        end
        % Message passed - turn on message and update text
        
        % Turn off display when message is displayed
        set(hdis, 'vis','off');

        % Display message, reformat appropriately Retain original text in
        % userdata.  This is needed in case we must reformat during resize
        % events, and if we've added hyphens, we need a clean original copy
        % to work from.
        txt = ReformatText(arg,MaxTextWidth(this));
        set(htxt, ...
            'vis', 'on', ...
            'string', txt, ...
            'userdata', arg);
        
    elseif islogical(arg)
        
        % If the text has not been rendered, clear any cache we have.
        if ~ishghandle(htxt)
            if ~arg
                this.ScreenMessageCache = '';
            end
            return;
        end
        
        % Input should be true, false, 0, or 1
        %
        % Turn off video when message is displayed, and vice-versa:
        if arg, sw_txt='on';  sw_vid='off';
        else    sw_txt='off'; sw_vid='on';
        end
        set(htxt, 'vis', sw_txt);
        set(hdis, 'vis', sw_vid);
        
        % If we're turning on the message, recompute text display width
        % (especially useful when we're being called during a resize event)
        if arg
            % Recompute line wrap on original cached message
            txt = get(this.MessageText,'userdata');
            txt = ReformatText(txt,MaxTextWidth(this));
            set(htxt,'string',txt);
        end
    end
else
    
    if ~ishghandle(htxt)
        y = ~isempty(this.ScreenMessageCache);
    else
    
        % Return state
        %
        % If screen text message is visible, return true
        y = strcmpi( get(htxt, 'vis'), 'on' );
    end
end

% ----------------------------------------
function strs = ReformatText(strs,maxchars)
%ReformatText Re-formats text line breaks for nicer looking display

% STR may be a simple string, or a cell-array of strings. Convert both to a
% cell string.
if ~iscell(strs),
    % change from [] to '' to strtrim won't break
    if isempty(strs), strs=''; end
    strs={strs};
end

% Deblank both ends of all strings
for i=1:numel(strs)
    strs{i} = strtrim(strs{i});
end

% If two adjacent entries in cell-array are non-empty, combine into one
% longer string using a space.  That is, remove caller-specified line feeds
% between adjacent lines, since we will re-determine this for the string.
%
% But, leave empty lines as they signify extra space which we will not
% reformat for deduce on our own.
i=1;
while (i < numel(strs))
    if ~isempty(strs{i}) && ~isempty(strs{i+1})
        % two adjacent non-empty lines
        strs(i) = {[strs{i} ' ' strs{i+1}]};
        strs(i+1) = [];
    else
        i=i+1;
    end
end

% "Wrap" each line of text by breaking it into separate cells
%
tmp={};
for i=1:numel(strs)
    % split string into multiple lines
    tmp = [ tmp ; SplitStr(strs{i},maxchars) ]; %#ok
end
strs = tmp;

% --------------------------------
function t = SplitStr(s,maxchars)
% S is a de-blanked string (not a cell) T is a vertical cell string (even if
% just one string)
if isempty(s)
    t={s};
else
    t={};
    while isLongString(s, maxchars)
        % string too long - split it: grab 1 extra char beyond maxchars,
        % and see if it's a space. If it is, keep the 1st maxchars
        % characters. If the ascii values are <=127, this means the string
        % has English characters. In this case use spaces to split the
        % string. If the values > 127, then the string contains characters
        % other than English, use 'aphanum' to find delimiters in order to
        % split.
        [substr,~] = getSubString(s, maxchars);
        if isempty(find((double(substr)>255),1))
            % Use regexp instead of find so that we find spaces & newlines
            % in the sub string.
           ispace = regexp(substr,'\s'); 
        else
            ispace = find(~isstrprop(substr,'alphanum'));
        end
        if isempty(ispace)
            % no space break one char before and add a hyphen
            [substr, indx] = getSubString(s,maxchars-1);
            % Don't add the hyphen for non-ascii characters (Japanese,
            % Korean, Chinese etc). The recommendation from the i18n team is
            % to just split the non-ascii characters without the hyphen. The
            % hyphen apparently can change the meaning of the word.
            if any(double(substr) > 255)
                t =  [t;{substr}]; %#ok<AGROW>
            else
                t = [t;{[substr '-']}]; %#ok
            end
            s = s(indx+1:end);
        else
            % space found - possibly more than one break at farthest space
            % <= maxchars. If the characters are non-english, don't remove
            % the non-alphanumeric characters. These can be spaces, commas,
            % +-*/ operators in Japanese.
            if any(double(substr) > 255)
                t = [t;{s(1:ispace(end))}]; %#ok
            else
                t = [t;{s(1:ispace(end)-1)}]; %#ok
            end
            s = strtrim(s(ispace(end)+1:end));
        end
    end
    if ~isempty(s)
        t=[t;{s}];  % append remaining text
    end
end

% ------------------------------------------
function w = MaxTextWidth(this)
% Get width of the axis, in units of characters Be sure axis font is set
% identically to text font

htxt = this.MessageText;

% Get extent of the figure
hfig = ancestor(htxt, 'figure');
set(hfig,'units','pix');
pos = get(hfig,'pos');

% Compute width of an "m", then use that to gauge max # chars given the
% width of the display.  For some reason, the width of an "m" is returned
% as 2 pixels wider than it is.  Doing a sequence of m's (differential
% measurement) proves this to be the case.  Also, leave 10% gutter (5% on
% each size, minimum)
set(htxt,'units','pix','string','m');
ext=get(htxt,'extent');
set(htxt,'units','norm'); % needed for centering of text to .5,.5

% Don't allow width below a minimum ... it must be > 0 as it's used as an
% index.  Besides, do we really want to read single-column (vertical) text?
% The value 8 is somewhat arbitrary:

w = max(8, floor(0.9 * pos(3) ./ (ext(3)-2)));

%--------------------------------------------------
function [str, index] = getSubString(s, maxchars)
% Get the substring that is of length maxchars from original string keeping
% in mind that the string might have non English characters. Also, return
% the index in the original string at which the length is just under
% maxchars.

index = maxchars;
count = ones(1,length(s));
% Find the indices of non English characters.
% Assume than all non English characters are 2 characters wide each.
count(double(s)>255) = 2;
c_sum = cumsum(count);
% Find the index of the sum of chars that is less than maxchars.
idx = find(c_sum <= maxchars);

% we might have a mixture of English and non English characters at this
% point. Check to see if the English characters that are part of the first
% maxchars have spaces. If they don't, then they are probably part of a
% bigger word - in this case, we don't want to split this. Don't return it
% as part of the substring of maxchars.

% Add 1 more character to the end to make sure it isn't a space. This will
% tell us if the English characters are part of a bigger word and is being
% split up incorrectly. 
% Also, check if all the characters from 1:maxchars are English characters.
if ~(idx(end)+1 > length(s))
    en_char_idx = find(double(s(1:idx(end)+1)) < 256);
else
    en_char_idx = find(double(s(1:idx(end))) < 256);
end
if ~isempty(en_char_idx) 
    % The en_char_idx vector might be one element longer than the idx
    % vector since we are going 1 character beyond maxchar. If the
    % character beyond maxchar is non English, then en_char_idx will be of
    % the same or lesser length as idx. If all characters are English, then
    % the difference between the two vectors will be at the most 1. Factor
    % this in while comparing the two vectors for equality.
    diffInLength = abs(length(en_char_idx)-length(idx));
    % difference in length has to be 0 or 1 for all characters to be
    % English.
    if diffInLength > 1
        areAllCharEnglish = false;
    else
        % compare the vectors correctly factoring in the difference in
        % length
        areAllCharEnglish = isequal(idx,en_char_idx(1:end-diffInLength));
    end
    % If the substring of length 1:maxchars contains English characters but
    % does not contain purely English characters, recompute the length of
    % the substring to be returned. For example, the string 'mqe_mplaytut/'
    % will be returned as-is since it contains purely English characters.
    % No further manipulations are necessary in this case.
    if ~areAllCharEnglish
        % If the English string is not at the end of the substring, then we
        % don't have to worry about it being split incorrectly. Check if
        % the cumulative sum of the characters just beyond the English
        % characters is less than maxchars. If it isn't, then the English
        % string is at the end and we have to recompute the substring index
        % that is below maxchars.
        if ~(c_sum(en_char_idx(end)) <= maxchars)
            space = find(s(en_char_idx)==' ');
            % if there are no spaces, don't return the English substring as part of the
            % first maxchars
            if isempty(space);
                idx = idx(1:en_char_idx(1)-1);
            else
                idx = idx(1:en_char_idx(space(end))-1);
            end
        end
    end
end
if ~isempty(idx);index = idx(end);end
% Return the substring of length just below maxchars.
str = s(1:idx(end));

%---------------------------------------------------
function isStringLongerThanMaxChars = isLongString(s, maxchars)
% Returns true if the string is longer than the maximum number of
% characters maxchars. This takes into account character sets other than
% English.
isStringLongerThanMaxChars = false;
count = ones(1,numel(s));
% Find the indices of non English characters.
% Assume than all non English characters are 2 characters wide each.
count(double(s) > 255) = 2;
% Check if the sum of the counts is greater than maxchars.
if sum(count) > maxchars
    isStringLongerThanMaxChars = true;
end

%--------------------------------------------------
% [EOF]
