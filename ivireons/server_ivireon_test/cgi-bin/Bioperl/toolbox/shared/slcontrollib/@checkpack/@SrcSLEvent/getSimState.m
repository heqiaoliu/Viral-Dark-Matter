function SimState =  getSimState(this)
%GETSIMSTATE gets the simulation status of the model.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:02 $

parMdlObj = getParentModel(this);
if isa(parMdlObj,'Simulink.BlockDiagram')
    SimState = get(parMdlObj,'SimulationStatus');
else
    %Block handle hasn't been stored as yet. Return default sim status.
    SimState = 'stopped';
end
end