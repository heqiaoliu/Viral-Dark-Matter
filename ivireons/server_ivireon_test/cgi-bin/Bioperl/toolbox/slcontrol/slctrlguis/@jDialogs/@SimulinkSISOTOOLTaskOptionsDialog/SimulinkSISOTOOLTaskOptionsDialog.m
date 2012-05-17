function hout = SimulinkSISOTOOLTaskOptionsDialog(TaskNode)
%  SimulinkSISOTOOLTaskOptionsDialog Constructor for @SimulinkSISOTOOLTaskOptionsDialog class
%
%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/12/04 23:28:01 $

% mlock
persistent this
    
if isempty(this)
    % Create class instance
    this = jDialogs.SimulinkSISOTOOLTaskOptionsDialog;
    LocalConfigureDialog(this);
end

% Store the linearization node
this.TaskNode = TaskNode;

% Update the GUI with the new data from the linearization task
LocalUpdateDialog(this)
hout = this;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateDialog - Update the dialog with the new node data
function LocalUpdateDialog(this)

% Get the options for the task.
OptionsStruct = this.TaskNode.TaskOptions;

% Get the handle to the Java object handles
jhand = this.JavaHandles;

% Use Full Precision
javaMethodEDT('setSelected',jhand.UseFullPrecisionCheckbox,OptionsStruct.UseFullPrecision);

% Custom Precision
javaMethodEDT('setText',jhand.CustomPrecisionEditField,OptionsStruct.CustomPrecision);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalConfigureDialog - Configure the dialog for the first time
function LocalConfigureDialog(this)

% Create the dialog panel
Frame = slctrlexplorer;
Dialog = javaObjectEDT('com.mathworks.toolbox.slcontrol.Dialogs.SimulinkSISOTOOLTaskDialog',Frame);
Dialog.setSize(450,400);

% Store the java panel handle
this.JavaPanel = Dialog;

% Configure the panel
jhand.HelpButton = Dialog.getHelpButton;
h = handle(jhand.HelpButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHelpButtonCallback, this};
jhand.OKButton = Dialog.getOKButton;
h = handle(jhand.OKButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalOKButtonCallback, this};
jhand.ApplyButton = Dialog.getApplyButton;
h = handle(jhand.ApplyButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalApplyButtonCallback, this};
jhand.CancelButton = Dialog.getCancelButton;
h = handle(jhand.CancelButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelButtonCallback, this};

% These Java widgets do not need to have callbacks since the data is read
% when the Apply and OK buttons are presed
jhand.CustomPrecisionEditField = Dialog.getCustomPrecisionEditField;
jhand.UseFullPrecisionCheckbox = Dialog.getUseFullPrecisionCheckbox;
     
% Store the java handles
this.JavaHandles = jhand;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHelpButtonCallback - Evaluate the help button callback
function LocalHelpButtonCallback(es,ed,this)

% Launch the help browser
scdguihelp('linearization_panel',this.JavaPanel)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOKButtonCallback - Evaluate the OK button callback
function LocalOKButtonCallback(es,ed,this)

% Call the apply callback
error = LocalApplyButtonCallback([],[],this);

% Dispose of the dialog
if ~error 
    javaMethodEDT('dispose',this.JavaPanel);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalApplyButtonCallback - Evaluate the apply button callback
function error = LocalApplyButtonCallback(es,ed,this)

% Initialize the error flag
error = false;

% Get the options for the task.
OptionsStruct = this.TaskNode.TaskOptions;

% Get the Java handles
jhand = this.JavaHandles;

% N Digits of Precision
OptionsStruct.UseFullPrecision = jhand.UseFullPrecisionCheckbox.isSelected;

% N Digits of Precision
OptionsStruct.CustomPrecision = char(jhand.CustomPrecisionEditField.getText);

% Set the dirty flag
this.setDirty

% Set the new data
this.TaskNode.TaskOptions = OptionsStruct;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCancelButtonCallback - Evaluate the cancel button callback
function LocalCancelButtonCallback(es,ed,this)

% Dispose of the dialog
javaMethodEDT('dispose',this.JavaPanel);
