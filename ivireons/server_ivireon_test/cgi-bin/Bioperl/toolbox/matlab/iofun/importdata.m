function [out, delimiter, headerlines] = importdata(varargin)
%IMPORTDATA Load data from file.
%
%   IMPORTDATA(FILENAME) loads data from FILENAME into the workspace.
%
%   A = IMPORTDATA(FILENAME) loads data into A.
%
%   IMPORTDATA(FILENAME, DELIM) interprets DELIM as the column separator in
%   ASCII file FILENAME. DELIM must be a string. Use '\t' for tab.
%
%   IMPORTDATA(FILENAME, DELIM, NHEADERLINES) loads data from ASCII file
%   FILENAME, reading numeric data starting from line NHEADERLINES+1.
%
%   [A DELIM] = IMPORTDATA(...) returns the detected delimiter character 
%   for the input ASCII file.
%
%   [A DELIM NHEADERLINES] = IMPORTDATA(...) returns the detected number of
%   header lines in the input ASCII file.
%
%   [...] = IMPORTDATA('-pastespecial', ...) loads data from the system
%   clipboard rather than from a file.
%
%   Notes:
%
%   If IMPORTDATA recognizes the file extension, it calls the MATLAB helper
%   function designed to import the associated file format.  Otherwise,
%   IMPORTDATA interprets the file as a delimited ASCII file.
%
%   When the helper function returns more than one nonempty output,
%   IMPORTDATA combines the outputs into a structure array.  For details,
%   type "doc importdata" at the command prompt.
%
%   For ASCII files and spreadsheets, IMPORTDATA expects to find numeric
%   data in a rectangular form (that is, like a matrix).  Text headers can
%   appear above or to the left of numeric data.  To import ASCII files
%   with numeric characters anywhere else, including columns of character
%   data or formatted dates or times, use TEXTSCAN instead of IMPORTDATA.
%   When importing spreadsheets with columns of nonnumeric data, IMPORTDATA
%   cannot always correctly interpret the column and row headers.
%
%   Examples:
%
%   1) Import and display an image:
%
%        nebula_im = importdata('ngc6543a.jpg');
%        image(nebula_im);
%
%   2) Using a text editor, create an ASCII file called myfile.txt:
%
%        Day1  Day2  Day3  Day4  Day5  Day6  Day7
%        95.01 76.21 61.54 40.57  5.79 20.28  1.53
%        23.11 45.65 79.19 93.55 35.29 19.87 74.68
%        60.68  1.85 92.18 91.69 81.32 60.38 44.51
%        48.60 82.14 73.82 41.03  0.99 27.22 93.18
%        89.13 44.47 17.63 89.36 13.89 19.88 46.60
%
%      Import the file, and view columns 3 and 5:
%
%         M = importdata('myfile.txt', ' ', 1);
%         for k = [3, 5]
%           disp(M.colheaders{1, k})
%           disp(M.data(:, k))
%           disp(' ')
%        end
%
% See also LOAD, FILEFORMATS, TEXTSCAN, OPEN, LOAD, UIIMPORT.

% Copyright 1984-2009 The MathWorks, Inc.
% $Revision: 1.17.4.35 $  $Date: 2009/11/16 22:26:46 $

error(nargchk(1,4,nargin,'struct'));
error(nargoutchk(0,3,nargout,'struct'));

FileName = varargin{1};

if nargin > 1
    delim.requested = varargin{2};
else
    delim.requested = NaN;
end

if nargin > 2
    requestedHeaderLines = varargin{3};
else
    requestedHeaderLines = NaN;
end

out = [];

if nargout > 1
    delim.printed = [];
    delimiter = [];
end

if nargout > 2
    headerlines = 0;
end

bFlatten = true;
if nargin > 3 && isfield(varargin{4}, 'Flatten')   
    FlattenInput = varargin{4}.Flatten;
    if islogical(FlattenInput) && isscalar(FlattenInput)
        bFlatten = FlattenInput;
    end
end
    
