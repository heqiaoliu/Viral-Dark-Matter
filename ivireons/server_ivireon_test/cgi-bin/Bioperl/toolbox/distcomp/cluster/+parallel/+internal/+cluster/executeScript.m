function workspaceOut = executeScript(scriptName, workspaceIn, workerCwd) %#ok<INUSL>

%  Copyright 2008-2010 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $  $Date: 2010/03/22 03:42:11 $

% Let's try and deal with the CWD to make this work in a shared file=system
% - NOTE any errors we will stick with the current CWD and try and continue
try
    cd(workerCwd);
catch err
    warning('distcomp:batch:ErrorSettingCurrentDirectory', ...
        ['Unable to change to requested folder: %s.\n', ...
        'Current folder is: %s.\nReason: %s'], ...
        workerCwd, pwd, err.message);
end

% We have to be VERY careful to allow all possible variables to be passed into
% the script and retrieved from it. The next line of code MUST be a single eval
% statement which firstly clears everything left in this workspace and then evals
% the script we need. Note that the string that is temporarily made contains the
% script to execute and thus it is OK to clear scriptName early;
%eval(['iClearAndSetCallerWorkspace(batchArgsIn.WorkspaceIn);' scriptName]);
eval(['iClearAndSetCallerWorkspace(workspaceIn);' scriptName]);
% Get remaining values from this workspace - we need to do this in a subfunction 
% workspace because otherwise we might pollute this workspace
workspaceOut = iGetCallerWorkspace;

% ------------------------------------------------------------------------------
%
% ------------------------------------------------------------------------------
function iClearAndSetCallerWorkspace(workspaceIn) %#ok<DEFNU>
% Clear all variables in the caller workspace
varsToClear = evalin('caller', 'whos');
evalin('caller', ['clear ' sprintf('%s ', varsToClear.name)]);
% Get the input variable names
varNamesIn = fieldnames(workspaceIn);
% Next populate with the required variables
for i = 1:numel(varNamesIn)
    assignin('caller', varNamesIn{i}, workspaceIn.(varNamesIn{i}));
end

% ------------------------------------------------------------------------------
%
% ------------------------------------------------------------------------------

function workspace = iGetCallerWorkspace
% No workspace supplied - we need to make our own from the calling workspace
where = 'caller';
% No workspace supplied - we need to make our own from the calling workspace
vars = evalin(where, 'whos');
workspace = cell2struct(repmat({[]}, numel(vars), 1), {vars.name}, 1);
pctFieldsToRemove = {};
% Loop over each variable in the calling workspace and assign it into part
% of the workspace structure
for i = 1:numel(vars)
    thisName =  vars(i).name;
    thisValue = evalin(where, thisName);
    % DO NOT send across PCT objects as we know they don't serialize
    % correctly
    if isa(thisValue, 'distcomp.object')
        pctFieldsToRemove{end + 1} = thisName; %#ok<AGROW>
    else
        workspace.(thisName) = thisValue;
    end
end
% Are there any fields to remove?
if ~isempty(pctFieldsToRemove)
    workspace = rmfield(workspace, pctFieldsToRemove);
end 
