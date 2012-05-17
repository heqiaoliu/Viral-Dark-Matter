function DialogPanel = getDialogSchema(this, ~)
%  getDialogSchema  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.22 $ $Date: 2010/02/17 19:07:56 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.ControlDesignDialogPanels.SimulinkControlDesignTask');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ValidElementsTableModel Table Model
%  Set the action callback for the ValidElementsTableModel table model 
%  and store its handle
ValidElementsTableModel = DialogPanel.ControlPanel.getValidBlocksTableModel;

%  Update the table if there is previously stored data
if ~isempty(this.ValidBlocksTableData)
    ValidElementsTableModel.setData(this.ValidBlocksTableData)
end

MATLABValidElementsTableModel = handle(ValidElementsTableModel, 'callbackproperties' );
ValidElementsTableModelListener = handle.listener(MATLABValidElementsTableModel,'tableChanged',...
             {@LocalUpdateValidElementsTableData, this});
this.Handles.ValidElementsTableModel = ValidElementsTableModel;
this.Handles.ValidElementsTableModelListener = ValidElementsTableModelListener;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DesignToolButton
%  Set the action callback for the DesignToolButton and store its handle
DesignToolButton = DialogPanel.getDesignToolButton;
h = handle(DesignToolButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalDesignToolButtonClicked,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AddBlock Button
AddBlockButton = DialogPanel.getAddBlockButton;
h = handle(AddBlockButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalSelectBlocks,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Help Button
HelpButton = DialogPanel.getHelpButton;
h = handle(HelpButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalHelp,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the operation condition selection panel
this.ConfigureOperatingConditionSelectionPanel(DialogPanel);     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the IO TablePanel
this.ConfigureIOTablePanel(DialogPanel)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalHelp
function LocalHelp(~,~,this)

%  Get the tabbed pane
TabbedPane = this.Dialog.getTabbedPane;

switch TabbedPane.getSelectedIndex
    case 0
        scdguihelp('tunable_blocks_dispatch_page');
    case 1
        scdguihelp('closed_loop_signals_dispatch_page');
    case 2
        scdguihelp('operating_point_selections_dispatch_page');
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalUpdateValidElementsTableData
function LocalUpdateValidElementsTableData(~,~,this)

% Update the table data
this.ValidBlocksTableData = cell(this.Handles.ValidElementsTableModel.data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalSelectBlocks
function LocalSelectBlocks(~,~,this)

% Set the explorer glass pane to be on.  This will be turned off when the
%  blocks are selected.
Explorer = slctrlexplorer;
Explorer.setBlocked(true, []);

% Launch the block selection GUI
dlg = jDialogs.SelectBlockDialog(this);
dlg.build(this);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalDesignToolButtonClicked - Start the controller design.
function LocalDesignToolButtonClicked(~,~,this)

% Wrap in a function to trap any errors and turn back on the linearize
% button
DesignToolButton = this.Dialog.getDesignToolButton;
if DesignToolButton.isSelected
    % Create the waitbar
    wtbr = waitbar(0,sprintf('Analyzing the model...'),...
                                'Name',sprintf('Simulink Control Design'));
    try
        if strcmp(char(this.Dialog.getOpCondSelectPanel.getOperPointType),'simulation_snapshots')
            LocalCreateDesign(this,wtbr)
            edtMethod('setEnabled',DesignToolButton,true);
        else
            edtMethod('setEnabled',DesignToolButton,false);
            LocalCreateDesign(this,wtbr)
            edtMethod('setEnabled',DesignToolButton,true);
        end
        close(wtbr);
    catch Ex
        if ~DesignToolButton.isEnabled
            edtMethod('setEnabled',DesignToolButton,true);
        end
        close(wtbr);
        if strcmp(Ex.identifier,'Slcontrol:linutil:ZOHD2CPoleAtZero') ...
            || strcmp(Ex.identifier,'Control:transformation:ZOHConversion1')
            msg = ctrlMsgUtils.message('Slcontrol:linutil:ZOHD2CPoleAtZeroGUI',this.Model);
        else
            errormsg = ltipack.utStripErrorHeader(Ex.message);
            msg = ctrlMsgUtils.message('Slcontrol:linutil:ModelCouldNotBeAnalyzed',this.Model,errormsg);
        end        
        errordlg(msg,xlate('Simulink Control Design'));        
    end
    edtMethod('setSelected',DesignToolButton,false)
else
    if strcmp(char(this.Dialog.getOpCondSelectPanel.getOperPointType),'simulation_snapshots')
        % Disable the design button until the remaining calculations are
        % completed
        edtMethod('setEnabled',DesignToolButton,false);
        set_param(this.Model,'SimulationCommand','stop');
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCreateDesign - Start the controller design.
function LocalCreateDesign(this,wtbr)

% Be sure that the model is open.
ensureOpenModel(slcontrol.Utilities,this.Model)

% Set the explorer glass pane to be on.  This will be turned off when the
% wizard is finished
Explorer = slctrlexplorer;

% Create a SISOConfigNode
Label = ctrlMsgUtils.message('Slcontrol:controldesign:SISODesignTaskLabel');
SISOTaskNode = ControlDesignNodes.SISODesignConfiguration(Label);
SISOTaskNode.SimulinkControlDesignTask = this;

% Get the operating point data and create the default nodes
op_type = char(this.Dialog.getOpCondSelectPanel.getOperPointType);
switch op_type
    case 'selected_operating_points'
        try
            % Get the operating points selected by the user
            op_nodes = this.getSelectedOperatingPoints;
        catch SelectOperatingPointException
            throwAsCaller(SelectOperatingPointException)
        end
        op = getOperPoint(op_nodes);
        SourceOpPointDescription = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointCopyDescription',op_nodes.Label);
    case 'model_initial_condition'
        warnstate = warning('off','SLControllib:opcond:ModelHasNonDoubleRootPortInputDataTypes');
        try
            op = operpoint(this.Model);
            warning(warnstate)
        catch ModelInitialConditionException
            warning(warnstate)
            throwAsCaller(ModelInitialConditionException)
        end
        SourceOpPointDescription = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointCopyDescriptionIC',this.Model);
    case 'simulation_snapshots'
        % Get the snapshot times
        snapshottimes_Str = this.Dialog.getOpCondSelectPanel.getSnapshotTimes;
        if ~isempty(snapshottimes_Str)
            op = str2num(snapshottimes_Str); %#ok<ST2NM>
            if isempty(op)
                try
                    op = evalin('base',snapshottimes_Str);
                catch Ex
                    ctrlMsgUtils.error('Slcontrol:linutil:InvalidSnapshotTimes')
                end
            end
        else
            ctrlMsgUtils.error('Slcontrol:linutil:InvalidSnapshotTimes')
        end
end
waitbar(0.1,wtbr)

% Create a folder node for each design snapshot
folder = controlnodes.DesignSnapshotFolder(sprintf('Design History'));

% Get the blocks the user has selected
ValidBlockStruct = this.ValidBlockStruct;
ValidBlocks = {ValidBlockStruct.block};

% Make sure that the user has selected a block
if isempty(this.ValidBlocksTableData)
    ctrlMsgUtils.error('Slcontrol:controldesign:BlocksNotSelected')
end
checkboxcolumn = this.ValidBlocksTableData(:,1);
indSelected = find([checkboxcolumn{:}] == true);

% Make sure that at least one block is marked as tunable
if isempty(indSelected) 
    ctrlMsgUtils.error('Slcontrol:controldesign:BlocksNotSelected')
end

SelectedBlocks = this.ValidBlocksTableData(indSelected,2);
[~,ia] = intersect(ValidBlocks,SelectedBlocks);
ValidBlockStruct = ValidBlockStruct(ia);
SISOTaskNode.ValidBlockStruct = ValidBlockStruct;

% Store the closed loop io data
ClosedLoopIO = this.IOData;

% Find the active closed loop io
activeio = get(ClosedLoopIO,{'Active'});
ClosedLoopIO = ClosedLoopIO(strcmp(activeio,'on'));

% Make sure that the user has selected closed loop IOs
if isempty(ClosedLoopIO)
    ctrlMsgUtils.error('Slcontrol:controldesign:ClosedLoopIONotSelected')
end

% Make sure that there is at least one input and one output
ClosedLoopIOList = get(ClosedLoopIO,{'Type'});
if ~(any(strcmp(ClosedLoopIOList,'in')) && any(strcmp(ClosedLoopIOList,'out'))) && ...
        ~any(strcmp(ClosedLoopIOList,'inout')) && ~any(strcmp(ClosedLoopIOList,'outin'))
    ctrlMsgUtils.error('Slcontrol:controldesign:ClosedLoopIONotSelected')
end

SISOTaskNode.ClosedLoopIO = ClosedLoopIO;

% Store the task options for later linearizations
SISOTaskNode.SCDTaskOptions = this.OptionsStruct;

% Get the model name
mdl = SISOTaskNode.getModel;

% Get the options for this case
opt = linoptions;
SCDTaskOptions = getSCDTaskOptions(SISOTaskNode);
ts = computeSampleTime(linutil,SCDTaskOptions.SampleTime);
opt.SampleTime = ts;
opt.RateConversionMethod = SCDTaskOptions.RateConversionMethod;
opt.PreWarpFreq = SCDTaskOptions.PreWarpFreq;
if isfield(SCDTaskOptions,'UseExactDelayModel')
    opt.UseExactDelayModel = SCDTaskOptions.UseExactDelayModel;
end
if isfield(SCDTaskOptions,'UseBusSignalLabels')
    opt.UseBusSignalLabels = SCDTaskOptions.UseBusSignalLabels;
end
waitbar(0.2,wtbr)

% Compute the initial loop data.  This will weed out blocks that are not
% in a feedback loop.
% Compute the TunedBlock objects and any linearization points that need to
% be added to virtual ports.
TunedBlocks = utCreateTunedBlocks(linutil,mdl,ValidBlockStruct,opt);

% Create the loopio based on the blocks selected
for ct = numel(TunedBlocks):-1:1
    block = TunedBlocks(ct).Name;
    port = TunedBlocks(ct).AuxData.OutportPort;
    % Create the initial loopio structures
    ph = get_param(block,'PortHandles');
    name = getUniqueSignalName(slcontrol.Utilities,ph.Outport(port));
    % Create the description
    if ~isempty(get_param(ph.Outport(port),'Name'))
        Description = ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopAtSignal',name);
    else
        Description = ctrlMsgUtils.message('Slcontrol:controldesign:OpenLoopAtPort',port,name);
    end
    loopio(ct,1) = struct('FeedbackLoop',linio(block,port,'outin','on'),...
        'LoopOpenings',[],...
        'Name','',...
        'Description',Description);
end

[loopdata, op] = computeloopdata(linutil,mdl,ClosedLoopIO,TunedBlocks,op,opt,loopio);
waitbar(0.8,wtbr)

Explorer.setBlocked(true, []);

if numel(op) > 1
    for ct = numel(op):-1:1
        opstr{ct} = ctrlMsgUtils.message('Slcontrol:linutil:OperatingPointTimeNote',mat2str(op(ct).Time));
    end
    dlg = jDialogs.SelectSingleOperatingPointDialog(slctrlexplorer,opstr);
    % Wait for the selected index
    index = getUserSelectedIndex(dlg);
    if isempty(index)
        Explorer.setBlocked(false, []);
        return
    else
        op = op(index);
        loopdata = loopdata(index);
    end
end

if isempty(loopdata.L)
    msg = ctrlMsgUtils.message('Slcontrol:controldesign:NoFeedbackLoopsDetected',mdl);
    ContinueStr = ctrlMsgUtils.message('Slcontrol:controldesign:ContinueButtonLabel');
    CancelStr = ctrlMsgUtils.message('Slcontrol:controldesign:CancelButtonLabel');
    val = questdlg(msg,'Simulink Control Design',ContinueStr,CancelStr,CancelStr);
    if strcmp(val,CancelStr)
        Explorer.setBlocked(false, []);
        return
    end
end

% Add the nodes to the tree
SISOTaskNode.addNode(folder);

% Create a copy of the operating point node used for the design
switch op_type
    case {'selected_operating_points','model_initial_condition'}
        SISOTaskNode.addNode(OperatingConditions.ControlDesignOperConditionValuePanel(...
            op,ctrlMsgUtils.message('Slcontrol:controldesign:DesignOperatingPointLabel'),...
            SourceOpPointDescription));
    case 'simulation_snapshots'
        SISOTaskNode.addNode(OperatingConditions.ControlDesignOperPointSnapshotPanel(...
            op,ctrlMsgUtils.message('Slcontrol:controldesign:DesignOperatingPointLabel')));
end
waitbar(1,wtbr)

% Create the wizard
jDialogs.ControlConfigurationWizard(SISOTaskNode,loopdata(1));
end
