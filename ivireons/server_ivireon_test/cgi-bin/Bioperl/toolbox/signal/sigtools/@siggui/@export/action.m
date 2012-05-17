function autoclose = action(hXP)
%ACTION Perform the action of the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.23.4.4 $  $Date: 2009/03/09 19:35:31 $

target = get(hXP,'ExportTarget');

% Call out to the specific function depending on the exporttarget
switch target,
    case 'Workspace',  autoclose = export2wkspace(hXP);
    case 'Text-file',  autoclose = export2file(hXP, 'text');
    case 'MAT-file',   autoclose = export2file(hXP, 'mat');
end


%---------------------------------------------------------------------
function aClose = export2wkspace(hXP)
%EXPORT2WKSPACE Export Coefficients to the MATLAB Workspace.  
%
% Inputs:
%    hXP - Handle to the Export dialog object

if iscoeffs(hXP),
    variables = get(hXP,'Variables');
    tnames    = get(hXP,'TargetNames');
else
    variables = get(hXP, 'Objects');
    tnames    = get(hXP, 'ObjectTargetNames');
end

% Check if the variables exist in the workspace.
[varsExist, existMsg] = chkIfVarExistInWksp(tnames);

overwriteVars = get(hXP,'Overwrite');

if ~overwriteVars & varsExist,
    % Variables exist, put up a warning dialog and set the
    % flag to not close the dialog.
    warning(existMsg);
    
    aClose = false;
else
    for i = 1:length(tnames)
        
        % Check for valid names
        if isvarname(tnames{i}),
            assign2wkspace('base',tnames{i},variables{i});
        else
            error([tnames{i} ' is not a valid variable name.']);
        end
    end
    
    % Message to be displayed in the command window. 
    exportMsg = 'Variables have been exported to the workspace.';
    sendstatus(hXP, exportMsg);
    aClose = true;
end

%---------------------------------------------------------------------
function aClose = export2file(hXP, fileType)
%EXPORT2FILE Export filter coefficients to a file (MAT or Text).
%
% Inputs:
%    hXP - Handle to the Export dialog object

aClose    = true;

switch fileType,
    case 'text',
        file = 'untitled.txt';
        dlgStr = 'Export Filter Coefficients to a Text-file';
    case 'mat',
        file = 'untitled.mat';
        dlgStr = 'Export Filter Coefficients to a MAT-file';
end

% Put up the file selection dialog
[filename, pathname] = uiputfile(file,dlgStr);
file = [pathname filename];

% filename is 0 if "Cancel" was clicked.
if filename ~= 0,
    
    % Unix returns a path that sometimes includes two paths (the
    % current path followed by the path to the file) separated by '//'.
    % Remove the first path.
    indx = findstr(file,[filesep,filesep]);
    if ~isempty(indx)
        file = file(indx+1:end);
    end
    
    if strcmpi(fileType,'mat'),
        save2matfile(hXP,file);
    else            
        save2textfile(hXP,file);
    end
end

%------------------------------------------------------------------------
function save2matfile(hXP,f_i_l_e)
%SAVE2MATFILE Save filter coefficients to a MAT-file
%
% Inputs:
%   f_i_l_e - String containing the MAT-file name.
%   hXP - Handle to the Export dialog object

if iscoeffs(hXP),
    variables = get(hXP, 'Variables');
    tnames    = get(hXP, 'TargetNames');
else
    variables = get(hXP, 'Objects');
    tnames    = get(hXP, 'ObjectTargetNames');
end

for i = 1:length(tnames)
    if isvarname(tnames{i}),
        assign2wkspace('caller',tnames{i},variables{i});
    else
        error([tnames{i} ' is not a valid variable name.']);
    end
end

% Create the MAT-file
save(f_i_l_e,tnames{:},'-mat');