if strcmpi(FileName,'-pastespecial')
    % fetch data from clipboard
    cb = clipboard('paste');
    if isnan(delim.requested)
        delim.printed = guessdelim(cb);
        delim.requested = delim.printed;
    else
        delim.printed = sprintf(delim.requested);
    end
    %When importing data from clipboard, do not warn of format mismatches.
    bWarn = false;
    try
        [out.data, out.textdata, headerlines] = parse(cb, ...
            delim, requestedHeaderLines, bWarn);
    catch %#ok<CTCH>
        error('MATLAB:importdata:InvalidClipboardData', 'Clipboard does not contain any recognizable data.');
    end
    out = LocalRowColShuffle(out);
    delimiter = delim.printed;
else

    % attempt extracting descriptive information about file
    warnState = warning('off', 'MATLAB:xlsfinfo:ActiveX');
    warnState(2) = warning('off', 'MATLAB:avifinfo:FunctionToBeRemoved');
    try
        [FileType,~,loadCmd,descr] = finfo(FileName);
        warning(warnState);
    catch %#ok<CTCH>
        warning(warnState);
        error('MATLAB:importdata:FileNotFound', 'Unable to open file.');
    end
    
    % Test success of FINFO call
    if strcmp(descr,'FileInterpretError')

        % Generate a warning that FINFO could not interpret data file
        Message = 'File contains uninterpretable data.';
        warning('MATLAB:IMPORTDATA:InvalidDataSection',Message)
        out.data=[]; % return an empty matrix object
        out.textdata={}; % return an empty cell object
        return
    end
    
    delim.printed = NaN;
    delimiter = delim.printed;
    %Just in case we found incorrect command, i.e. the name was a
    %coincidence, we'll try to load, but if we fail, we'll try to load
    %using other means.
    loaded = 0;
    if ~isempty(loadCmd) && ~strcmp(loadCmd,'importdata')
        try
            out.data = feval(loadCmd, FileName);
            loaded = 1;
        catch exception %#ok<NASGU>
        end
    end
    if (loaded == 0)
        if (strncmp(FileType, 'xls', 3) > 0)
            out = readFromExcelFile(FileName, descr, out, bFlatten);
        else
            switch FileType
            case 'wk1'
                [out.data, out.textdata] = wk1read(FileName);
                out = LocalRowColShuffle(out);
            case 'avi'
                S = warning('off', 'MATLAB:aviread:FunctionToBeRemoved');
                cleaner = onCleanup(@()warning(S));
                out = aviread(FileName);
            case 'im'
                [out.cdata, out.colormap, out.alpha] = imread(FileName);
            case {'au','snd'}
                [out.data, out.fs] = auread(FileName);
            case 'wav'
                [out.data, out.fs] = wavread(FileName);
            case 'mat'
                wasError = false;
                try
                    if ~isempty(whos('-file',FileName))
                        % call load with -mat option
                        out = load('-mat',FileName);
                    else
                        wasError = true;
                    end
                catch exception %#ok<NASGU>
                    wasError = true;
                end
                if wasError
                    % call load with -ascii option
                    out = load('-ascii',FileName);
                end
                if isempty(out)
                    error('MATLAB:importdata:InvalidFile', 'Unable to load file.  Not a MAT file.');
                end
            otherwise
                % try to treat as hidden mat file
                try
                    out = load('-mat',FileName);
                catch exception  %#ok<NASGU>
                    out = [];
                end
                if isempty(out)
                    try
                        % file is an unknown format, treat it as text
                        [out, delimiter, headerlines] = LocalTextRead(FileName, delim, requestedHeaderLines);
                    catch myException
                        finalException = MException('MATLAB:importdata:UnableToRead', 'Unable to load file.\nUse TEXTSCAN or FREAD for more complex formats.\n%s');
                        finalException = finalException.addCause(myException);
                        throw(finalException);
                    end
                end
            end
        end
    end
end

