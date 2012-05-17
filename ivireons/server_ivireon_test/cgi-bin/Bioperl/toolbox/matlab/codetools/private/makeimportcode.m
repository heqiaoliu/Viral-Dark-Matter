function varargout = makeimportcode(varargin)
% This undocumented function may change in a future release.

%MAKEIMPORTCODE Generates readable m-code function based on input argument
%
%  MAKEIMPORTCODE(PARAMS) Generates m-code for importing data from a file 
%               (or the clipboard) using the specified parameters, and
%               displays the code in the desktop editor.
%
%  STR = MAKEIMPORTCODE(PARAMS, 'Output', '-editor')  Display code in the
%               desktop editor
%
%  STR = MAKEIMPORTCODE(PARAMS, 'Output', '-string') Output code as a 
%                string variable
%
%  MAKEIMPORTCODE(PARAMS,'Output', FILENAME) Output code as a file
%
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/01/25 21:41:59 $

% Fields for PARAMS
% --------
% REQUIRED:
% hasInputArg - logical
% hasOutputArg - logical
% needsStructurePatch - logical
% loadFunc - double.  One of...
%     0 = IMPORTDATA
%     1 = LOAD -MAT
%     2 = LOAD -ASCII
%     3 = LOAD -XL
%     4 = LOAD -WK1
% outputBreakup - double.  One of...
%     0 = "normal"
%     1 = "by Column"
%     2 = "by Row"
% unpackXLSdata - logical
% unpackXLStextdata - logical
% unpackXLScolheaders - logical
% unpackXLSrowheaders - logical

%
% OPTIONAL:
% delimiter - char (ignored if loadFunc ~= 0)
% headerLines - double (ignored if loadFunc ~= 0)
% worksheetName - char (ignored if loadFunc ~= 3)
 
% Check arguments.
checkArguments(varargin)
% Strip away unnecessary arguments, and add some new, calculated 
% parameters for later use.
params = adjustParams(varargin{1});
% Generate the basic function code.
hFunc = localGenCode(params);
% Add it to a codeprogram.
hProgram = codegen.codeprogram;
hProgram.addSubFunction(hFunc);
% Configure the output options, and use them to generate the code.
options = configureOptions(varargin);
strCells = hProgram.toMCode(options);
% Output the generated code in the requested style, possibly returning it.
out = handleGeneratedCode(options, generateCodeString(strCells));
if ~isempty(out)
    varargout{1} = out;
end

%-------------------------------
function checkArguments(args)
if isempty(args)
    error('MATLAB:codetools:makeimportcode:InsufficientArguments', ...
        'MAKEIMPORTCODE requires at least one input argument.');
end
if rem(length(args), 2) ~= 1
    error('MATLAB:codetools:makeimportcode:ArgumentsMustBeOdd', ...
        'MAKEIMPORTCODE requires an odd number of input arguments.');
end
if ~isstruct(args{1})
    error('MATLAB:codetools:makeimportcode:FirstArgMustBeStruct', ...
        'The first input argument to MAKEIMPORTCODE must be a structure.');
end
for i = 2:length(args)
    if ~ischar(args{i})
        error('MATLAB:codetools:makeimportcode:ArgsMustBeChars', ...
        'The second and subsequent input arguments to MAKEIMPORTCODE must be character arrays.');
    end
end

%-------------------------------
function params = adjustParams(params)
params.LOADMAT = params.loadFunc == 1;
params.LOADASCII = params.loadFunc == 2;
params.LOADXL = params.loadFunc == 3;
params.LOADWK1 = params.loadFunc == 4;
params.IMPORTDATA = ~params.LOADMAT && ~params.LOADASCII && ~params.LOADXL && ~params.LOADWK1;
if (~params.IMPORTDATA)
    if isfield(params, 'delimiter')
        params = rmfield(params, 'delimiter');
    end
    if isfield(params, 'headerLines')
        params = rmfield(params, 'headerLines');
    end
end

%-------------------------------
function options = configureOptions(args)
options.Output = '-editor';
options.OutputTopNode = false;
options.ReverseTraverse = false;
options.ShowStatusBar = false;
options.MFileName = '';
if length(args) > 2
    for i = 2:(length(args)-1)
        if strcmpi(args{i}, 'Output')
            options.Output = args{i+1};
        end
    end
    if ( ~strcmp(options.Output,'-editor') && ...
            ~strcmp(options.Output,'-string') && ...
            ~strcmp(options.Output,'-cmdwindow') )
        [~, file] = fileparts(options.Output);
        options.MFileName = file;
    end
