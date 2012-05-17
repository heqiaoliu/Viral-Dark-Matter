function connectState(this)
%CONNECTSTATE Initializes the connection between the block and the UI

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/10/07 14:24:15 $

this.BlockHandle = this.ScopeCLI.ParsedArgs{1};
if length(this.ScopeCLI.ParsedArgs) > 1
    this.RunTimeBlock = this.ScopeCLI.ParsedArgs{2};
end

updateSourceName(this);

% Attach to Simulink model with current state
hRoot = getParentModel(this);
this.State.attachToModel(hRoot,hRoot.SimulationStatus, @(h, ev) this.onStateEventHandler(ev));

if strcmpi('running',hRoot.SimulationStatus)
    mdlStart(this, this.RunTimeBlock);
end

% [EOF]