if (length(out) == 1 && isstruct(out))
    % remove empty fields from output struct
    names = fieldnames(out);
    for i = 1:length(names)
        if isempty(out.(names{i}))
            out = rmfield(out, names{i});
        end
    end
    if ~isempty(out)
        % flatten output struct if single variable
        names = fieldnames(out);
        if bFlatten && length(names) == 1 
            out = out.(names{1});
        elseif isempty(names)
            out = [];
        end
    end
end

function [out, delimiter, headerlines] = LocalTextRead(filename, delim, hlines)
% get the delimiter for the file
if isnan(delim.requested)
    fid = fopen(filename);
    str = fread(fid, 4096,'*char')';
    fclose(fid);
    delim.printed = guessdelim(str);
    delim.requested = delim.printed;
    
else
    delim.printed = sprintf(delim.requested);
end
delimiter = delim.printed;
% try load first (it works with tabs, spaces, and commas)
out = [];
if isnan(hlines) && ~isempty(findstr(delim.printed, sprintf('\t ,')))
    try
        out = load('-ascii', filename);
        headerlines = 0;
    catch exception  %#ok<NASGU>
        out = '';
    end
end
if isempty(out)
    fileString = fileread(filename);
    bWarn = true;
    [out.data, out.textdata, headerlines] = parse(fileString, delim, hlines, bWarn);
    out = LocalRowColShuffle(out);
end

function out = LocalRowColShuffle(in)

out = in;

if isempty(in) || ~isfield(in, 'data') || ~isfield(in,'textdata') || isempty(in.data) || isempty(in.textdata)
    return;
end

[dm, dn] = size(in.data);
[tm, tn] = size(in.textdata);

if tn == 1 && tm == dm
    % use as row headers
    out.rowheaders = in.textdata(:,end);
elseif tn == dn
    % use last row as col headers
    out.colheaders = in.textdata(end,:);
end

function [numericData, textData, numHeaderRows] = parse(fileString, ...
    delim, headerLines, bWarnOnMismatch)
%This is the function which takes in a string and parses it into
%"spreadsheet" type data.
error(nargchk(1,4,nargin, 'struct'));

numericData = [];
textData = {};
numHeaderRows = 0;

% gracefully handle empty
if isempty(fileString) && isempty(regexp(fileString,'\S','once')); 
    %regexp is faster than all(isspace(fileString));
        return;
end

% validate delimiter
if length(delim.printed) > 1
    error('MATLAB:importdata:InvalidDelimiter',...
        'Multi-character delimiters are not supported.')
end

if nargin < 3
    headerLines = NaN;
end

%Arbitrarily set the maximum size for a line, used to calculate this but it
%was slow, so we went with all in one line or the old maximum it would
%check.
bufsize = min(1000000, max(numel(fileString),100)) + 5;

% use what user asked for header lines if specified
[numDataCols, numHeaderRows, numHeaderCols, numHeaderChars] = ...
    analyze(fileString, delim, headerLines, bufsize);

% fetch header lines and look for a line of column headers
headerLine = {};
headerData = {};
origHeaderData = headerData;
useAsCells = 1;
    
if numHeaderRows
    firstLineOffset = numHeaderRows - 1;
    if firstLineOffset > 0
        headerData = textscan(fileString,'%[^\n\r]',firstLineOffset,...
            'whitespace','','delimiter','\n','bufsize', bufsize);
        origHeaderData = headerData{1};
        if numDataCols
            headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols + numDataCols - 1)];
        else
            headerData = [origHeaderData, cell(length(origHeaderData), numHeaderCols)];
        end
    else
        headerData = emptyCharCell(0, numHeaderCols + numDataCols);
    end

    Data = textscan(fileString,'%[^\n\r]',1,'headerlines',firstLineOffset,...
        'delimiter',delim.requested,'bufsize', bufsize);

    headerLine = Data{1};
    origHeaderLine = headerLine;
    
    useAsCells = 0;
    
    if ~isempty(delim.printed) && ~isempty(headerLine) && ~isempty(strfind(deblank(headerLine{:}), delim.printed))
        cellLine = split(headerLine{:}, delim);
        %Trailing spaces are not treated as extra delimiters
        if (delim.printed ~= ' ' && isequal(headerLine{:}(end),delim.printed))
            cellLine(end+1) = {''};
        end
        if length(cellLine) == numHeaderCols + numDataCols
            headerLine = cellLine;
            useAsCells = 1;
        end
    end
    
    if ~useAsCells
        if numDataCols
            headerLine = [origHeaderLine, emptyCharCell(1, numHeaderCols + numDataCols - 1)];
        else
            headerLine = [origHeaderLine, emptyCharCell(1, numHeaderCols)];
        end
    end
