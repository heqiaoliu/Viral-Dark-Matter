function F = simcontdesigner(varargin)
% SIMCONTDESIGNER - Function used as a gateway to launch the simulink
% control design GUI.

%  Author(s): John Glass
%   Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.34 $  $Date: 2008/12/04 23:26:39 $

% Switch yard for GUI interaction with Simulink
% Get the simulink model name
    if isa(varargin{2},'char')
        model = varargin{2};
    else
        model = get_param(varargin{2},'Name');
    end

CETM = true;
switch varargin{1}
    case 'initialize_linearize'        
        if CETM
            LocalLinearizationTask(model,varargin{:});
        else
            LocalCEDLinearizationTask(model,varargin{:});
        end
    case 'initialize_controller_design'
        LocalCompensatorDesignTask(model,varargin{:});
    case 'linearizeblock'
        LocalLinearizeBlockTask(model,varargin{:});
    case 'updateio'
        if CETM
            LocalUpdateIOCETM(model);
        else
        ph = get_param(gcs,'CurrentOutputPort');
            if ~isempty(ph)
        LocalUpdateIO(model,ph);
            end
        end
    case 'updateio_porthandle'
        ph = varargin{3};
        LocalUpdateIO(model,ph);
    case 'updatetrim'
        ph = get_param(gcs,'CurrentOutputPort');
        LocalUpdateOutputConstraint(model,ph)
end

% Return the handle to the explorer
F = slctrlexplorer;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [project,FRAME,selecttask,showexplorer] = LocalGetProject(model,varargin)

% Get the handle to the project
if ((nargin > 3) && isa(varargin{3},'explorer.Project'))
    project = varargin{3};
    FRAME = slctrlexplorer;
    OperatingConditions.addoptask(model,project);
    selecttask = varargin{4};
    showexplorer = false;
else
    [project, FRAME] = getvalidproject(model,true);
    selecttask = true;
    showexplorer = true;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLinearizationTask(model,varargin)

% Get the handle to the project
try
    [project,FRAME,selecttask,showexplorer] = LocalGetProject(model,varargin{:});
catch Ex2
    msg = ltipack.utStripErrorHeader(Ex2.message);
    msgstr = ctrlMsgUtils.message('Slcontrol:linutil:ModelCouldNotBeAnalyzed',model,msg);
    errordlg(msgstr,'Simulink Control Design');
    return
end

% Create the waitbar
wb = waitbar(0,sprintf('Please Wait, Opening linearization task'),'Name',...
    sprintf('Control and Estimation Tools Manager'));

% Update the waitbar
waitbar(0.25,wb,sprintf('Gathering information from: %s',model));

% Get the default nodes
SettingsNode = ModelLinearizationNodes.ModelLinearizationSettings(model);

% Update the waitbar
waitbar(0.75,wb,sprintf('Rendering the linearization task'))

% Add it to the Workspace first a unique label
SettingsNode.Label = SettingsNode.createDefaultName(SettingsNode.Label, project);
project.addNode(SettingsNode);

% Update and close the waitbar
waitbar(1,wb);
close(wb)

% Set the project dirty flag
project.Dirty = 1;

if selecttask
    FRAME.setSelected(SettingsNode.getTreeNodeInterface);
    % Show the explorer frame
    if showexplorer
        javaMethodEDT('show',FRAME)
    end
end

% Search for linearization point blocks
outpoints = find_system(model,'ReferenceBlock','slctrlobsolete/Output Point');
inpoints = find_system(model,'ReferenceBlock','slctrlobsolete/Input Point');

if ~isempty(outpoints) || ~isempty(inpoints)
    warnstr = ctrlMsgUtils.message('Slcontrol:linearizationtask:LinearizationIOBlocksNotSupported',model);
    warndlg(warnstr,sprintf('Simulink Control Design'),'modal');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCEDLinearizationTask(model,varargin)

% Get the current set of linearization IO
io = getlinio(model);

