function LinearizeModel(this)
%% Method to linearize the Simulink model from the linearization GUI.

%  Author(s): John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.32 $ $Date: 2010/04/11 20:41:20 $

% Wrap in a function to trap any errors and turn back on the linearize
% button
LinearizeButton = this.Handles.LinearizeButton;
if LinearizeButton.isSelected
    try
        if strcmp(char(this.Dialog.getOpCondSelectPanel.getOperPointType),'simulation_snapshots')
            LocalLinearizeModel(this)
            edtMethod('setEnabled',LinearizeButton,true);
        else
            edtMethod('setEnabled',LinearizeButton,false);
            LocalLinearizeModel(this)
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
        elseif strcmp(Ex.identifier,'Slcontrol:linearize:NonUniformSampleTimeInLinResultsCommand')
            % Reconstruct the error message from the cause. Cause has the
            % list of sample times in the linearization results.
            msgCore = Ex.cause{1}.message;
            msg = ctrlMsgUtils.message('Slcontrol:linearizationtask:NonUniformSampleTimeInLinResultsGUI',msgCore);            
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
function LocalLinearizeModel(this)

% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

% Clear the status area
ExplorerFrame.clearText;

% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',this.model))
    try
        preloaded = 0;
        load_system(this.model);
    catch Ex
        ctrlMsgUtils.error('Slcontrol:linutil:CouldNotOpenModel',this.model)
    end
else 
    preloaded = 1;
end 

% Get the selected IOs and remove the IOs that are not active
io = this.IOData;
io = io(strcmp(get(io,'Active'),'on'));

% Post text that the model is linearizing
ExplorerFrame.postText(sprintf(' - Linearizing the model: %s.',this.Model))
if isempty(io)
    % Throw a warning that there are no linearization points and that it
    % will use the root level ports for linearization.
    ExplorerFrame.postText(sprintf(' - Linearizing using root level ports for linearization inputs and outputs.'))
else
    iotypes = get(this.IOData, 'Type');
    if ~((any(strcmp(iotypes,'in')) && any(strcmp(iotypes,'out'))) || ...
         (any(strcmp(iotypes,'inout')) || any(strcmp(iotypes,'outin'))))
        ExplorerFrame.postText(sprintf(' - Warning, the resulting linearized model will either have no input or output.'))
     end
end

% Linearize the model
OpTask = getOpCondNode(this);
opt = OpTask.Options;

% Get the operating point type
op_type = char(this.Dialog.getOpCondSelectPanel.getOperPointType);
switch op_type
    case 'selected_operating_points'
        % Get the operating points selected by the user
        op_nodes = this.getSelectedOperatingPoints;
        resultnode = operpoint_linearize(this,io,op_nodes,opt);
    case 'model_initial_condition'
        warnstate = warning('off','SLControllib:opcond:ModelHasNonDoubleRootPortInputDataTypes');
        try
            op = operpoint(this.Model);
            warning(warnstate)
        catch OperatingPointCreationException
            warning(warnstate)
            throw(OperatingPointCreationException)
        end
        op_node = OperatingConditions.LinearizationOperConditionValuePanel(op,sprintf('Model Initial Conditions'));
        resultnode = operpoint_linearize(this,io,op_node,opt);
    case 'simulation_snapshots'
        % Get the snapshot times
        snapshottimes_Str = this.Dialog.getOpCondSelectPanel.getSnapshotTimes;
        resultnode = snapshot_linearize(this,io,snapshottimes_Str,opt);
end
      
% Call getInspectorPanelData since the block handles will become stale
%  if the model is closed
if ~isempty(resultnode.ModelJacobian)
    ExplorerFrame.postText(sprintf(' - Generating linearization inspector and diagnostic information.'))
end

% Update the LTI Viewer if needed
plotresult(this,resultnode);

% Add it to the this node above the views folder
SessionChildren = this.getChildren;
connect(resultnode,SessionChildren(end),'right');

% Send update to tell the user that a node has been added
ExplorerFrame.postText(sprintf(' - A linearization result %s has been added to the current Task.', resultnode.Label))

% Set the dirty flag
this.setDirty

% Clean up
if preloaded == 0
    close_system(this.Model,0);
end