end

formatString = [repmat('%q', 1, numHeaderCols) repmat('%n', 1, numDataCols)];


% now try for the whole shootin' match
try
    if numDataCols
		 %When the delimiter is a space, multiple spaces do NOT mean
		 %multiple delimiters.  Thus, call textsscan such that it will
		 %treat them as one.

		if isequal(delim.printed,' ')
	        Data = textscan(fileString,formatString,'headerlines',numHeaderRows,...
                'CollectOutput', true, 'bufsize', bufsize);
		else
	        Data = textscan(fileString,formatString,'delimiter',delim.requested,...
                'bufsize', bufsize, 'headerlines',numHeaderRows, 'CollectOutput', true);
		end
		if (numHeaderCols)
		    numericData = Data{2};
		else
	        numericData = Data{1};
		end
    end
    wasError = false;
catch exception %#ok
    wasError = true;
end


if nargout > 1
    if numHeaderCols > 0
    	textData = emptyCharCell(size(Data{1}, 1), numDataCols+numHeaderCols);
        textData(:, 1:numHeaderCols) =  Data{1};
    end

    if ~isempty(headerLine)
        textData = [headerLine; textData];
    end

    if ~isempty(headerData)
        textData = [headerData; textData];
    end    
end
clear('Data');

if (numDataCols && numHeaderCols && (size(textData, 1) ~= numHeaderRows + size(numericData, 1)))
    wasError = true;
end
    
% if the first pass failed to read the whole shootin' match, try again using the character offset
if wasError && numHeaderChars
    wasError = false;
    
    % rebuild format string
    formatString = ['%' num2str(numHeaderChars) 'c' repmat('%n', 1, numDataCols)];

    %When the delimiter is a space, multiple spaces do NOT mean
    %multiple delimiters.  Thus, call textscan such that it will
    %treat them as one.
	if isequal(delim.printed,' ')
        Data = textscan(fileString,formatString,'headerlines',numHeaderRows,...
            'returnonerror',1, 'CollectOutput', true);
	else
        Data = textscan(fileString,formatString,'delimiter',delim.requested,...
            'headerlines',numHeaderRows,'returnonerror',1,'CollectOutput', true);
	end
	
    textCharData = Data{1};
    numericData = Data{2};
    numHeaderCols = 1;
    if ~isempty(numericData)
        numRows = size(numericData, 1);
    else
        numRows = length(textCharData);
    end
    
    if numDataCols
        headerData = [origHeaderData, ...
            emptyCharCell(length(origHeaderData), numHeaderCols + numDataCols - 1)];
    else
        headerData = [origHeaderData, ...
            emptyCharCell(length(origHeaderData), numHeaderCols)];
    end
    
    if ~useAsCells
        if numDataCols
            headerLine = [origHeaderLine, ...
                emptyCharCell(1, numHeaderCols + numDataCols - 1)];
        else
            headerLine = [origHeaderLine, emptyCharCell(1, numHeaderCols)];
        end
    end
   
    if nargout > 1 && ~isempty(textCharData)
        textCellData = cellstr(textCharData);
        if ~isempty(headerLine)
            textData = [headerLine; ...
                        textCellData(1:numRows), ...
                        emptyCharCell(numRows, numHeaderCols + numDataCols - 1)];
        else
            textData = [textCellData(1:numRows), ...
                emptyCharCell(numRows, numHeaderCols + numDataCols - 1)];
        end

        if ~isempty(headerData)
            textData = [headerData; textData];
        end
    end
