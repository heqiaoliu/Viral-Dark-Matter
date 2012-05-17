function DialogPanel = getDialogSchema(this, manager)
%  BUILD  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $ $Date: 2008/12/04 23:27:16 $
%  % Revision % % Date %

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.linearization_task.LinearizationTaskPanel',true);
this.Dialog = DialogPanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Linear Analysis Button
%  Set the action callback for the linearization button and store its
%  handle
this.Handles.LinearizeButton = DialogPanel.getLinearizeButton;
h = handle(this.Handles.LinearizeButton, 'callbackproperties' );
h.ActionPerformedCallback =  {@LocalLinearizeModelCallback this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the operation condition selection panel
ConfigureOperatingConditionSelectionPanel(this,DialogPanel);                           
                                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the analysis result summary panel
ConfigureAnalysisResultsPanel(this,DialogPanel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the lti plot combobox
this.Dialog.setPlotType(this.LTIPlotType);
h = handle(this.Dialog.getPlotTypeCallback,'callbackproperties');
h.DelayedCallback = {@LocalPlotTypeCallback, this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Configure the IO TablePanel
ConfigureIOTablePanel(this,DialogPanel)

% Listener for the linearization algorithm change
opnode = this.getOpCondNode;
linopt = opnode.Options;
this.addListeners(handle.listener(linopt,...
                        linopt.findprop('LinearizationAlgorithm'),...
                        'PropertyPostSet',...
                        @(es,ed)LocalUpdateLinearizationAlgorithm(this,linopt)));
                    
% Toggle the mode specified in the options
LocalUpdateLinearizationAlgorithm(this,linopt)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions 
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalPlotTypeCallback(es,ed,this)

this.LTIPlotType = char(ed);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalLinearizeModelCallback - Callback for the linearize button to 
%  activate the linearization process.
function LocalLinearizeModelCallback(es,ed,this)

% Call the linearize model method
this.LinearizeModel;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateLinearizationAlgorithm(this,linopt)

% Use Model Perturbation disable for block linearization
if strcmp(linopt.LinearizationAlgorithm,'numericalpert');
    if this.Handles.RefreshSignalButton.isEnabled
        toggleLinearizationMode(this,'numericalpert')
    end
else
    if ~this.Handles.RefreshSignalButton.isEnabled
        toggleLinearizationMode(this,'blockbyblock')
    end
end