end

%-------------------------------
function str = generateCodeString(strCells)
str = [];
for n = 1:length(strCells)
    str = [str, strCells{n}, sprintf('\n')]; %#ok<AGROW>
end

%-------------------------------
function hFunc = localGenCode(params)

hFunc = codegen.coderoutine;

hFunc.Name = 'importfile';
if params.hasInputArg
    hFunc.Comment = 'Imports data from the specified file';
else
    hFunc.Comment = 'Imports data from the system clipboard';
end

hInputArg = generateInputArg(params.hasInputArg);
if (params.hasInputArg)
    hFunc.addArgin(hInputArg);
end
    
hOutputArg = generateOutputArgForImport;
importTheData(hFunc, params, hInputArg, hOutputArg);

if params.needsStructurePatch
    hOutputArg = createSimpleOutputWorkaround(hFunc, hInputArg, hOutputArg);
end

if (params.LOADXL || params.LOADWK1)
    createXLNewVariables(hFunc, hOutputArg, params.unpackXLScolheaders, params.unpackXLSrowheaders, params.outputBreakup);
    if params.outputBreakup ~= 0
        hNewOutput=changeOutputBreakup(hFunc, hOutputArg, params);
    else
        hNewOutput=hOutputArg;
    end
    if params.hasOutputArg == 0
        createWorkspace(hFunc, hOutputArg, params.outputBreakup);
    else
        createXLOutput(hFunc, hNewOutput, hOutputArg, params.outputBreakup);
    end
    generateXLOutputHandling(hFunc, params.hasOutputArg, hNewOutput);
else
    if params.outputBreakup ~= 0
        hNewOutput=changeOutputBreakup(hFunc, hOutputArg, params);
    else
        hNewOutput=hOutputArg;
    end
    if params.hasOutputArg == 0
        createWorkspace(hFunc, hOutputArg, params.outputBreakup);
    end    
    generateOutputHandling(hFunc, params.hasOutputArg, hNewOutput);
end

function createXLOutput (hFunc, hNewOutput, hOutputArg, outputBreakup)
switch (outputBreakup)
    case 2
        hFunc.addText();
        hFunc.addText(xlate('% Create output variables.'));
        hFunc.addText('for i = 1:size(', hOutputArg, '.rowheaders, 1)');
        hFunc.addText('    ', hNewOutput, '.(genvarname(', hOutputArg, '.rowheaders{i})) = ', hOutputArg, '.data(i, :);');
        hFunc.addText('end');

    case 1
        hFunc.addText();
        hFunc.addText(xlate('% Create output variables.'));        
        hFunc.addText('for i = 1:size(', hOutputArg, '.colheaders, 2)');
        hFunc.addText('    ', hNewOutput, '.(genvarname(', hOutputArg, '.colheaders{i})) = ', hOutputArg, '.data(:, i);');
        hFunc.addText('end');
    
    otherwise
        % Do nothing
end

%-------------------------------
function hInputArg = generateInputArg(hasInputArg)
hInputArg = codegen.codeargument;
hInputArg.IsParameter = hasInputArg;
if hasInputArg
    hInputArg.Name = 'fileToRead';
    hInputArg.Comment = 'File to read';
else
    hInputArg.Name = '''-pastespecial''';
    hInputArg.Comment = 'Read data from the system clipboard';
    hInputArg.Value = '-pastespecial';
end

%-------------------------------
function hOut = generateOutputArgForImport
hOut = codegen.codeargument;
hOut.IsParameter = true;
hOut.IsOutputArgument = true;
hOut.Name = 'newData';

%-------------------------------
function createXLNewVariables(hFunc, hOutputArg, unpackXLScolheaders, unpackXLSrowheaders, outputBreakup)

XL_NUM = 'numbers';
XL_STR = 'strings';

hFunc.addText('if ~isempty(', XL_NUM, ')');
hFunc.addText('    ', hOutputArg, '.data = ', ' ', XL_NUM, ';');
hFunc.addText('end');