end

if bWarnOnMismatch && wasError
	warning('MATLAB:importdata:FormatMismatch', ...
		'An unexpected format mismatch was detected.\nPlease check results against original file.');
end

if nargout > 1 && ~isempty(textData)
	textData = TrimTrailing(@(x)cellfun('isempty', x), textData);
end

if ~isempty(numericData) 
    numericData = TrimTrailing(@(x)(isnan(x)), numericData);
end

function out = emptyCharCell(m,n)
%Create a cell array with empty strings of a given size
out = repmat({''}, [m, n]);

function [numColumns, numHeaderRows, numHeaderCols, numHeaderChars] = ...
    analyze(fileString, delim, header, bufsize)
%ANALYZE count columns, header rows and header columns

numColumns = 0;
numHeaderRows = 0;
numHeaderCols = 0;
numHeaderChars = 0;

if ~isnan(header)
    numHeaderRows = header;
end

Data = textscan(fileString,'%[^\n\r]',1,'headerlines',numHeaderRows,...
    'delimiter',delim.requested,'bufsize', bufsize);
thisLine = Data{1};

if isempty(thisLine)
    return;
end
thisLine = thisLine{:};

[isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delim);

if ~isvalid && isnan(header)
    numHeaderRows = numHeaderRows + 1;
    Data = textscan(fileString,'%[^\n\r]',1,'headerlines',numHeaderRows,...
        'delimiter',delim.requested, 'bufsize', bufsize);

    thisLine = Data{1};
    if isempty(thisLine)
        return;
    end
    thisLine = thisLine{1};
    
    [isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delim);
    while ~isvalid 
        % stop now if the user specified a number of header lines
        if ~isnan(header) && numHeaderRows == header
            break;
        end
        numHeaderRows = numHeaderRows + 1;
        if numHeaderRows >= 1000
            %Assume no data.
            Data = textscan(fileString,'%[^\n\r]','headerlines',numHeaderRows,...
                'delimiter',delim.requested, 'bufsize', bufsize);
            thisLine = Data{1};
            numHeaderRows = length(thisLine) + numHeaderRows;
            break;
        end
        Data = textscan(fileString,'%[^\n\r]',1,'headerlines',numHeaderRows,...
                'delimiter',delim.requested, 'bufsize', bufsize);
            
        thisLine = Data{1};            
        if isempty(thisLine)
            break;
        end
        thisLine = thisLine{1};
        [isvalid, numHeaderCols, numHeaderChars] = isvaliddata(thisLine, delim);  
    end
end

% This check could happen earlier
if ~isnan(header) && numHeaderRows >= header
    numHeaderRows = header;
end

if isvalid
    % determine num columns
    %remove trailing spaces.  Spaces are different from other delimiters.
    thisLine = regexprep(thisLine, ' +$', '');
    delimiterIndexes = strfind(thisLine, delim.printed);
    if all(delim.printed ==' ') && length(delimiterIndexes) > 1
        delimiterIndexes = delimiterIndexes([true diff(delimiterIndexes) ~= 1]);
		delimiterIndexes = delimiterIndexes(delimiterIndexes > 1);
    end
    
    % format string should have 1 more specifier than there are delimiters
    numColumns = length(delimiterIndexes) + 1;
    if numHeaderCols > 0
        % add one to numColumns because the two set of columns share a delimiter
        numColumns = numColumns - numHeaderCols;
    end
end

function [status, numHeaderCols, numHeaderChars] = isvaliddata(fileString, delim)
% ISVALIDDATA delimiters and all numbers or e or + or . or -
% what about single columns???

numHeaderCols  = 0;
numHeaderChars = 0;

if isempty(delim.printed)
    % with no delimiter, the line must be all numbers, +, . or -
    status = isdata(fileString);
    return
end

status = 0;
if ~strcmp(delim.printed,'"')
    fileString = regexprep(fileString, '"[^"]*"','""');
