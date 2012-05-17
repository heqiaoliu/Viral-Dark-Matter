function schema
%SCHEMA  Defines properties for @StatePointSiMech class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2007/10/15 23:28:31 $

% Register class
c = schema.class(findpackage('opcond'), 'StatePointSimMech');

% Public attributes
% Property for the simulink block name
schema.prop(c, 'Block', 'string');                   

% Property for the simulink state name
schema.prop(c, 'StateName', 'string');  

% Property for the SimMechanics Information
schema.prop(c, 'SimMechSystemStates', 'MATLAB array');
schema.prop(c, 'SimMechMachineName', 'MATLAB array');
schema.prop(c, 'SimMechBlockStates', 'MATLAB array');
schema.prop(c, 'SimMechBlock', 'MATLAB array');

% Property storing the number of states in a block
schema.prop(c,'Nx','MATLAB array');

% Property for the value of the states
schema.prop(c, 'x', 'MATLAB array');             

% Property for the sample time of the state
p = schema.prop(c, 'Ts', 'MATLAB array');
p.FactoryValue = [];

% Property for the sample time of the state
p = schema.prop(c, 'SampleType', 'MATLAB array');
p.FactoryValue = [];

% Property for whether the state is in a referenced model
p = schema.prop(c, 'inReferencedModel', 'MATLAB array');
p.FactoryValue = false;

% User storable description of the state object
schema.prop(c, 'Description', 'string');             % User description