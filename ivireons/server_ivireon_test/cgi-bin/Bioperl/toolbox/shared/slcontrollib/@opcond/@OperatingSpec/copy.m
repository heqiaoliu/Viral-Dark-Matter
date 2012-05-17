function opcopy = copy(opspec)
%

%COPY 
%
%  OPCOPY = COPY(OPSPEC) Creates a copy of an operating spec object.
%

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/06/13 15:28:36 $

% Create a copy of the operating condition object
opcopy = opcond.OperatingSpec;
opcopy.Model = opspec.Model;
opcopy.Time = opspec.Time;

% Extract the states from the operating condition object
oldstates = opspec.States;
states = [];
for ct = 1:length(oldstates)
    % Create a new object
    newstate = opcond.StateSpec;
    
    % Copy information
    newstate.Block       = oldstates(ct).Block;   
    newstate.StateName   = oldstates(ct).StateName;
    newstate.Nx          = oldstates(ct).Nx;
    newstate.x           = oldstates(ct).x;
    newstate.Known       = oldstates(ct).Known;
    newstate.SteadyState = oldstates(ct).SteadyState;
    newstate.Description = oldstates(ct).Description;
    newstate.Min         = oldstates(ct).Min;
    newstate.Max         = oldstates(ct).Max;
    newstate.Ts          = oldstates(ct).Ts;
    newstate.SampleType  = oldstates(ct).SampleType;
    newstate.inReferencedModel  = oldstates(ct).inReferencedModel;
        
    % Store the new state
    states = [states;newstate];
end

% Extract the input levels
oldinputs = opspec.Inputs;
inputs = [];
for ct = 1:length(oldinputs)
    % Create a new object
    newinput = opcond.InputSpec;
    
    % Copy Information
    newinput.PortDimensions = oldinputs(ct).PortDimensions;
    newinput.PortWidth = oldinputs(ct).PortWidth;
    newinput.u         = oldinputs(ct).u;
    newinput.Known     = oldinputs(ct).Known;
    newinput.Block     = oldinputs(ct).Block;
    newinput.Description = oldinputs(ct).Description; 
    newinput.Min         = oldinputs(ct).Min; 
    newinput.Max         = oldinputs(ct).Max; 
    
    % Store the new input
    inputs = [inputs;newinput];
end

% Extract the output levels
constr_outputs = opspec.Outputs;
outputs = [];
for ct = 1:length(constr_outputs)
    % Create a new object
    newoutput = opcond.OutputSpec;
    
    % Copy information
    newoutput.PortWidth = opspec.Outputs(ct).PortWidth;
    newoutput.PortNumber = opspec.Outputs(ct).PortNumber;
    newoutput.y          = opspec.Outputs(ct).y;
    newoutput.Known      = opspec.Outputs(ct).Known;    
    newoutput.Block      = opspec.Outputs(ct).Block;
    newoutput.Description = opspec.Outputs(ct).Description;
    newoutput.Min         = opspec.Outputs(ct).Min;
    newoutput.Max         = opspec.Outputs(ct).Max;
            
    % Store the new output 
    outputs = [outputs;newoutput];
end

opcopy.States = states;
opcopy.Inputs = inputs;
opcopy.Outputs = outputs;