% Create the TaskLog and TaskManager objects
tasklog = LinAnalysisTask.TaskLog;
tasksnapshot = LinAnalysisTask.TaskSnapshot(model,io);
tasklog.setCurrentSnapshot(tasksnapshot);
taskmanager = tasklog.createTaskManager;

% Create the node object
node = LinAnalysisNodes.TaskNode(taskmanager);

% Create the desktop manager
desktopmanager = controldesktop.DesktopManager;
desktopmanager.addNode(node, desktopmanager.getSession)
setSelectedNode(desktopmanager,node)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCompensatorDesignTask(model,varargin)

% Get the handle to the project
try
    [project,FRAME,selecttask,showexplorer] = LocalGetProject(model,varargin{:});
catch Ex2
    msg = ltipack.utStripErrorHeader(Ex2.message);
    msgstr = ctrlMsgUtils.message('Slcontrol:linutil:ModelCouldNotBeAnalyzed',model,msg);
    errordlg(msgstr,'Simulink Control Design');
    return
end

% Create the waitbar
wb = waitbar(0,sprintf('Please Wait, Opening Simulink compensator design task'),'Name',...
    sprintf('Control and Estimation Tools Manager'));

% Update the waitbar
waitbar(0.25,wb,sprintf('Gathering information from: %s',model));

% Get the default nodes
try
    SettingsNode = ControlDesignNodes.SimulinkControlDesignTask(model);
catch Ex2
    msg = ltipack.utStripErrorHeader(Ex2.message);
    msgstr = ctrlMsgUtils.message('Slcontrol:linutil:ModelCouldNotBeAnalyzed',model,msg);
    close(wb)
    errordlg(msgstr,'Simulink Control Design');
    return
end

% Set the project dirty flag
project.Dirty = 1;

% Update the waitbar
waitbar(0.75,wb,sprintf('Rendering the Simulink compensator design task'))

% Add it to the Workspace first a unique label
SettingsNode.Label = SettingsNode.createDefaultName(SettingsNode.Label, project);
project.addNode(SettingsNode);
if selecttask
FRAME.setSelected(SettingsNode.getTreeNodeInterface);
    % Show the explorer frame
    if showexplorer
        javaMethodEDT('show',FRAME)
    end
end

% Update and close the waitbar
waitbar(1,wb);
close(wb)

% Search for linearization point blocks
outpoints = find_system(model,'ReferenceBlock','slctrlobsolete/Output Point');
inpoints = find_system(model,'ReferenceBlock','slctrlobsolete/Input Point');

if ~isempty(outpoints) || ~isempty(inpoints)
    warnstr = ctrlMsgUtils.message('Slcontrol:linearizationtask:LinearizationIOBlocksNotSupported',model);
    warndlg(warnstr,sprintf('Simulink Control Design'),'modal');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLinearizeBlockTask(model,varargin)

try
    [project,FRAME,selecttask,showexplorer] = LocalGetProject(model,varargin{:});
catch Ex2
    msg = ltipack.utStripErrorHeader(Ex2.message);
    msgstr = ctrlMsgUtils.message('Slcontrol:linutil:ModelCouldNotBeAnalyzed',model,msg);
    errordlg(msgstr,'Simulink Control Design');
    return
end

% Create the waitbar
wb = waitbar(0,sprintf('Please Wait, Opening block linearization task'),'Name','Control and Estimation Tools Manager');

% Update the waitbar
waitbar(0.25,wb,sprintf('Gathering information from: %s',model));

% Get the default nodes
SettingsNode = BlockLinearizationNodes.BlockLinearizationSettings(model,getfullname(varargin{3}));

% Update the waitbar
waitbar(0.75,wb,sprintf('Rendering the linearization task'))

% Add it to the Workspace first a unique label
SettingsNode.Label = SettingsNode.createDefaultName(SettingsNode.Label, project);
project.addNode(SettingsNode);

if selecttask
FRAME.setSelected(SettingsNode.getTreeNodeInterface);

    % Expand by default to show the default operating conditions, analysis results and views
