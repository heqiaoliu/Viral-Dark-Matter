function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/12/04 22:21:49 $

%% Create the main button panel
DialogPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
DialogPanel.setLayout(java.awt.BorderLayout);

%% Create the display scrollpane
SummaryArea = javaObjectEDT('com.mathworks.toolbox.control.explorer.HTMLStatusArea');
DialogPanel.add(SummaryArea,java.awt.BorderLayout.CENTER);

%% Create the bottom button panel
ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
ButtonPanel.setLayout(java.awt.FlowLayout(java.awt.FlowLayout.CENTER));

RetrieveDesignButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Retrieve Design'));
RetrieveDesignButton.setName('RetrieveDesignButton');
h = handle(RetrieveDesignButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalRetrieveDesignButtonClicked,this};

ButtonPanel.add(RetrieveDesignButton);
DialogPanel.add(ButtonPanel,java.awt.BorderLayout.SOUTH);

%% Store the handles
this.Handles.SummaryArea = SummaryArea;

%% Update the summary
this.updateSummary;

%% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged, this}));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRetrieveDesignButtonClicked(es,ed,this)

%% Get the design object
task = getSISOTaskNode(this);
sisodb = task.sisodb;
ind = find(strcmp(get(sisodb.LoopData.History,{'Name'}),this.Label));
Design = sisodb.LoopData.History(ind);

%% Import the data
importdesign(sisodb.LoopData,Design);

% --------------------------------------------------------------------------- % 
function LocalLabelChanged(es,ed,this)

%% Need to update the name in the history first.
ch = this.up.getChildren;
ind = find(ch == this);
task = getSISOTaskNode(this);
sisodb = task.sisodb;
sisodb.LoopData.History(ind).Name = this.Label;

%% Update the summary with the new name
this.updateSummary;

%% Throw an event to the design history folder that the node label changed 
eventData = ctrluis.dataevent(this.up,'DesignLabelChanged',ind);
send(this.up, 'DesignLabelChanged', eventData);