function opreport = CreateOpReport(opspec)
%CREATEOPREPORT Method create the operating condition report from trim analysis
%

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/04/25 03:19:50 $

% Create a copy of the operating condition object
opreport = opcond.OperatingReport(opspec.Model);
opreport.Time = opspec.Time;
 
% Extract the states from the operating condition object
if isempty(opspec.States)
    states = [];
end

for ct = length(opspec.States):-1:1
    
    %% Create a new object
    newstate = opcond.StateReport;
    
    %% Copy the information
    newstate.Block       = opspec.States(ct).Block;   
    newstate.StateName   = opspec.States(ct).StateName;  
    newstate.Nx          = opspec.States(ct).Nx;
    newstate.x           = opspec.States(ct).x;
    newstate.Known       = opspec.States(ct).Known;
    newstate.SteadyState = opspec.States(ct).SteadyState;
    newstate.Description = opspec.States(ct).Description;
    newstate.Min         = opspec.States(ct).Min;
    newstate.Max         = opspec.States(ct).Max;
    newstate.SampleType = opspec.States(ct).SampleType;
    newstate.inReferencedModel = opspec.States(ct).inReferencedModel;
    newstate.Ts         = opspec.States(ct).Ts;

    %% Store the new state
    states(ct) = newstate;
end

% Extract the input levels
if isempty(opspec.Inputs)
    inputs = [];
end
for ct = 1:length(opspec.Inputs)
    %% Create a new object
    newinput = opcond.InputReport;
    
    %% Copy Information
    newinput.PortWidth = opspec.Inputs(ct).PortWidth;
    newinput.u         = opspec.Inputs(ct).u;
    newinput.Known     = opspec.Inputs(ct).Known;
    newinput.Block     = opspec.Inputs(ct).Block;
    newinput.Description = opspec.Inputs(ct).Description; 
    newinput.Min         = opspec.Inputs(ct).Min; 
    newinput.Max         = opspec.Inputs(ct).Max; 
    
    %% Store the new input
    inputs(ct) = newinput;
end

% Extract the output levels
if isempty(opspec.Outputs)
    outputs = [];
end
for ct = 1:length(opspec.Outputs)
    %% Create a new object
    newoutput = opcond.OutputReport;
    
    %% Copy information
    newoutput.PortWidth = opspec.Outputs(ct).PortWidth;
    newoutput.PortNumber = opspec.Outputs(ct).PortNumber;
    newoutput.y          = opspec.Outputs(ct).y;
    newoutput.yspec      = opspec.Outputs(ct).y;
    newoutput.Known      = opspec.Outputs(ct).Known;    
    newoutput.Block      = opspec.Outputs(ct).Block;
    newoutput.Description = opspec.Outputs(ct).Description;
    newoutput.Min         = opspec.Outputs(ct).Min;
    newoutput.Max         = opspec.Outputs(ct).Max;
            
    %% Store the new output 
    outputs(ct) = newoutput;
end

opreport.States = states;
opreport.Inputs = inputs;
opreport.Outputs = outputs;
