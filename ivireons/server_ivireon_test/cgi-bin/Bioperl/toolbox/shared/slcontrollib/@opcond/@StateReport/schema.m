function schema
%SCHEMA  Defines properties for @StateReport class

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2007/11/09 21:02:01 $

% Register class
c = schema.class(findpackage('opcond'), 'StateReport');

% Public attributes
% Property for the simulink block name
schema.prop(c, 'Block', 'string');                   

% Property for the simulink state name
schema.prop(c, 'StateName', 'string');  

% Property for the value of the states
p = schema.prop(c, 'x', 'MATLAB array');             
p.SetFunction = {@LocalSetValue,'x'};

% Property for the state derivative or update
p = schema.prop(c, 'dx', 'MATLAB array');             
p.SetFunction = {@LocalSetValue,'dx'};

% Property storing the number of states in a block
schema.prop(c,'Nx','MATLAB array');

% Property for the known state flag
schema.prop(c, 'Known', 'MATLAB array');

% On/Off property for the steady state flag
schema.prop(c, 'SteadyState', 'MATLAB array');    

% Property for the lower bounds for a set of states for a block during
% trim
p = schema.prop(c, 'Min', 'MATLAB array');        % Lower Bound
p.SetFunction = {@LocalSetValue,'Max'};

% Property for the upper bounds for a set of states for a block during
% trim
p = schema.prop(c, 'Max', 'MATLAB array');        % Upper Bound
p.SetFunction = {@LocalSetValue,'Max'};

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid input arguments for the analysis point
% type.
function NewValue = LocalSetValue(this,NewValue,prop)

invaliddatatype = ~isa(NewValue,'double') || ~isreal(NewValue);
invalidlength = (~isempty(this.Nx)) && ...
        (~(length(NewValue)==this.Nx) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty',prop,this.Nx);
end
