function DialogPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
%$Revision: 1.1.6.19 $  $Date: 2008/12/04 23:27:31 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.GenericSimulinkSettingsObjects.OperatingConditionsValuePanel');

% Configure the operating point tables
configureTablePanels(this,DialogPanel);

% Add the buttons
DuplicateButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Duplicate Operating Point'));
DuplicateButton.setName('DuplicateButton');
SyncButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Sync with Model'));
SyncButton.setName('SyncButton');
ButtonPanel = javaObjectEDT(DialogPanel.getButtonPanel);
ButtonPanel.add(SyncButton);
ButtonPanel.add(DuplicateButton);
        
% Configure the import initial value for operating point button
h = handle(SyncButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalSyncOpPoint, this};

% Configure the duplicate operating point button
h = handle(DuplicateButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalDuplicateOpPoint, this};

% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged, this}));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL FUNCTIONS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalLabelChanged
function LocalLabelChanged(es,ed,this)
% Get the parent node
parent = this.up;
if isa(parent,'OperatingConditions.OperatingConditionTask');
    send(parent, 'OpPointDataChanged');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSyncOpPoint
function LocalSyncOpPoint(es,ed,this)

% Update the operating point data    
try
    this.OpPoint.update;
catch Ex
    lastmsg = ltipack.utStripErrorHeader(Ex.message); 
    str = sprintf(['The operating point could not be could '...
        'not be synchronized with the model %s due to the following error:\n\n',...
        '%s'],this.Model,lastmsg);
    errordlg(str,'Operating Points Synchronization Error')
    return
end

% Get the state and input table data
[this.StateTableData,this.StateIndices] = this.getStateTableData;
[this.InputTableData,this.InputIndices] = this.getInputTableData;
refreshTables(this)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDuplicateOpPoint
function LocalDuplicateOpPoint(es,ed,this)

% Create the new operating point 
optask = this.getRoot;
Label = optask.createDefaultName(this.Label, optask);
newpoint = OperatingConditions.OperConditionValuePanel(this.OpPoint,Label);

% Connect it to the explorer
addNode(optask,newpoint);
