function oppoint = CreateOpPoint(opspec)
% CREATEOPPOINT Method to create an operating point object based on the
% relevant data in an operating point specification object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/09/15 20:47:10 $

% Create a copy of the operating condition object
oppoint = opcond.OperatingPoint(opspec.Model);
oppoint.T = opspec.T;

% Get the states
if isempty(opspec.States)
    states = [];
end

% Set the state data
for ct = length(opspec.States):-1:1
    % Create a new object
    states(ct) = opcond.StatePoint;
    % Copy information
    states(ct).Block        = opspec.States(ct).Block;
    states(ct).StateName    = opspec.States(ct).StateName;
    states(ct).Nx           = opspec.States(ct).Nx;
    states(ct).x            = opspec.States(ct).x;
    states(ct).Description  = opspec.States(ct).Description;
    states(ct).Ts           = opspec.States(ct).Ts;
    states(ct).SampleType   = opspec.States(ct).SampleType;
    states(ct).inReferencedModel  = opspec.States(ct).inReferencedModel;
end

% Get the inputs
if isempty(opspec.Inputs)
    inputs = [];
end

% Set the input data
for ct = length(opspec.Inputs):-1:1
    % Create a new object
    inputs(ct) = opcond.InputPoint;
    % Copy information
    inputs(ct).PortDimensions = opspec.Inputs(ct).PortDimensions;
    inputs(ct).Block        = opspec.Inputs(ct).Block;
    inputs(ct).PortWidth    = opspec.Inputs(ct).PortWidth;
    inputs(ct).u            = opspec.Inputs(ct).u;
    inputs(ct).Description  = opspec.Inputs(ct).Description;
end

oppoint.States = states;
oppoint.Inputs = inputs;

