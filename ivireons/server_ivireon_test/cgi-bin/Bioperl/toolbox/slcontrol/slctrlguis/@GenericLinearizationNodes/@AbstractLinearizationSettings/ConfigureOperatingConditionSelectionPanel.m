function ConfigureOperatingConditionSelectionPanel(this,DialogPanel)
% ConfigureOperatingConditionSelectionPanel

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2006/12/27 21:31:03 $

this.Handles.OpCondSelectionPanel = OperatingConditions.OperatingConditionSelectionPanel(...
                                    DialogPanel.getOpCondSelectPanel.getOpCondSelectPanel,...
                                    this.getOpCondNode);
                                
h = handle(DialogPanel.OpCondPanel.getNewOperatingPointButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalCreateConditionCallback,this};

h = handle(DialogPanel.OpCondPanel.getEditOperatingPointButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalEditOperatingPointCallback,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCreateConditionCallback - Callback to select the operating
%  conditions creation node
function LocalCreateConditionCallback(es,ed,this)

%% Get the operating conditions node
OperCondNode = this.getOpCondNode;

%% If the dialog panel has not been created then create it
if isempty(OperCondNode.Dialog)
    [Frame,Worspace,Manager] = slctrlexplorer;
    OperCondNode.getDialogInterface(Manager);
end

%% Set the operating condition creation tab as selected
OperCondNode.Dialog.getTabbedPane.setSelectedIndex(1);

%% Select the operating condition node
Frame = slctrlexplorer;
Frame.setSelected(OperCondNode.getTreeNodeInterface);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalViewConditionCallback - Callback to view the selected operating
%  condition.
function LocalEditOperatingPointCallback(es,ed,this)

%% Get the first selected row
idx = this.Handles.OpCondSelectionPanel.Handles.JavaPanel.OpCondTable.getSelectedRow + 1;

%% Get the operating conditions node
OperCondNode = this.getOpCondNode;

%% Get the operating condition children
Children = OperCondNode.getChildren;

%% Set the selected node
Frame = slctrlexplorer;
Frame.setSelected(Children(idx).getTreeNodeInterface);