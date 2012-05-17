function varargout = dispContent(hobj, maxlevel, props)
%dispContent Display content of an object or a struct
%   sigutils.dispContent(H) displays the object to the command line.
%
%   sigutils.dispContent(H, MAXLEVEL) specifies the level of expansion if
%   one of the field (property) of the struct (object) is itself a struct
%   or object. The default value for MAXLEVEL is 1.
%
%   sigutils.dispContent(H, MAXLEVEL, PROPS) display the object's
%   properties in order according to the cell array PROPS.  Any properties
%   not listed in PROPS will not be displayed.  Groups of properties can
%   also be created by passing a nested cell array of strings.
%
%   STR = sigutils.dispContent(H) returns a char array STR instead of
%   displaying directly.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 03:06:09 $

error(nargchk(1,3,nargin,'struct'));

if nargin < 3 || isempty(props)
    props = fieldnames(hobj);
end

if ~iscell(props)
    error(generatemsgid('InvalidParam'),'PROPS must be a cell array.');
end
    
if nargin < 2
    maxlevel = 1;
end
validateattributes(maxlevel,{'numeric'},{'integer','positive','scalar'},...
    'sigutils.dispContent','maxLevel');


% define a string buffer
rpbuffer = StringBuffer;
% addcr(rpbuffer);

% default padding at front.
defaultpadding = 4;

% the spacing before first appeared character.
frontspacing = repmat(' ',1,defaultpadding);

% define delimiter, user can choose their sign such as '->' if
% they want
colonstring = ': ';
% print string
startDisp = '';

if strcmpi(get(0,'formatspacing'), 'loose')
    looseFormat = true;
else
    looseFormat = false;
end

if ~isempty(startDisp)
    addcr(rpbuffer,'%s%s',frontspacing,startDisp);
    if looseFormat
        addcr(rpbuffer);
    end
end

% define level, at beginning, it's level 1
lvl = 1;

% call updatereport to finish report, pass in the front spacing
% for the next level as the default plus the max length of
% properties plus the length of delimiter
updatereport(hobj,props,rpbuffer,colonstring,...
    defaultpadding+length(startDisp),lvl, maxlevel,looseFormat);

displaystring1 = char(rpbuffer);
crs = [0 regexp(displaystring1, char(10))]; %find the carriage returns
displaystring = '';
for ii=1:length(crs)-1
  displaystring = strvcat(displaystring, displaystring1(crs(ii)+1:crs(ii+1)-1)); %#ok<VCAT>
end

displaystring = strvcat(displaystring, ' '); %#ok<VCAT>
if nargout
    varargout{1} = displaystring;
else
    disp(displaystring);
end

end

