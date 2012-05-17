function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2008/12/04 23:26:47 $

% Create the main button panel
DialogPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
BorderLayout = javaObjectEDT('java.awt.BorderLayout');
DialogPanel.setLayout(BorderLayout);

% Create the display scrollpane
SummaryArea = javaObjectEDT('com.mathworks.toolbox.control.explorer.HTMLStatusArea');
DialogPanel.add(SummaryArea,BorderLayout.CENTER);

% Create the bottom button panel
ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
FlowLayout = javaObjectEDT('java.awt.FlowLayout');
FlowLayout.setAlignment(FlowLayout.CENTER)
ButtonPanel.setLayout(FlowLayout);

WriteToSimulinkButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
                                xlate('Update Simulink Block Parameters'));
WriteToSimulinkButton.setName('WriteToSimulinkButton');
h = handle(WriteToSimulinkButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalWriteToSimulinkButtonClicked,this};

ButtonPanel.add(WriteToSimulinkButton);
DialogPanel.add(ButtonPanel,java.awt.BorderLayout.SOUTH);

RetrieveDesignButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
                            xlate('Retrieve Design'));
RetrieveDesignButton.setName('RetrieveDesignButton');
h = handle(RetrieveDesignButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalRetrieveDesignButtonClicked,this};

ButtonPanel.add(RetrieveDesignButton);

% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged,this}));
                    
% Store the handles
this.Handles.SummaryArea = SummaryArea;

% Update the summary
this.updateSummary;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLabelChanged(es,ed,this)

% Need to update the name in the history first.
ch = this.up.getChildren;
ind = find(ch == this);
task = getSISOTaskNode(this);
sisodb = task.sisodb;
sisodb.LoopData.History(ind).Name = this.Label;

% Update the summary with the new name
this.updateSummary;

% Throw an event to the design history folder that the node label changed
eventData = ctrluis.dataevent(this.up,'DesignLabelChanged',ind);
send(this.up, 'DesignLabelChanged', eventData);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWriteToSimulinkButtonClicked(es,ed,this)

% Get the design object
task = getSISOTaskNode(this);
sisodb = task.sisodb;
ind = strcmp(get(sisodb.LoopData.History,{'Name'}),this.Label);
Design = sisodb.LoopData.History(ind);

% Loop over each of the tuned blocks
Tuned = Design.Tuned;
C = handle(NaN(size(Tuned)));
for ct = 1:numel(Tuned)
    C(ct) = Design.(Tuned{ct});
end

% Update the parameters
try
    updateBlockParameters(linutil,C,task.TaskOptions)
catch Ex
    msg = ltipack.utStripErrorHeader(Ex.message);
    GenericLinearizationNodes.showExplorerMsgDlg(msg);
    return
end
% Put up a dialog notifying the user that the update has been completed.
msg = sprintf('The tuned blocks in the Simulink model %s have been updated.',bdroot(C(1).Name));
GenericLinearizationNodes.showExplorerMsgDlg(msg);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRetrieveDesignButtonClicked(es,ed,this)

% Get the design object
task = getSISOTaskNode(this);
sisodb = task.sisodb;
ind = strcmp(get(sisodb.LoopData.History,{'Name'}),this.Label);
Design = sisodb.LoopData.History(ind);

% Import the data
importdesign(sisodb.LoopData,Design);