if outputBreakup == 0
    hFunc.addText('if ~isempty(', XL_STR, ')');
    hFunc.addText('    ', hOutputArg, '.textdata = ', ' ', XL_STR, ';');   
    hFunc.addText('end');
end

if unpackXLSrowheaders
    hFunc.addText('');
    hFunc.addText('if ~isempty(strings) && ~isempty(numbers)');
    hFunc.addText('    [strRows, strCols] = size(strings);');
    hFunc.addText('    [numRows, ~] = size(numbers);');    
    hFunc.addText(xlate('    % Break the data up into a new structure with one field per row.'));
    hFunc.addText('    if  strCols == 1 && strRows == numRows');
    hFunc.addText('        ', hOutputArg, '.rowheaders = strings(:,end);');
    hFunc.addText('    end');
    hFunc.addText('end');
end
if unpackXLScolheaders
    hFunc.addText('');
    hFunc.addText('if ~isempty(strings) && ~isempty(numbers)');
    hFunc.addText('    [strRows, strCols] = size(strings);');
    hFunc.addText('    [numRows, numCols] = size(numbers);');    
    hFunc.addText('    likelyRow = size(raw,1) - numRows;'); 
    hFunc.addText(xlate('    % Break the data up into a new structure with one field per column.'));
    hFunc.addText('    if strCols == numCols && likelyRow > 0 && strRows >= likelyRow');
    hFunc.addText('        ', hOutputArg, '.colheaders = strings(likelyRow, :);');
    hFunc.addText('    end');
    hFunc.addText('end');
end



%-------------------------------
function createWorkspace(hFunc, hOutputArg, outputBreakup)
switch (outputBreakup) 
    case 1        
        hFunc.addText();
        hFunc.addText(xlate('% Create new variables in the base workspace from those fields.'));
        hFunc.addText('for i = 1:size(', hOutputArg, '.colheaders, 2)');
        hFunc.addText('    assignin(''base'', genvarname(', hOutputArg, '.colheaders{i}), ', hOutputArg, '.data(:,i));');
        hFunc.addText('end');
        
    case 2
        hFunc.addText();
        hFunc.addText(xlate('% Create new variables in the base workspace from those fields.'));
        hFunc.addText('for i = 1:size(', hOutputArg, '.rowheaders, 1)');
        hFunc.addText('    assignin(''base'', genvarname(', hOutputArg, '.rowheaders{i}), ', hOutputArg, '.data(i,:));');
        hFunc.addText('end');        
        
    otherwise
        hFunc.addText();
        hFunc.addText(xlate('% Create new variables in the base workspace from those fields.'));
        hFunc.addText('vars = fieldnames(', hOutputArg, ');');
        hFunc.addText('for i = 1:length(vars)');
        hFunc.addText('    assignin(''base'', vars{i}, ', hOutputArg, '.(vars{i}));');
        hFunc.addText('end');
end

%-------------------------------
function returnValuesAsStructure(hFunc, hOut)
hFunc.addArgout(hOut);