function updatereport(sys,props,strbuf,delimiter,frontspacenum,lvl,maxlvl,looseFormat)

    props = sortpropsfordisp(props);
    % obtain max space in the properties
    maxspace = getspacing(props);
    % define the max levels where one wants to see an empty line separate
    % the content blocks.
    emptylinelevelmax = 0;
    % go through the properties and print to string buffer
    for m = 1:length(props)
        tempprop = props(m);
        tempval = sys.(tempprop{1});
        % the front spacing before first character
        frontspacing = repmat(' ',1,frontspacenum);
        % padding to ensure alignment of delimiters, all strings at this
        % level are left aligned and delimiters are also aligned
        padding = repmat(' ',1,maxspace-length(tempprop{1}));

        if ischar(tempval)
        
            if length(tempval) > maxwidth(length(frontspacing)+maxspace)
                tempvaldisp = shortdescription(tempval);
            else
                tempvaldisp = sprintf('''%s''',tempval);
            end           
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        elseif isa(tempval, 'embedded.fi')
            % Convert all other values to a matrix.
            tempvaldisp = shortdescription(tempval);
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);

        elseif isa(tempval, 'embedded.numerictype')
            tempvaldisp = tempval.tostring;
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);
        
        elseif isa(tempval, 'strel')
            tempvaldisp = '[1x1 strel]';
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);
        
        elseif isa(tempval, 'function_handle')
            tempvaldisp = func2str(tempval);
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);
        
        elseif isstruct(tempval) || isa(tempval,'handle')
            if lvl < maxlvl
                % if the property is a handle and max level is not reached, go
                % through another level, but first print the property name and
                % its type, the next level left align with the values of
                % properties at this level
                tempvaldisp = '';
            else
                % display the default MATLAB display
                tempvaldisp = shortdescription(tempval);
            end
            
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);
            
            if lvl < maxlvl
                updatereport(tempval,fieldnames(tempval),strbuf,delimiter,...
                    frontspacenum+maxspace+length(delimiter),lvl+1,maxlvl,looseFormat);
            end
            
            if lvl <= emptylinelevelmax
                % if the level is below the max level that needs separator,
                % print the separater
                addcr(strbuf);
            end
            
        elseif iscellstr(tempval)
            % Special case the cellstr code.  This code will not work and
            % will not be hit by nested cells of cellstrs, e.g. it will not
            % work for {{'a','b'}, {'c', 'd'}}, but it will work for
            % {'a', 'b'; 'c', 'd'}.
            [cellstrrows,cellstrcols] = size(tempval);
            tempvaldisp = sprintf('%s','{');
            
            if (cellstrrows == 0) || (cellstrcols == 0)
                tempvaldisp = sprintf('%s}',tempvaldisp);           

            elseif cellstrrows == 1
                
                for cidx = 1:cellstrcols
                    tempvaldisp = sprintf('%s''%s'' ', tempvaldisp, tempval{cidx});
                end
                tempvaldisp(end) = '}'; % replace last space
            
            elseif cellstrcols == 1
 
                for ridx = 1:cellstrrows
                    tempvaldisp = sprintf('%s''%s'';', tempvaldisp, tempval{ridx});
                end
                tempvaldisp(end) = '}'; % replace last ;
            
            else
                
                for ridx = 1:cellstrrows
                    for cidx = 1:cellstrcols
                        tempvaldisp = sprintf('%s''%s'' ', tempvaldisp, tempval{ridx, cidx});
                    end
                    tempvaldisp(end) = ';';
                end
                tempvaldisp(end) = '}';
            end
            
            if length(tempvaldisp) > maxwidth(length(frontspacing)+maxspace)
                tempvaldisp = shortdescription(tempval);
            end
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);
        
        else
            % otherwise, the property is a number and we print the value
            % after the property
            if iscell(tempval) || isempty(tempval) || (ndims(tempval) > 2)
                tempvaldisp = shortdescription(tempval);
            elseif 2*numel(tempval)+1 > maxwidth(length(frontspacing)+maxspace)
                % mat2str for a very large number is very expensive so we
                % first figure out whether it is making sense to convert.
                % mat2str converts the number and spacing in between, plus
                % the square bracket at both ends. Therefore, total number
                % of char will be 2*numel(tempval)+1
                tempvaldisp = shortdescription(tempval);
            else
                tempvaldisp = mat2str(tempval);
            end
            
            if length(tempvaldisp) > maxwidth(length(frontspacing)+maxspace)
                tempvaldisp = shortdescription(tempval);
            end
            writestr(strbuf,frontspacing,tempprop{1},padding,delimiter,tempvaldisp);
        end
        
        if looseFormat
            % Like the compact form so don't do anything even if format is
            % loose
            % addcr(strbuf);
        end
    end
end

% -------------------------------------------------------------------------
function valuestr = shortdescription(value)

    sz = size(value);

    if sum(sz) == 0
        valuestr = '[]';
        return;
    end

    if iscell(value)
        valuestr = '{';
    else
        valuestr = '[';
    end
    
    for kndx = 1:length(sz)-1
        valuestr = sprintf('%s%dx', valuestr, sz(kndx));
    end
    valuestr = sprintf('%s%d %s', valuestr, sz(end), class(value));

    if iscell(value)
        valuestr = sprintf('%s}', valuestr);
    else
        valuestr = sprintf('%s]', valuestr);
    end

end

function spacing = getspacing(props)
    % convert to cell
    if ~iscell(props{1})
        props = {props};
    end
    % loop through to get max length of properties
    spacing = 0;

    for indx = 1:length(props)
        for jndx = 1:length(props{indx})
            spacing = max(length(props{indx}{jndx}), spacing);
        end
    end

end
      
function maxw = maxwidth(padding)
    cmdwinsize = get(0,'CommandWindowSize');
    maxw = max(60,cmdwinsize(1)-padding-2);
end

function writestr(strbuf,frontspacing,prop,padding,delimiter,propvalstr)
    addcr(strbuf,'%s%s%s%s%s',frontspacing,padding,prop,...
        delimiter,propvalstr);
end

function sortedprops = sortpropsfordisp(props)

    descriptionProps = {'Description'};
    descriptionPresent = ismember(descriptionProps,props);
    [~, sortedpropsidx] = setdiff(props,descriptionProps);
    otherprops = props(sort(sortedpropsidx));
    sortedprops = [descriptionProps{descriptionPresent};otherprops(:)];
end

% [EOF]
