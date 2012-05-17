function this = NewTaskDialog(varargin)
% NEWTASKDIALOG Create and configure the new task dialog

% Author(s): John Glass
% Revised: Bora Eryilmaz
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.25.2.1 $ $Date: 2010/07/23 15:43:03 $

% Block the explorer while the dialog is being created
FRAME = slctrlexplorer;
FRAME.setBlocked(true,[]);

% Create the object
this = explorer.NewTaskDialog;
this.TaskConfig = LocalGetTaskConfig(this);% Gather all available task name IDs

node = varargin{1};
if isa(node,'explorer.Project')
    % Store the project node
    this.CurrentProject = node;
    this.CurrentWorkspace = node.up;
elseif isa(varargin{1},'explorer.Workspace')
    this.CurrentProject = [];
    this.CurrentWorkspace = node;
else
    % Walk up the tree until we find a project
    while ~isempty(node)
        if (isa(node,'explorer.Project'))
            this.CurrentProject = node;
            this.CurrentWorkspace = node.up;
            break
        end
        node = node.up;
    end
end

% Create the dialog
dialog = javaObjectEDT( 'com.mathworks.toolbox.control.dialogs.NewTaskDialog', FRAME );
this.Dialog = dialog;
h = handle(dialog, 'callbackproperties');
set(h, 'WindowClosingCallback', {@LocalWindowClosing,this});

% Get the handles to the Java objects and configure them
% TaskTypeCombo
jhand.TaskTypeCombo = dialog.getTaskTypeCombo;
jhand.TaskTypeCombo.setModel( LocalGetValidTasks(this) );

% ProjectSelectionCombo
jhand.ProjectSelectionCombo = dialog.getProjectSelectionCombo;
[ProjectComboObject,projind] = LocalGetProjectList(this);
jhand.ProjectSelectionCombo.setModel(ProjectComboObject)
jhand.ProjectSelectionCombo.setSelectedIndex(projind);

% OKButton
jhand.OKButton = dialog.getOKButton;
h = handle( jhand.OKButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalOKButtonCallback,this};

% CancelButton
jhand.CancelButton = dialog.getCancelButton;
h = handle( jhand.CancelButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalCancelButtonCallback,this};

% Store the appropriate handles
this.JavaHandles = jhand;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGetTaskConfig
function TaskConfig = LocalGetTaskConfig(~)
TaskConfig = {};
% If Simulink Control Designer exists add it to the list
if license('test','simulink_control_design') && ~isempty(ver('slcontrol'))
    TaskConfig(end+1,:) = {'Slcontrol:linearizationtask:CETMNewTaskLinearizeModel', ...
        'linearization_simulink'};
    TaskConfig(end+1,:) = {'Slcontrol:controldesign:CETMNewTaskCompDesign', ...
        'compensator_design_simulink'};
end

% If Simulink Parameter Estimator exists add the project types to the list
if license('test','simulink_design_optim') && ~isempty(ver('sldo'))
    TaskConfig(end+1,:) = {'SPE:dialogs:CETMNewTaskParameterEstimation', ...
        'estim_simulink'};
end

