function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2010/02/17 19:07:54 $

% Create the main button panel
DialogPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
BorderLayout = javaObjectEDT('java.awt.BorderLayout',5,5);
DialogPanel.setLayout(java.awt.BorderLayout);

% Create the display scrollpane
TaskPanel = this.sisodb.getTaskPanel;
DialogPanel.add(TaskPanel,BorderLayout.CENTER);

% Create the bottom button panel
ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
FlowLayout = javaObjectEDT('java.awt.FlowLayout');
FlowLayout.setAlignment(FlowLayout.CENTER)
ButtonPanel.setLayout(FlowLayout);

StoreDesignButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
                            xlate('Store Design'));
StoreDesignButton.setName('StoreDesignButton');
h = handle(StoreDesignButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalStoreDesignButtonClicked,this};

WriteDesignButton = javaObjectEDT('com.mathworks.mwswing.MJButton',...
                    xlate('Update Simulink Block Parameters'));
WriteDesignButton.setName('WriteDesignButton');
h = handle(WriteDesignButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalWriteDesignButtonClicked,this};

AutoUpdateCheckBox = javaObjectEDT('com.mathworks.mwswing.MJCheckBox',...
                    xlate('Automatically update block parameters'));
if strcmp(this.AutoUpdateEnabled,'on')
    AutoUpdateCheckBox.setSelected(1);
end
AutoUpdateCheckBox.setName('AutoUpdateCheckBox');
h = handle(AutoUpdateCheckBox, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalAutoUpdateCheckBoxClicked,this};

HelpButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Help'));
HelpButton.setName('HelpButton');
h = handle(HelpButton, 'callbackproperties' );
h.ActionPerformedCallback  = {@LocalHelp this};

ButtonPanel.add(StoreDesignButton);
ButtonPanel.add(WriteDesignButton);
ButtonPanel.add(AutoUpdateCheckBox);
ButtonPanel.add(HelpButton);
DialogPanel.add(ButtonPanel,java.awt.BorderLayout.SOUTH);

% Create the delete listener
createDefaultListeners(this);

% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged, this}));
                    
% Store the handles
this.Handles.TaskPanel = TaskPanel;
this.Handles.AutoUpdateCheckBox = AutoUpdateCheckBox;
this.Handles.WriteDesignButton = WriteDesignButton;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStoreDesignButtonClicked(es,ed,this)

% Get the folder to store the design
folder = this.getSnapshotFolder;

% Store the design
folder.storeSnapshot;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWriteDesignButtonClicked(es,ed,this)

% Update the parameters
try
    WriteToSimulinkModel(this) 
catch Ex
    errordlg(ltipack.utStripErrorHeader(Ex.message),'Simulink Control Design');
    return
end
% Put up a dialog notifying the user that the update has been completed.
msg = sprintf('The tuned blocks in the Simulink model %s have been updated.',this.getModel);
GenericLinearizationNodes.showExplorerMsgDlg(msg);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAutoUpdateCheckBoxClicked(es,ed,this)

if this.Handles.AutoUpdateCheckBox.isSelected
    % Enable the listener
    setAutoUpdateListenerEnabled(this,'on')
    % Update the design
    try
        WriteToSimulinkModel(this)
    catch Ex
        errordlg(ltipack.utStripErrorHeader(Ex.message),'Simulink Control Design');
        return
    end
    % Disable the write to design button
    enablestate = false;
    % Store the state of the checkbox
    this.AutoUpdateEnabled = 'on';
else
    setAutoUpdateListenerEnabled(this,'off')
    enablestate = true;
    % Store the state of the checkbox
    this.AutoUpdateEnabled = 'off';
end
this.Handles.WriteDesignButton.setEnabled(enablestate);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHelp(es,ed,this)

% Display help
this.sisodb.DesignTask.showPanelHelp;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalLabelChanged(es,ed,this)

this.sisodb.LoopData.Name = ed.NewValue;
