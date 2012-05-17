function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
%	$Revision: 1.1.6.10 $  $Date: 2008/12/04 23:26:44 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.linearization_task.LinearizationTaskPanel',false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Linearize Block Button
%  Set the action callback for the linearization button and store its
%  handle
this.Handles.LinearizeButton = DialogPanel.getLinearizeButton;
h = handle(this.Handles.LinearizeButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalLinearizeBlockCallback,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the lti plot combobox
DialogPanel.setPlotType(this.LTIPlotType);
h = handle(DialogPanel.getPlotTypeCallback,'callbackproperties');
h.DelayedCallback = {@LocalPlotTypeCallback, this};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the operation condition selection panel
this.ConfigureOperatingConditionSelectionPanel(DialogPanel);  

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure the analysis result summary panel
ConfigureAnalysisResultsPanel(this,DialogPanel)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions 
%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalPlotTypeCallback(es,ed,this)

this.LTIPlotType = char(ed);

%% LocalLinearizeModelCallback - Callback for the linearize button to 
% activate the linearization process.
function LocalLinearizeBlockCallback(es,ed,this)

% Call the linearize model method
this.LinearizeBlock;