% If MPC GUI exists add the project types to the list
if license('test','mpc_toolbox') && ~isempty(ver('mpc'))
    TaskConfig(end+1,:) = {'MPC:designtool:CETMNewTaskMPCController', ...
        'MPC_simulink'};
    TaskConfig(end+1,:) = {'MPC:designtool:CETMNewTaskMultipleMPCControllers', ...
        'MultipleMPC_simulink'};
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGetValidTasks
function ComboBoxObject = LocalGetValidTasks(this)
% Create an empty default list model
ComboBoxObject = javax.swing.DefaultComboBoxModel;
for k = 1:size(this.TaskConfig,1)
    ComboBoxObject.addElement( ctrlMsgUtils.message(this.TaskConfig{k,1}) );
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOKButtonCallback
function LocalOKButtonCallback(~,~,this)
% Get the task type
idx = this.JavaHandles.TaskTypeCombo.getSelectedIndex + 1;
if idx > 0
    % Prototype fcn('flag',model,project)
    typekey = this.TaskConfig{idx,2};
    switch typekey
        case 'linearization_simulink'
            fcnhndl = {@simcontdesigner,'initialize_linearize',[],[],true};
        case 'compensator_design_simulink'
            fcnhndl = {@simcontdesigner,'initialize_controller_design',[],[],true};
        case 'estim_simulink'
            fcnhndl = {@slparamestim,'initialize', [], []};
        case 'MPC_simulink'
            fcnhndl = {@mpc_mask,'open_by_cetm','',''};
        case 'MultipleMPC_simulink'
            fcnhndl = {@mpc_mask_multiple,'open_by_cetm','',''};
    end
    
    if this.CreateNewProject
        % Create the new task dialog and let it handle the rest
        newdlg = explorer.NewProjectDialog(this.CurrentWorkspace,typekey);
        javaMethodEDT('setVisible',newdlg.Dialog,true);
    else
        % Block the explorer while the dialog is being created
        FRAME = slctrlexplorer;
        FRAME.setBlocked(true,[]);
        project = this.Projects(this.JavaHandles.ProjectSelectionCombo.getSelectedIndex + 1);
        % Set the model name
        fcnhndl{3} = project.model;
        % Set the selected project
        fcnhndl{4} = project;
        
        % Evaluate the task creation function
        try
            feval( fcnhndl{:} );
        catch Ex
            util  = slcontrol.Utilities;
            str = sprintf('%s cannot be created due to the error: \n%s', ...
                ctrlMsgUtils.message(this.TaskConfig{idx,1}), ...
                util.getLastError(Ex));
            h = errordlg(str, sprintf('New Task Error'), 'modal');
            % In case the dialog is closed before uiwait blocks MATLAB.
            if ishandle(h)
                uiwait(h)
            end
            % Unblock the explorer
            FRAME.setBlocked(false,[]);
        end
    end
end
% Close the dialog and unblock the explorer
LocalCancelButtonCallback([],[],this)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalGetProjectList
function [ComboBoxObject,ind] = LocalGetProjectList(this)
% Create an empty default list model
ComboBoxObject = javax.swing.DefaultComboBoxModel;

% If Simulink Control Designer exists add it to the list
if isa(this.CurrentProject,'explorer.Project')
    Workspace = this.CurrentProject.up;
    
    % Find non-MPC projects
    this.Projects = setdiff(Workspace.getChildren, ...
        [Workspace.find('-class','mpcnodes.MPCGUI','-depth',1);...
        Workspace.find('-class','controlnodes.SISODesignTask','-depth',1)]);
    for ct = 1:length(this.Projects)
        ComboBoxObject.addElement(this.Projects(ct).Label);
    end
    % Find the project index
    ind = find(this.CurrentProject == this.Projects) - 1;
    if length(ind) ~= 1
        ctrlMsgUtils.error( 'SLControllib:explorer:IncorrectNumberOfProjects' );
    end
else
    % Find non-MPC projects
    theseChildren = setdiff(this.CurrentWorkspace.getChildren, ...
        [this.CurrentWorkspace.find('-class','mpcnodes.MPCGUI','-depth',1);...
        this.CurrentWorkspace.find('-class','controlnodes.SISODesignTask','-depth',1)]);
    if isempty(theseChildren)
        this.Projects = theseChildren;
        for ct = 1:length(this.Projects)
            ComboBoxObject.addElement(this.Projects(ct).Label);
        end
    else
        ComboBoxObject.addElement(ctrlMsgUtils.message( 'SLControllib:explorer:ANewProjectCreated' ));
        this.CreateNewProject = true;
    end
    % Set the project index = 0
    ind = 0;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCancelButtonCallback - Close the dialog
function LocalCancelButtonCallback(~,~,this)
% Unblock the explorer
FRAME = slctrlexplorer;
FRAME.setBlocked(false,[]);
delete(this(ishandle(this)))

% ----------------------------------------------------------------------------
function LocalWindowClosing(~,~,this)
LocalCancelButtonCallback([],[],this)
