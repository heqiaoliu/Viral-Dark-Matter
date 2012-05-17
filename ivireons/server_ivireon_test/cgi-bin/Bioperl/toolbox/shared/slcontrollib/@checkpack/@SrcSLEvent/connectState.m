function connectState(this)
%CONNECTSTATE Initializes the connection between the block and the UI

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:50:53 $

% Attach to Simulink model with current state
hRoot = getParentModel(this);
this.State.attachToModel(hRoot,hRoot.SimulationStatus, @(h, ev) this.onStateEventHandler(ev));

if strcmpi('running',hRoot.SimulationStatus)
    mdlStart(this, this.RunTimeBlock);
end
