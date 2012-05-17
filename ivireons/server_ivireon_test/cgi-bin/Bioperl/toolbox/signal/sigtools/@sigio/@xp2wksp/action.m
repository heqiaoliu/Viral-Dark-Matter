function success = action(this)
%ACTION Perform the action of exporting to the Workspace.

%   Author(s): P. Costa
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2009/03/09 19:35:44 $

tnames  = get(this,'VariableNames');
if ~iscell(tnames), tnames = {tnames}; end

% Check if the variables exist in the workspace.
[varsExist, existMsg] = chkIfVarExistInWksp(tnames);

% Check if VariableNames are unique
[varsUnique, uniqueMsg] = chkVarName(tnames);

overwriteVars = get(this,'Overwrite');

if (~overwriteVars && varsExist) || ~varsUnique,
    % Variables exist, put up a warning dialog and set the
    % flag to not close the dialog.
    if ~isempty(uniqueMsg), error(generatemsgid('SigErr'),uniqueMsg); end
    if ~isempty(existMsg), error(generatemsgid('SigErr'),existMsg); end
    success = false;
else
    
    % variables & tnames are cell arrays of the same length.
    variables = formatexportdata(this);
    
    % Make sure that when we only have a single variable to be exported to
    % the workspace, that the information we export is everything in the
    % 'variables' variable. g307525
    if length(tnames) == 1 && length(variables) ~= 1
        variables = {variables};
    end
    
    for i = 1:length(tnames)
        
        % Check for valid names
        if isvarname(tnames{i}),
            assign2wkspace('base',tnames{i},variables{i});
        else
            error([tnames{i} ' is not a valid variable name.']);
        end
    end
    
    % Message to be displayed in the command window. 
    sendstatus(this, 'Variables have been exported to the workspace.');
    success = true;
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

% Get the base workspace variable names
vars = evalin('base', 'whos');
vars = {vars.name};

% Check if there are any common names between the base workspace and the
% variable names we are going to use for export.
common = intersect(vars, vnames);

if ~isempty(common)
     varsExist = 1;
     existMsg = ['The variable ' common{1} ' already exists in the MATLAB workspace.'];
end

%-------------------------------------------------------------------
function [varsUnique, existMsg] = chkVarName(tnames)
% CHKVARNAME Check if the variables names are unique 
    
varsUnique = true;
existMsg = '';

[B,I,J] =  unique(tnames);
for n = 1:length(J),
    idx = find(J == J(n));
    
    if length(idx) > 1, 
        % Variable Name is repeated
        varsUnique = false; 
        existMsg = ['The variable names are not unique.'];
        return; 
    end 
end

% [EOF]