end
delims = strfind(fileString, delim.printed);
if isempty(delims)
    checkstring = fileString;
    if isempty(regexp(checkstring, '\S', 'once'))
        % Just a blank line, not actually data.
        status = 0;
        return
    end
else
    checkstring = fileString(delims(end)+1:end);
end

% if there is data at the end of the line, it's legit
if isdata(checkstring)
    try
        [cellstring indices] = split(fileString, delim); 
        numNonEmptyCols = find(cellfun('isempty',deblank(cellstring)) == false, 1, 'last');
        numHeaderCols = maxNotData(cellstring); 
		% use contents of 1st data cell to find num leading chars
        if numHeaderCols > 0
            numHeaderChars = indices(numHeaderCols);
        end
        if (numHeaderCols == numNonEmptyCols)
            numHeaderCols = 0;
            numHeaderChars = 0;
        else
    		status = 1;
        end
    catch exception  %#ok<NASGU>
        numHeaderCols = 0;
        numHeaderChars = 0;
    end
end

function index = maxNotData(cellstring)
len = length(cellstring);
index = 0;
for i = len:-1:1
    if ~isdata(cellstring{i})
        index = i;
        break;
    end
end
        
function status = isdata(fileString)
%ISDATA true if string can be shoved into a number or if it's allwhite
if isempty(regexp(fileString, '\S', 'once'))
    status = 1;
else
    [~,b,c] = sscanf(fileString, '%g');
    status = isempty(c) && b == 1;
end

function [cellOut indOut] = split(fileString, delim)
%SPLIT rip string apart
if delim.printed == ' '
    %Multiple spaces are often used as a "fixed-width", thus we treat them
    %differently.
    cellOut = textscan(fileString,'%s','delimiter',delim.requested,...
        'multipleDelimsAsOne', 1, 'whitespace','');
    indOut = regexp(strtrim(fileString),' [^ ]') ;
else
    cellOut = textscan(fileString,'%s','delimiter',delim.requested,...
        'whitespace','');
    indOut = strfind(fileString,delim.printed);
end
cellOut = (cellOut{1})';

function out = TrimTrailing(operation, out)
% Trim trailing that use a certain operation
cols = size(out,2);
while cols >= 1
    if ~all(operation(out(:,cols)))
        break;
    end
    cols = cols - 1;
end
% trim trailing empty rows from textData
rows = size(out,1);
while rows >= 1
    if ~all(operation(out(rows,1:cols)))
        break;
    end
    rows = rows - 1;
end
if rows < size(out,1) || cols < size(out,2)
    out = out(1:rows,1:cols);
end

function out = readFromExcelFile(FileName, descr,out, bFlatten)
warnState = warning('off', 'MATLAB:xlsread:Mode');
warnState(2) = warning('off', 'MATLAB:xlsread:ActiveX');
cleanupObj = onCleanup(@()warning(warnState));
if bFlatten && length(descr) == 1
    baseSubs = {struct('type', {}, 'subs', {})};
else
    names = genvarname(descr);
    baseSubs = num2cell(struct('type','.', 'subs', names));
end
% top level fields so assignments below work right
for i = 1:length(descr)
    [n,s,raw] = xlsread(FileName,descr{i});
    likely_row = size(raw,1) - size(n,1);
    if ~isempty(n)
        out = subsasgn(out, [substruct('.','data') baseSubs{i}], n);
    end
    if ~isempty(s)
        out = subsasgn(out, [substruct('.', 'textdata') baseSubs{i}], s);
    end
    
    if ~isempty(s) && ~isempty(n)
        [dm, dn] = size(n);
        [tm, tn] = size(s);
        if tn == 1 && tm == dm
            out = subsasgn(out, [substruct('.', 'rowheaders') baseSubs{i}], s(:,end));
        elseif tn == dn && likely_row > 0 && tm >= likely_row
            out = subsasgn(out, [substruct('.', 'colheaders') baseSubs{i}], s(likely_row, :));
        end
    end
end
