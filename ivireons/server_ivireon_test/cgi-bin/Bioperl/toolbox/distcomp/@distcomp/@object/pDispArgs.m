function pDispArgs(obj, itemFormatString, displayItem) %#ok<INUSL>
% HELPER FUNCTION FOR DISPATCHING any structure or pair of cell arrays for
% formated printout. Must have at least two arguments in addition to
% the calling object.

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.7 $  $Date: 2010/05/10 17:03:24 $

% FORMAT PAIRS OF PROPERTY VALUE CELL STRINGS
listofvalues = displayItem.Values;
listofproperties = displayItem.Names;
% prints from cell array of strings containing property name and values
iPrintAndFormat(itemFormatString, listofproperties, listofvalues);
end

%--------------------------------------------------------------------------
% INTERNAL  FUNCTION DECLARATION
% prints Names and values based on the format provided in first argument
%--------------------------------------------------------------------------
function iPrintAndFormat(itemFormatString, propNames, propVals)

if isempty(propNames) && isempty(propVals)
    % if both lists are empty simply dont do display
    return
end

if numel(propNames) ~= numel(propVals)
    error('distcomp:object:InvalidArgument', ...
        ['Unexpected internal error - number of properties should be the same as the\n' ...
        'number of values. numel(props) = %d, numel(values) = %d'] , numel(propNames), numel(propValues) );
end

numNames = numel(propNames);

% each item is displayed using the itemsDisplayFormat
for ii = 1:numNames
    thisName  = propNames{ii};
    % iRetCharForDisp : gets the obj properties value as a char for display
    % also does some truncation if necessary
    thisValue = iRetCharForDisp(itemFormatString, propVals{ii});
    fprintf(itemFormatString, thisName, thisValue);
end

end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------

function valueStr = iRetCharForDisp( itemFormatString, value )
% pRetCharForDisp - a simple display for a variety of object types
% Based on edrics original pSimpleDisp, with changes to numel instead of
% length.
if isempty(value)
    if iscell(value)
        valueStr = '{}';
    elseif ischar(value)
        valueStr = '';
    else
        valueStr = '[]';
    end
    return
end
% Deal with all numeric type in one way before switching on other types
if isnumeric( value )
    valueStr = iNumericDisp( value );
    return
end
switch class( value )
    case 'char'
        valueStr = iCharDisp( value );
    case 'cell'
        valueStr = iCellDisp( itemFormatString, value );
    case 'function_handle'
        valueStr = iFnHandleDisp( value );
        %   Not entirely sure why we have a distcomp.worker here - think it
        %   is possible that no one uses it. This is likely to be removed in
        %   future releases
        %   case 'distcomp.worker'
        %       valueStr = iWorkerDisp( value );
    case 'logical'
        valueStr = iLogicalDisp( value );
    otherwise
        valueStr = iGenericDisp( value );
end
end % end of function


%--------------------------------------------------------------------------
% iCharDisp - displays text truncates beginning
%--------------------------------------------------------------------------
function str = iCharDispBeg( value )
% STR_LEN_THRESH defines the cut off  threshold for truncating string values of properties
STR_LEN_THRESH = iGetTruncationLength();
truncated = false;
% split at STR_LEN_THRESH chars, or line-break
linebrk = strfind( value, sprintf( '\n' ) );

if ~isempty( linebrk )
    value = value(1:linebrk-1);
    truncated = true;
end

if numel( value ) > STR_LEN_THRESH
    value = value(end-(STR_LEN_THRESH-1):end);
    truncated = true;
end
str = value;
if truncated
    truncChar = '...';
    N = numel(truncChar);
    str(1:N) = truncChar(1:N);
end
end

%--------------------------------------------------------------------------
% iCharDisp - displays text abd truncated end
%--------------------------------------------------------------------------
function str = iCharDisp( value )
% STR_LEN_THRESH defines the cut off  threshold for truncating string values of properties
STR_LEN_THRESH = iGetTruncationLength();
truncated = false;
% split at STR_LEN_THRESH chars, or line-break
linebrk = strfind( value, sprintf( '\n' ) );

if ~isempty( linebrk )
    value = value(1:linebrk-1);
    truncated = true;
end

if length( value ) > STR_LEN_THRESH
    value = value(1:STR_LEN_THRESH);
    truncated = true;
end
str = value;
if truncated
    truncChar = '...';
    N = numel(truncChar);
    str(end-(N-1):end) = truncChar(1:N);
end
end

%--------------------------------------------------------------------------
% iGenericDisp - generic display for something we don't know how to handle
%--------------------------------------------------------------------------
function str = iGenericDisp( value )
szStr = iGetDimensionStringOfIntArray( size( value ) );
str = sprintf( '[%s %s]', szStr, class( value ) );
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function str = iLogicalDisp( value )

