function [newline1,newline2] = linediff(line1,line2,padlength,ignore_whitespace)
% LINEDIFF - Highlights differences within a line of text
%
%   [newline1, newline2] = LINEDIFF(line1,line2,padlength,ignore_whitespace)
%
% The returned strings are HTML fragments in which any non-matching
% portions of the string are wrapped in "span" tags.  These tags use
% styles defined in matlab-report-styles.css in this directory.

% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

if nargin<4
    ignore_whitespace = false;
    if nargin<3
        padlength = inf;
    end
end
tok1 = tokenize(line1,ignore_whitespace);
tok2 = tokenize(line2,ignore_whitespace);
[align1,align2] = diffcode(tok1(:,2),tok2(:,2));
[differ1,differ2] = compareTokens(align1,align2,tok1,tok2);
if ignore_whitespace
    % Find tokens which are whitespace only.  These have a specific hash
    % value (because they were collapsed to a single space).
    is_whitespace_1 = find(tok1(:,2)==hash(' '));
    is_whitespace_2 = find(tok2(:,2)==hash(' '));
    % Remove these tokens from the list of those to be highlighted.
    differ1 = differ1(~ismember(differ1,is_whitespace_1));
    differ2 = differ2(~ismember(differ2,is_whitespace_2));
end
newline1 = formatLine(line1,differ1,tok1(:,1),padlength);
newline2 = formatLine(line2,differ2,tok2(:,1),padlength);

end

% Highlight the parts of the line that have modified characters.
% % "l1" contains the characters in the line.
% "toks" gives the indices in the line of the first character in each
% token.
% % "colorize" contains the indices of the tokens that contain modified
% characters and are to be highlighted.
function newl = formatLine(l1,colorize,toks,padlength)
    charcount = 0;
    outc = cell(numel(toks),1);
    for k=1:numel(toks)
        if k==numel(toks)
            tok_end = numel(l1);
        else
            tok_end = toks(k+1)-1;
        end
        tt = replacetabs(l1(toks(k):tok_end),charcount);
        charcount = charcount + numel(tt);
        if charcount>padlength
            chop = charcount - padlength;
            tt(end-chop+1:end) = [];
        end
        tt = code2html(tt);
        if ismember(k,colorize)
            prepend = '';
            if ~ismember(k-1,colorize)
                % Beginning of a modified section.
                prepend = '<span class="diffchars">';
            end
            append = '';
            if ~ismember(k+1,colorize) || charcount>padlength
                % End of a modified section, or no more space
                append = '</span>';
            end
            outc{k} = sprintf('%s%s%s',prepend,tt,append);
        else
            outc{k} = tt;
        end
        if charcount>=padlength
            break;
        end
    end
    newl = [ outc{:} ];
    if charcount<padlength && isfinite(padlength)
        extra = padlength - charcount;
        newl = [ newl repmat(' ',1,extra) ];
    end
end


% align1 and align2 are arrays of the same length.  In each row, the
% elements of these arrays contain respectively the index of the token in
% line1 and the index of the token in line2 that are "aligned".  They
% may or may not actually be the same.  Where an element is zero, the token
% in the other array is "unmatched".
function [differ1,differ2] = compareTokens(align1,align2,tok1,tok2)
    % Identify tokens in each line that don't match anything in the other.
    removed1 = align2==0;
    removed2 = align1==0;
    % Compare the tokens that were aligned by the "diffcode" algorithm to
    % see if they're the same or not.
    possible_differ = ~removed1 & ~removed2;
    atok1 = align1;
    atok1(possible_differ) = tok1(align1(possible_differ),2);
    atok1(~possible_differ) = 0;
    atok2 = align2;
    atok2(possible_differ) = tok2(align2(possible_differ),2);
    atok2(~possible_differ) = 0;
    act_differ = atok1 ~= atok2; % indices in align1 and align2 where tokens are different.
    % Now we can find the indices of tokens in each line that are different
    % from the corresponding token (if any) on the other side.
    differ1 = align1(removed1 | act_differ);
    differ2 = align2(removed2 | act_differ);
    
end


% Hash a string into a double
function h = hash(s)
h = 0;
for k=1:length(s)
    sk = s(k);
    c = -1.85-1/sk;
    h = h*h+c;
end
end

% Returns an n*2 matrix in which the columns contain:
%  the start index of each "token"
%  the hash value for the token
% A token is an identifier, a sequence of digits,
% a sequence of whitespace or a symbol. All symbols are unique tokens.
% By using tokens the visual clutter is reduced. Most tokens are short
% anyway and the eye scans words better if the color doesn't change within
% them.
function t = tokenize(s,ignore_whitespace)
    persistent tok_class;
    if isempty(tok_class)
        tok_class = zeros(1,127);
        tok_class(double('A':'Z')) = 1;
        tok_class(double('a':'z')) = 1;
        tok_class(double('0':'9')) = 1;
        tok_class('_') = 1;
        tok_class(' ') = 2;
        tok_class(9) = 2;
    end
    if isempty(s)
        % Handling an empty string gets complicated later on, so we just
        % use a special case here.
        t = zeros(0,2);
        return;
    end
    s(s>127) = 'a'; % assume all non-ascii unicode points are letters
    cls = tok_class(s);
    % make sure runs of a given symbol does not count as a token
    symbols = find(cls==0);
    cls(symbols) = 100+(1:length(symbols));
    % we have now classified each character so form tokens from
    % runs of classes.
    [~,pos] = find(diff(cls));
    pos = [1 pos+1 length(s)+1];
    t = zeros(length(pos)-1,2);
    for k=1:length(pos)-1
        word = s(pos(k):(pos(k+1)-1));
        if ignore_whitespace
            % collapse spaces down into a single space
            if cls(pos(k))==2
                word = ' ';
            end
        end
        t(k,:) = [pos(k) hash(word)];
    end
end

