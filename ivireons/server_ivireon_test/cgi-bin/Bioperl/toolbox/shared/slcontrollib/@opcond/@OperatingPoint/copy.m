function opcopy = copy(oppoint)

%COPY 
%
%  OPCOPY = COPY(OPPOINT) Creates a copy of an operating spec object.
%

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2008/06/13 15:28:34 $

% Create a copy of the operating condition object
opcopy = opcond.OperatingPoint;
opcopy.Model = oppoint.Model;
opcopy.Time = oppoint.Time;

% Extract the states from the operating condition object
oldstates = oppoint.States;
states = handle(NaN(numel(oldstates),1));
for ct = 1:numel(oldstates)
    % Create a new object
    newstate = opcond.StatePoint;
    
    % Copy information
    newstate.Block       = oldstates(ct).Block;   
    newstate.Nx          = oldstates(ct).Nx;
    newstate.x           = oldstates(ct).x;
    newstate.Description = oldstates(ct).Description;
    newstate.Ts           = oldstates(ct).Ts;
    newstate.StateName   = oldstates(ct).StateName;
    newstate.SampleType   = oldstates(ct).SampleType;
    newstate.inReferencedModel  = oldstates(ct).inReferencedModel;
        
    % Store the new state
    states(ct) = newstate;
end

% Extract the input levels
oldinputs = oppoint.Inputs;
inputs = handle(NaN(numel(oldinputs),1));
for ct = 1:length(oldinputs)
    % Create a new object
    newinput = opcond.InputPoint;
    
    % Copy Information
    newinput.PortDimensions = oldinputs(ct).PortDimensions;
    newinput.PortWidth = oldinputs(ct).PortWidth;
    newinput.u         = oldinputs(ct).u;
    newinput.Block     = oldinputs(ct).Block;
    newinput.Description = oldinputs(ct).Description; 
    
    % Store the new input
    inputs(ct) = newinput;
end

opcopy.States = states;
opcopy.Inputs = inputs;
