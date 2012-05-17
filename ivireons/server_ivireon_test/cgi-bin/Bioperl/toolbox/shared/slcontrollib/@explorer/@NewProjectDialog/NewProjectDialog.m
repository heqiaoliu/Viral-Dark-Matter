function this = NewProjectDialog(workspace,varargin)
% NEWPROJECTDIALOG
%
% PROJECTDIALOG = NEWPROJECTDIALOG(WORKSPACE) Create and configure the new
% project dialog.  WORKSPACE is the handle to the Control and Estimation Tools
% Manager root workspace.
%
% PROJECTDIALOG = NEWPROJECTDIALOG(WORKSPACE, TASK) Create and configure the new
% project dialog and checks the task specified by the variable TASK.

% Author(s): John Glass
% Revised: Bora Eryilmaz
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.23.2.1 $ $Date: 2010/07/23 15:43:01 $

% Create the object
this = explorer.NewProjectDialog;
this.TaskConfig = LocalGetTaskConfig(this);% Gather all available task name IDs

if (nargin == 1)
    this.Workspace = workspace;
    this.Task = [];
else
    this.Workspace = workspace;
    this.Task = varargin{1};
end

% Block the explorer while the dialog is being created
FRAME = slctrlexplorer;
FRAME.setBlocked(true,[]);

% Create the dialog
dialog = javaObjectEDT('com.mathworks.toolbox.control.dialogs.NewProjectDialog', FRAME );
this.Dialog = dialog;
h = handle(dialog, 'callbackproperties');
set(h, 'WindowClosingCallback', {@LocalWindowClosing,this});

% Get the handles to the Java objects and configure them
% ProjectNameTextField
jhand.ProjectNameTextField = dialog.getProjectNameTextField;

% ModelList
jhand.ModelList = dialog.getModelList;
% Populate the model list
this.getLoadedModels;

% New Task Table Model
jhand.TaskTableModel = dialog.getTaskTableModel;
% Populated the table model
table_data = LocalGetValidTasks(this);
if ~isempty(table_data)
    jhand.TaskTableModel.data = table_data;
end

% OKButton
jhand.OKButton = dialog.getOKButton;
h = handle( jhand.OKButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalOKButtonCallback,this};

% CancelButton
jhand.CancelButton = dialog.getCancelButton;
h = handle( jhand.CancelButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalCancelButtonCallback,this};

% Store the JAVA handles
this.JavaHandles = jhand;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions

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
function table_data = LocalGetValidTasks(this)
TaskConfig = this.TaskConfig;
if ~isempty(TaskConfig)
    table_data = javaArray('java.lang.Object', size(TaskConfig,1), 2);
    for ct = 1:size(TaskConfig,1)
        table_data(ct,1) = java.lang.String( ctrlMsgUtils.message( TaskConfig{ct,1} ) );
        table_data(ct,2) = java.lang.Boolean( strcmp(TaskConfig{ct,2}, this.Task) );
    end
else
    table_data = {};
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOKButtonCallback
function LocalOKButtonCallback(~,~,this)

data = this.JavaHandles.TaskTableModel.data;
% Check to see that any of the tasks have been selected
nselected = cell(data);
nselected = sum([nselected{:,2}]);

% Get the selected model
model = this.JavaHandles.ModelList.getSelectedValue;

if ~isempty(model) && nselected
    % Dispose of the dialog
    javaMethodEDT('dispose',this.Dialog)
    
    % Block the explorer while the dialog is being created
    FRAME = slctrlexplorer;
    FRAME.setBlocked(true,[]);
    % Open the model
    open_system(model);
    % Get model name since the model may have been specified using a file
    % path.
    model = bdroot;
    % Create a new project
    projectname = char(this.JavaHandles.ProjectNameTextField.getText);
    project = getvalidproject(model,false,projectname);
    
    for ct = 1:size(data,1)
        if data(ct,2)
            % Create selected tasks
            typekey = this.TaskConfig{ct,2};
            switch typekey
                case 'linearization_simulink'
                    fcnhndl = {@simcontdesigner,'initialize_linearize',model,project,false};
                case 'compensator_design_simulink'
                    fcnhndl = {@simcontdesigner,'initialize_controller_design',model,project,false};
                case 'estim_simulink'
                    fcnhndl = {@slparamestim,'initialize', model, project};
                case 'MPC_simulink'
                    fcnhndl = {@mpc_mask, 'open_by_cetm', model, project};
                case 'MultipleMPC_simulink'
                    fcnhndl = {@mpc_mask_multiple, 'open_by_cetm', model, project};
            end
            
            % Evaluate the task creation function
            try
                feval(fcnhndl{:});
            catch Ex
                util  = slcontrol.Utilities;
                str = sprintf('%s cannot be created due to the error: \n%s', ...
                    char(data(ct,1)), util.getLastError(Ex));
                h = errordlg(str, sprintf('New Project Error'), 'modal');
                % In case the dialog is closed before uiwait blocks MATLAB.
                if ishandle(h)
                    uiwait(h)
                end
                % Unblock the explorer
                FRAME.setBlocked(false,[]);
            end
        end
    end
    
    % Connect the project to the Workspace, select and expand it
    this.Workspace.addNode(project);
    FRAME.setSelected(project.getTreeNodeInterface);
    FRAME.expandNode(project.getTreeNodeInterface);
    if ~FRAME.isVisible
        FRAME.setVisible(true)
    end
    % Close the dialog and unblock the explorer
    LocalCancelButtonCallback([],[],this)
else
    import javax.swing.*;
    JOptionPane.showMessageDialog(this.Dialog, ...
        sprintf('Please select a model and a task for the new project.'), ...
        sprintf('Control and Estimation Tools Manager'), ...
        JOptionPane.ERROR_MESSAGE);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCancelButtonCallback - Close the dialog
function LocalCancelButtonCallback(~,~,this)
% Dispose of the dialog
this.Dialog.dispose;
% Unblock the explorer
FRAME = slctrlexplorer;
FRAME.setBlocked(false,[]);
delete(this(ishandle(this)));

% ----------------------------------------------------------------------------
function LocalWindowClosing(~,~,this)
LocalCancelButtonCallback([],[],this)