%-------------------------------
function importTheData(hFunc, params, hInputArg, hOutputArg)
delimiterArgument = '';
headerLinesArgument = '';
if isfield(params, 'delimiter') && (~isempty(params.delimiter))
    hFunc.addText('DELIMITER = ''', params.delimiter, ''';');
    delimiterArgument = ', DELIMITER';
    if isfield(params, 'headerLines') && (params.headerLines ~= -1)
        hFunc.addText('HEADERLINES = ', num2str(params.headerLines), ';');
        headerLinesArgument = ', HEADERLINES';
    end
    hFunc.addText('');
end

hFunc.addText ( xlate ( '% Import the file' ) ) ;

if params.LOADXL && (isfield(params, 'worksheetName')) && ~strcmp(params.worksheetName,'')
    closing = strcat(', sheetName);') ;
else
    closing = ');' ;
end

if params.LOADMAT
    fun = 'load(''-mat'', ';
elseif params.LOADASCII
    fun = 'load(''-ascii'', ';
elseif params.LOADXL
    fun = 'xlsread(';
elseif params.LOADWK1
    fun = 'wk1read(';
else
    fun = 'importdata(';
end

if params.LOADXL
    hFunc.addText('sheetName=''', params.worksheetName, ''';');
    if params.unpackXLScolheaders
        hFunc.addText('[numbers, strings, raw]', ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, closing);
    else
        hFunc.addText('[numbers, strings]', ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, closing);
    end
elseif params.LOADWK1
    hFunc.addText('[numbers, strings]', ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, closing);
else
    hFunc.addText(hOutputArg, ' = ', fun, hInputArg, delimiterArgument, headerLinesArgument, closing);
end

%-------------------------------
function hNewOutputArg = createSimpleOutputWorkaround(hFunc, hInputArg, hOutputArg)
hOutputArg.Name = 'rawData';

hNewOutputArg = codegen.codeargument;
hNewOutputArg.IsParameter = true;
hNewOutputArg.IsOutputArgument = true;
hNewOutputArg.Name = 'newData';

hFunc.addText('');
hFunc.addText(xlate('% For some simple files (such as a CSV or JPEG files), IMPORTDATA might')); 
hFunc.addText(xlate('% return a simple array.  If so, generate a structure so that the output')); 
hFunc.addText(xlate('% matches that from the Import Wizard.'));
hFunc.addText('[~,name] = fileparts(', hInputArg, ');');
hFunc.addText(hNewOutputArg, '.(genvarname(name)) = ', hOutputArg, ';');

%-------------------------------
function hOutputArg = changeOutputBreakup(hFunc, hOutputArg, params)
switch (params.outputBreakup) 
    case 1
        hNewOutputArg = codegen.codeargument;
        hNewOutputArg.IsParameter = true;
        hNewOutputArg.IsOutputArgument = true;
        hNewOutputArg.Name = 'dataByColumn';
        
        if ~params.LOADXL && ~params.LOADWK1 && params.hasOutputArg ~= 0
            hFunc.addText('');
            hFunc.addText(xlate('% Break the data up into a new structure with one field per column.'));
            hFunc.addText('colheaders = genvarname(', hOutputArg ,'.colheaders);');
            hFunc.addText('len = size(colheaders,2);');
            hFunc.addText('for i = 1:len');
            hFunc.addText('    ', hNewOutputArg, '.(colheaders{1,i}) = ', ...
                hOutputArg, '.data(:, i);');
            hFunc.addText('end');
        end
        
		hOutputArg = hNewOutputArg;
        
    case 2
        hNewOutputArg = codegen.codeargument;
        hNewOutputArg.IsParameter = true;
        hNewOutputArg.IsOutputArgument = true;
        hNewOutputArg.Name = 'dataByRow';
        
        if ~params.LOADXL && ~params.LOADWK1 && params.hasOutputArg ~= 0
            hFunc.addText('');
            hFunc.addText(xlate('% Break the data up into a new structure with one field per row.'));
            hFunc.addText('rowheaders = genvarname(', hOutputArg ,'.rowheaders);');
            hFunc.addText('for i = 1:length(rowheaders)');
            hFunc.addText('    ', hNewOutputArg, '.(rowheaders{i}) = ', ...
                hOutputArg, '.data(i, :);');
            hFunc.addText('end');
        end
        
		hOutputArg = hNewOutputArg;
        
    otherwise
        % Do nothing
end 

%-------------------------------
function generateOutputHandling(hFunc, hasOutputArg, hOutputArg)
if hasOutputArg
    returnValuesAsStructure(hFunc, hOutputArg);
end

%-------------------------------
function generateXLOutputHandling(hFunc, hasOutputArg, hOutputArg)
if hasOutputArg
    returnValuesAsStructure(hFunc, hOutputArg);
end

%-------------------------------
function res = handleGeneratedCode(options, str)
res = '';
if strcmp(options.Output,'-cmdwindow')
    disp(str);
elseif strcmp(options.Output,'-editor')
    % Throw to command window if java is not available
    err = javachk('mwt','The MATLAB Editor');
    if ~isempty(err)
        local_display_mcode(str,'cmdwindow');
    end
    editorDoc = editorservices.new(str);
    editorservices.matlab.smartIndentContents(editorDoc);
elseif strcmp(options.Output,'-string')
    res = str;
else
    fid = fopen(options.Output,'w');
    if(fid<0)
        error('MATLAB:codetools:makeimportcode:CannotSave',['Could not create file: ',options.Output]);
    end
    fprintf(fid,'%s',str);
    fclose(fid);
end
