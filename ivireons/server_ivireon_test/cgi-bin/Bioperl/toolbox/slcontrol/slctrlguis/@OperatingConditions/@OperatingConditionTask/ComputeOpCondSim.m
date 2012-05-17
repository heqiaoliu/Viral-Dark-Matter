function ComputeOpCondSim(this)
% Method to compute the operating conditions of a Simulink model.

%  Author(s): John Glass
%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $ $Date: 2010/04/30 00:43:59 $

% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

% Clear the status area
ExplorerFrame.clearText;

% Get the settings node and its dialog interface
di = this.Handles.OpCondSpecPanel;
SnapShotTimes_str = char(di.SimLinearizationPanel.getSnapshotTimesTextField.getText);

if ~isempty(SnapShotTimes_str)
    SnapShotTimes = str2num(SnapShotTimes_str); %#ok<ST2NM>
    if isempty(SnapShotTimes)
        try
            SnapShotTimes = evalin('base',SnapShotTimes_str);
        catch Ex %#ok<NASGU>
            LocalErrorDialog('Slcontrol:linutil:InvalidSnapshotTimes')
            return
        end
    end
else
    LocalErrorDialog('Slcontrol:linutil:InvalidSnapshotTimes')
    return
end

ExplorerFrame.postText(ctrlMsgUtils.message('Slcontrol:operpointtask:ComputingSnapshotStatus'))

% Compute operating conditions at snapshot times
try
    % Create the model parameter manager
    ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(this.Model);
    ModelParameterMgr.loadModels;
    oppoint = runsnapshot(LinearizationObjects.OperPointSnapShotEvent(ModelParameterMgr,SnapShotTimes));
    OperatingConditionSummary = cell(length(oppoint),1);
    for ct = 1:length(oppoint)
        OperatingConditionSummary{ct} = ctrlMsgUtils.message('Slcontrol:linutil:OperatingPointTimeNote',mat2str(oppoint(ct).Time));
    end
catch Ex
    ModelParameterMgr.closeModels
    LocalErrorDialog('Slcontrol:operpointtask:OperatingPointSearchGenericError',ltipack.utStripErrorHeader(Ex.message))
    return
end

% Create the linearization settings object
for ct = 1:length(oppoint)
    % Create the operating conditions result node
    children = this.getChildren;
    nchars = length(OperatingConditionSummary{ct});
    matches = sum(strncmp(get(children,'Label'),OperatingConditionSummary{ct},nchars));

    if matches
        Label = sprintf('%s(%d)',OperatingConditionSummary{ct},matches);
    else
        Label = OperatingConditionSummary{ct};
    end
    node = OperatingConditions.OperConditionValuePanel(oppoint(ct),Label);
    node.Description = OperatingConditionSummary{ct};

    % Add it to the node
    this.addNode(node);

    % Expand the analysis nodes so the user sees the new result
    ExplorerFrame.expandNode(this.getTreeNodeInterface);

    % Send update to tell the user that a node has been added
    ExplorerFrame.postText(ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointAddedStatus',Label))
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalErrorDialog(msgkey,varargin)

errtitle = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointsComputationErrorTitle');
errordlg(ctrlMsgUtils.message(msgkey,varargin{:}),errtitle);


