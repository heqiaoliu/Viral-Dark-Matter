function LinearizeBlock(this)
%Method to linearize the Simulink block/subsystem from the linearixation GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.30 $ $Date: 2008/12/04 23:26:42 $

% Wrap in a function to trap any errors and turn back on the linearize
% button
LinearizeButton = this.Handles.LinearizeButton;
if LinearizeButton.isSelected
    try
        if strcmp(char(this.Dialog.getOpCondSelectPanel.getOperPointType),'simulation_snapshots')
            LocalLinearizeBlock(this)
            edtMethod('setEnabled',LinearizeButton,true);
        else
            edtMethod('setEnabled',LinearizeButton,false);
            LocalLinearizeBlock(this)
            edtMethod('setEnabled',LinearizeButton,true);
        end
    catch Ex
        if ~LinearizeButton.isEnabled
            edtMethod('setEnabled',LinearizeButton,true);
        end
        if strcmp(Ex.identifier,'Slcontrol:linearize:InvalidBlockNameforStateOrder')
            msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:ModelOutofStateOrder',this.Model);
        elseif strcmp(Ex.identifier,'Slcontrol:linutil:ZOHD2CPoleAtZero')
            msg = ctrlMsgUtils.message('Slcontrol:linutil:ZOHD2CPoleAtZeroGUI',this.Model);
        else
            msg = ctrlMsgUtils.message('Slcontrol:linutil:ModelCouldNotBeAnalyzed',this.Model,ltipack.utStripErrorHeader(Ex.message));
        end
        errordlg(msg,xlate('Simulink Control Design'));
    end
    edtMethod('setSelected',LinearizeButton,false)
else
    if strcmp(char(this.Dialog.getOpCondSelectPanel.getOperPointType),'simulation_snapshots')
        % Disable the linearize button until the remaining calculations are
        % completed
        edtMethod('setEnabled',LinearizeButton,false);
        set_param(this.Model,'SimulationCommand','stop');
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalLinearizeModel
function LocalLinearizeBlock(this)

% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

% Clear the status area
ExplorerFrame.clearText;

% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',this.model))
    try
        preloaded = 0;
        load_system(this.model);
    catch
        ctrlMsgUtils.error('Slcontrol:linutil:CouldNotOpenModel',this.model);
    end
else 
    preloaded = 1;
end 

% Throw up a error dialog if full model perturbation is being used
OpTask = getOpCondNode(this);
if strcmp(OpTask.Options.LinearizationAlgorithm,'numericalpert')
    ctrlMsgUtils.error('Slcontrol:linearizationtask:PerturbationNotValidBlockLinearization');
end

% Linearize the block
ExplorerFrame.postText(sprintf(' - Linearizing the block: %s.',regexprep(getfullname(this.Block),'\n',' ')))
block = get_param(this.Block,'object');

% Get the operating point type
opt = OpTask.Options;
op_type = char(this.Dialog.getOpCondSelectPanel.getOperPointType);
switch op_type
    case 'selected_operating_points'
        %% Get the operating points selected by the user
        op_nodes = this.getSelectedOperatingPoints;
        resultnode = operpoint_linearize(this,block,op_nodes,opt);
    case 'model_initial_condition'
        warnstate = warning('off','SLControllib:opcond:ModelHasNonDoubleRootPortInputDataTypes');
        try
            op = operpoint(this.Model);
            warning(warnstate)
        catch ModelInitialConditionException
            warning(warnstate)
            throwAsCaller(ModelInitialConditionException)
        end
        op_node = OperatingConditions.LinearizationOperConditionValuePanel(op,sprintf('Model Initial Conditions'));
        resultnode = operpoint_linearize(this,block,op_node,opt);
    case 'simulation_snapshots'
        %% Get the snapshot times
        snapshottimes_Str = this.Dialog.getOpCondSelectPanel.getSnapshotTimes;
        resultnode = snapshot_linearize(this,block,snapshottimes_Str,opt);
end

% Call getInspectorPanelData since the meaning of the block handles will go away
%  if the model is closed
if ~isempty(resultnode.ModelJacobian)
    ExplorerFrame.postText(sprintf(' - Generating linearization inspector and diagnostic information.'))
    resultnode.getInspectorPanelData(block.getFullName);
end

% Send update to tell the user that a node has been added
ExplorerFrame.postText(sprintf(' - A linearization result %s has been added to the current Task.', resultnode.Label))

% Update the LTI Viewer if needed
plotresult(this,resultnode);

% Add it to the this node above the views folder
SessionChildren = this.getChildren;
connect(resultnode,SessionChildren(end),'right');

% Set the project dirty flag
this.setDirty;

% Clean up
if preloaded == 0
    close_system(this.Model,0);
end