FRAME.expandNode(SettingsNode.getTreeNodeInterface);
    % Show the explorer frame
    if showexplorer
        javaMethodEDT('show',FRAME)
    end
end

% Update and close the waitbar
waitbar(1,wb);
close(wb)

% Show the explorer frame
if ~FRAME.isVisible
    FRAME.setVisible(true);
end

% Set the project dirty flag
project.Dirty = 1;

% Show the project, be sure the queue is cleared before bringing the frame
% to the front.
drawnow
javaMethodEDT('toFront',FRAME)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateIOCETM(model)

% Send an event with model that was changed
eventobj = LinAnalysisTask.IODispatch;
eventData = ctrluis.dataevent(eventobj,'ModelIOChanged',...
                                        struct('Model',model));
send(eventobj, 'ModelIOChanged', eventData);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateIO(model,ph)

% Send an event with the block and port that has changed
    block = regexprep(get_param(ph,'Parent'),'\n',' ');
    portnumber = get_param(ph,'PortNumber');
    LinearAnalysisInput = strcmp(get_param(ph,'LinearAnalysisInput'),'on');
    LinearAnalysisOutput = strcmp(get_param(ph,'LinearAnalysisOutput'),'on');
    LinearAnalysisLinearizeOrder = strcmp(get_param(ph,'LinearAnalysisLinearizeOrder'),'on');
    LinearAnalysisOpenLoop = get_param(ph,'LinearAnalysisOpenLoop');

    if LinearAnalysisInput && ~LinearAnalysisOutput
        io = linio(block,portnumber,'in',LinearAnalysisOpenLoop);
    elseif ~LinearAnalysisInput && LinearAnalysisOutput
        io = linio(block,portnumber,'out',LinearAnalysisOpenLoop);
    elseif ~LinearAnalysisInput && ~LinearAnalysisOutput
        io = linio(block,portnumber,'none',LinearAnalysisOpenLoop);
    elseif LinearAnalysisLinearizeOrder
        io = linio(block,portnumber,'outin',LinearAnalysisOpenLoop);
    else
        io = linio(block,portnumber,'inout',LinearAnalysisOpenLoop);
    end
eventobj = LinAnalysisTask.IODispatch;
eventData = ctrluis.dataevent(eventobj,'ModelIOChanged',...
                                        struct('Model',model,'IO',io));
send(eventobj, 'ModelIOChanged', eventData);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateOutputConstraint(model,ph)

%  Get the frame handles
FRAME = slctrlexplorer;

%  Update the IO panel if valid
if (isa(FRAME,'com.mathworks.toolbox.control.explorer.Explorer'))
    SelectedNode = handle(getObject(FRAME.getSelected));
    if isa(SelectedNode,'explorer.Project')
        SelectedRoot = SelectedNode;
    elseif isa(SelectedNode,'explorer.Workspace')
        return
    else
        SelectedRoot = SelectedNode.getRoot.up;
    end
    ProjectChildren = SelectedRoot.getChildren;
    OpCondSpecNode = handle(ProjectChildren(1));
    %% Make sure that we are updating a project with the
    %% same model.  Also, do not do any GUI updates until the node has
    %% been selected for the first time.
    if strcmpi(OpCondSpecNode.Model,model)
        %% Get the operating conditions node for the project
        opspec = OpCondSpecNode.OpSpecData;
        if strcmp(get_param(ph,'LinearAnalysisTrim'),'on')
            OpCondSpecNode.OpSpecData = addoutputspec(opspec,get_param(ph,'Parent'),get_param(ph,'PortNumber'));
        else
            removeOutputSpec(opspec,get_param(ph,'Parent'),get_param(ph,'PortNumber'));
        end
        if ~isempty(OpCondSpecNode.Dialog)
            [OpCondSpecNode.OutputSpecTableData,OpCondSpecNode.OutputIndices] = OpCondSpecNode.getOutputConstrTableData;
            refreshOutputConstrTable(OpCondSpecNode);
        end
    end
end