%------------------------------------------------------------------------
function save2textfile(hXP, file)
%SAVE2TEXTFILE Save filter coefficients to a Text-file
%
% Inputs:
%   file  - String containing the Text-file name.
%   hXP - Handle to the Export dialog object

fid = fopen(file, 'w');

% Display header information
fprintf(fid,'%s\n',sptfileheader);

if iscoeffs(hXP),
    savevars2textfile(hXP, fid);
else
    error(generatemsgid('cannotExport'), ...
        'Objects cannot be exported to a text-file.');
end

fclose(fid);

% Launch the MATLAB editor (to display the coefficients)
edit(file);

%------------------------------------------------------------------------
function autoClose = savevars2textfile(hXP, fid)

autoClose = true;

variables = get(hXP, 'Variables');

% Cascade and parallel filters use these labels.
labels    = get(hXP, 'TextFileVariableHeaders');

if isempty(labels),
    labels    = get(hXP, 'Labels');
end

% Print the header comments
textcomment = get(hXP, 'TextFileComment');
inputs      = printheader(fid, textcomment);

if iscell(labels{1}),
    variables = variables{1};
end

print2file(hXP, fid, labels, variables, inputs{:});

%-------------------------------------------------------------------
function print2file(hXP, fid, labels, variables, inputs)

for i = 1:length(labels),
        
    if iscell(labels{i}),
        if nargin > 4
            outputs = printheader(fid, inputs{i});
        else
            outputs = {};
        end

        print2file(hXP, fid, labels{i}, variables{i}, outputs{:});
    else
        fprintf(fid, '%s:\n', labels{i});
        
        % Only perform this action on a vector.
        if any(size(variables{i}) == 1),
            switch lower(hXP.VectorPrintToTextFormat),
                case 'rows',
                    variables{i} = variables{i}(:)';
                case 'columns'
                    variables{i} = variables{i}(:);
            end
        end
        sz = size(variables{i});
        for j = 1:sz(1), % Rows
            fprintf(fid, '%s\n', num2str(variables{i}(j,:),10));
        end
        fprintf(fid, '\n');
    end
end

%-------------------------------------------------------------------
function inputs = printheader(fid, textcomment)

if iscell(textcomment)
    
    % If there is a string in the first element of the cell array and the
    % 2nd element is another cell we want to print the string and pass back
    % the other cell array.  The string is a "header of headers".
    if length(textcomment) == 2 && iscell(textcomment{2}) && ischar(textcomment{1}),
        printheader(fid, textcomment{1});
        inputs = {textcomment{2}};
    else
        inputs = {textcomment};
    end
else
    inputs = {};
    for indx = 1:size(textcomment, 1),
        fprintf(fid, '%% %s\n', deblank(textcomment(indx, :)));
    end
    
    if ~isempty(textcomment),
        fprintf(fid, '\n');
    end 
end

%-------------------------------------------------------------------
function assign2wkspace(wkspace, name, variable)

assignin(wkspace, name, variable);

%-------------------------------------------------------------------
function [varsExist, existMsg] = chkIfVarExistInWksp(vnames)
% CHKIFVAREXISTINWKSP Check if the variables exist in the workspace.
%
% Input:
%   vnames - Filter Structure specific coefficient strings stored
%               in FDATool's UserData.
%
% Outputs:
%   varsExist - Boolean flag to indicate if variables exist in the
%               MATLAB workspace.
%   existMsg  - Warning dialog string to let the user know that their
%               variable(s) already exists.             

varsExist = 0;
existMsg = '';

for n = 1:length(vnames),
    % Using the evaluatevars function since the "exist" function cannot be made
    % to look in the base MATLAB workspace.  
    [vals, errStr] = evaluatevars(vnames{n}); 
    
    % Put up a message if the variables exist
    if ~isempty(vals),
        varsExist = 1;
        existMsg = ['The variable ' vnames{n} ' already exists in the MATLAB workspace.'];
        return; % Return immediately after finding the first existing variable
    end
end

% [EOF]
