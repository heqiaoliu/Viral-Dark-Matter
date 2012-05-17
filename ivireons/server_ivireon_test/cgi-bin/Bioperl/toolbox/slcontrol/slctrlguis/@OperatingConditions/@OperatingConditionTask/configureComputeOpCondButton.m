function configureComputeOpCondButton(this)
%  configureComputeOpCondButton  Construct the compute operating condition
%  button

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

%% Set the action callback to compute the operating condition
this.Handles.ComputeOpCondButton = this.Handles.OpCondSpecPanel.getComputeOpCondButton;
h = handle(this.Handles.ComputeOpCondButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalComputeOpCond, this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalComputeOpCond - Callback for computing the operating conditions
function LocalComputeOpCond(es,ed,this)

%% Get the button handle
ComputeOpCondButton = this.Handles.ComputeOpCondButton;

if ComputeOpCondButton.isSelected
    %% Get the handle to the explorer frame
    ExplorerFrame = slctrlexplorer;

    %% Clear the status area
    ExplorerFrame.clearText;
    
    %% Find the mode that the operating conditions panel is in
    if (this.Handles.OpCondSpecPanel.OpCondComputeCombo.getSelectedIndex == 0)
        this.ComputeOpCond;
    else
        this.ComputeOpCondSim;
    end
    
    %% Set the toggle button to be false
    ComputeOpCondButton.toggleButton(false)
    edtMethod('setEnabled',ComputeOpCondButton,true);
else
    if (this.Handles.OpCondSpecPanel.OpCondComputeCombo.getSelectedIndex ~= 0)
        % Disable the linearize button until the remaining calculations are
        % completed
        edtMethod('setEnabled',ComputeOpCondButton,false);
        set_param(this.Model,'SimulationCommand','stop');
    end
end
