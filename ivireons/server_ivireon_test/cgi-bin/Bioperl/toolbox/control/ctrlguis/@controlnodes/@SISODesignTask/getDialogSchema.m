function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/12/04 22:21:52 $


%% Create the main button panel
DialogPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
DialogPanel.setLayout(java.awt.BorderLayout);

%% Create the display scrollpane
TaskPanel = this.sisodb.getTaskPanel;
DialogPanel.add(TaskPanel,java.awt.BorderLayout.CENTER);

%% Add the delete listener
createDeleteListener(this)

%% Create the bottom button panel
ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
ButtonPanel.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.CENTER));

StoreDesignButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Store Design'));
StoreDesignButton.setName('StoreDesignButton');
h = handle(StoreDesignButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalStoreDesignButtonClicked,this};

ShowArchButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Show Architecture'));
ShowArchButton.setName('ShowArchButton');
h = handle(ShowArchButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalShowDiagram this};

HelpButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Help'));
HelpButton.setName('HelpButton');
h = handle(HelpButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalHelp this};

ButtonPanel.add(ShowArchButton);
ButtonPanel.add(StoreDesignButton);
ButtonPanel.add(HelpButton);

DialogPanel.add(ButtonPanel,java.awt.BorderLayout.SOUTH);

%% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged, this}));

%% Store the handles
this.Handles.TaskPanel = TaskPanel;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStoreDesignButtonClicked(es,ed,this)

%% Get the folder to store the design
folder = this.getSnapshotFolder;

%% Store the design
folder.storeSnapshot;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowDiagram(es,ed,this)
% Show architecture diagram
this.sisodb.DesignTask.showDiagram;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHelp(es,ed,this)
% Display help
this.sisodb.DesignTask.showPanelHelp;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLabelChanged(es,ed,this)

this.sisodb.LoopData.Name = ed.NewValue;