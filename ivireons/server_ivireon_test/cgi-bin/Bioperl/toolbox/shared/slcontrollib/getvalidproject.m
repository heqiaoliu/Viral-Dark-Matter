function [project,FRAME] = getvalidproject(diagram_name,addoptaskflag,varargin)
%  GETVALIDPROJECT Gets or creates a valid project for a new task to be added.

% Author(s): John Glass
% Revised:
%   Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2008/01/29 15:37:02 $

% Check for valid platform for Java Swing
if (~usejava('Swing'))
    ctrlMsgUtils.error('SLControllib:explorer:JavaNotSupportedOnThisPlatform');
end

% Get the frame and workspace handles
[FRAME,WSHANDLE] = slctrlexplorer;

% Get the select node after a draw now has occurred since there may be a node selection
% still in the event queue.
drawnow
selected = FRAME.getSelected;
if isempty(selected)
    %% Make the workspace to be the selected node.
    selected = WSHANDLE;
else
    selected = handle(getObject(selected));
end

if (nargin == 3)
    %% Create a new project if there are two input arguments
    project = explorer.Project(WSHANDLE, diagram_name);
    project.Label = project.createDefaultName(varargin{1}, WSHANDLE);

    %% Add it to the workspace
    WSHANDLE.addNode(project);
    %% Create the operating conditions if Simulink Control Designer if needed;
    LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
elseif isa(selected,'explorer.Workspace')
    %% This is the case where the workspace node is selected
    project = LocalCreateProjectfromWorkspace(diagram_name,selected,addoptaskflag);
else
    %% At this point a project has not been assigned
    project = [];
    %% This is the case where any other node is selected
    SelectedRoot = selected.getRoot;
    %% Loop up until we reach the top of a project
    while ~isempty(SelectedRoot)
        if (isa(SelectedRoot,'explorer.Project'))
            project = SelectedRoot;
            break
        end
        SelectedRoot = SelectedRoot.up;
    end

    if isempty(project) || ~strcmp(project.Model,diagram_name)
        %% Create a new project if the diagram name does not match
        project = LocalCreateProjectfromWorkspace(diagram_name,WSHANDLE,addoptaskflag);
    else
        %% Create the operating conditions if Simulink Control Designer if needed;
        LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function LocalCreateProjectfromWorkspace create a project given a
% workspace handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function project = LocalCreateProjectfromWorkspace(diagram_name,workspace,addoptaskflag)

projects = workspace.getChildren;
validind = find(strcmp(get(projects,'Model'),diagram_name));
if isempty(validind);
    %% Create a new project
    project = explorer.Project(workspace, diagram_name);
    project.Label = project.createDefaultName(sprintf('Project - %s', diagram_name), workspace);
    %% Add it to the workspace
    workspace.addNode(project);
    %% Create the operating conditions if Simulink Control Designer if needed;
    LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
else
    project = projects(validind(1));
    %% Create the operating conditions if Simulink Control Designer if needed;
    LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function LocalCreateOpSpec create the operating condition task node
% object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateOpSpecNode(diagram_name,project,addoptaskflag)

if addoptaskflag && license('test','Simulink_Control_Design')
    OperatingConditions.addoptask(diagram_name,project);
end