if value
    str = 'true';
else
    str = 'false';
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iWorkerDisp
% function str = iWorkerDisp( work )
% str = sprintf( '%s on %s', work.Name, work.Hostname );
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% iFnHandleDisp - display function handle
%--------------------------------------------------------------------------
function str = iFnHandleDisp( fnh )
str = func2str( fnh );
% Add a @ if the function name isn't an anonymous function which
% already has the @ inserted by func2str
if ~isempty(str) && str(1) ~= '@'
    str = [ '@' str ]; 
end


end

%--------------------------------------------------------------------------
% iNumericDisp
%--------------------------------------------------------------------------
function str = iNumericDisp( num )
[~, doShort] = iGetDimensionStringOfIntArray( size( num ) );
if doShort
    str = iGenericDisp( num );
else
    str = num2str( num );
    if numel( num ) == 1
        % No need to put brackets around a single number
    else
        str = ['[', str, ']'];
    end
end
end

%--------------------------------------------------------------------------
% iGetDimensionStringOfIntArray - turn a size array into 4x5x7
%--------------------------------------------------------------------------
function [str, doShort] = iGetDimensionStringOfIntArray( sz, thresh )

if nargin == 1
    thresh = 6;
end

if numel( sz ) == 2 && sz(1) == 1 && sz(2) <= thresh
    doShort = false;
    str = sprintf( '%dx%d', sz(1), sz(2) );
else
    doShort = true;
    switch length(sz)
        case {2 3 4}
            % Use vectorised sprintf and strip the last char 'x'
            str = sprintf('%dx', sz);
            str = str(1:end-1);
        otherwise
            str = [num2str(length(sz)), '-D'];
    end
end

end

%--------------------------------------------------------------------------
% iCellDispEl - even shorter display!
%--------------------------------------------------------------------------
function str = iCellDispEl( el )
handled = false;
% When the element of cell is a character then truncate if necessary
if ischar(el)
    % MAGIC NUMBER
    if numel( el ) <= 10
        str = sprintf( '''%s''', el );
        handled = true;
    end
elseif isnumeric(el)
    sz = size( el );
    [~, doShort] = iGetDimensionStringOfIntArray( sz, 3 );
    if ~doShort
        str = sprintf( '[%s]', num2str( el ) );
        handled = true;
    end
end
if ~handled
    str = iGenericDisp( el );
end

end

%--------------------------------------------------------------------------
% iCellDisp - display a cell array in a reasonable manner
%--------------------------------------------------------------------------
function str = iCellDisp( itemFormatString, cellarr )
sz = size( cellarr );
numel_cellarr = numel( cellarr );
%itemFormatString = '%26s : %s\n';
% special case for only strings which also truncates if cell array is
% greater than 20
if isvector(cellarr) && all( cellfun( @ischar, cellarr ))
    postfix = '';
    %  what if this is really long? Perhaps we might want to truncate
    if numel_cellarr > 20  % truncation condition
        numel_cellarr = 20;
        % puts the line output in the correct format
        postfix = '...';
    end
    strs = cell(numel(cellarr), 1);
    itemF = '%s';
    for ii = 1:numel_cellarr % flattens cell array
        strs{ii} = sprintf(itemF, '', iCharDispBeg(cellarr{ii})); % truncates string in each cell if necessary
        %ignore the \n on the formatstring
        itemF = itemFormatString(1:end-2);
    end
    %str = str(1:end-1);
    str = [ sprintf('%s\n', strs{:}), postfix ];
    % remove additional line break at the end of the cell array
    str = str(1:end-1); 
else
    [szStr, doShort] = iGetDimensionStringOfIntArray( sz );

    if doShort
        str = sprintf( '{%s cell}', szStr );
    else
        % preallocate a certain size cell array to hold the output
        strs = cell(numel(cellarr), 1);
        for ii = 1:numel_cellarr %flattens cell array
            strs{ii} = iCellDispEl(cellarr{ii});
        end
        % Note space before sprintf but not after as there is a trailing
        % space from the vectorized sprintf
        str = ['{ ' sprintf('%s ', strs{:}) '}'];
    end
end
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function STR_LEN_THRESH = iGetTruncationLength()
% STR_LEN_THRESH defines the cut off  threshold for truncating string values of properties
% call c mex function to get command window size
STR_LEN_THRESH = 47;
headerSize = 31; %
try
    cmdWSize = distcomp.dctCmdWindowSize();
    % make sure cmdWSize is something sensible
    if cmdWSize > (STR_LEN_THRESH + headerSize) && cmdWSize < 5000
        STR_LEN_THRESH = cmdWSize - headerSize;
    end
catch err %#ok<NASGU>
end
end
