function schema
%SCHEMA  Defines properties for @StateSpec class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2008/04/28 03:26:01 $

% Register class
c = schema.class(findpackage('opcond'), 'StateSpec');

% Public attributes
% Property for the simulink block name
schema.prop(c, 'Block', 'string');                   

% Property for the simulink state name
schema.prop(c, 'StateName', 'string');  

% Property for the value of the states
p = schema.prop(c, 'x', 'MATLAB array');             
p.SetFunction = {@LocalSetValue,'x'};

% Property storing the number of states in a block
schema.prop(c,'Nx','MATLAB array');

% Property for the sample time of the state
p = schema.prop(c, 'Ts', 'MATLAB array');
p.FactoryValue = [];

% Property for the sample time of the state
p = schema.prop(c, 'SampleType', 'MATLAB array');
p.FactoryValue = [];

% Property for whether the state is in a referenced model
p = schema.prop(c, 'inReferencedModel', 'MATLAB array');
p.FactoryValue = false;

% Property for the known state flag
p = schema.prop(c, 'Known', 'MATLAB array');
p.SetFunction = @LocalSetKnownValue;

% On/Off property for the steady state flag
schema.prop(c, 'SteadyState', 'MATLAB array');    

% Property for the lower bounds for a set of states for a block during
% trim
p = schema.prop(c, 'Min', 'MATLAB array');        % Lower Bound
p.SetFunction = {@LocalSetValue,'Min'};

% Property for the upper bounds for a set of states for a block during
% trim
p = schema.prop(c, 'Max', 'MATLAB array');        % Upper Bound
p.SetFunction = {@LocalSetValue,'Max'};

% User storable description of the state object
schema.prop(c, 'Description', 'string');             % User description

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid input arguments for the number of states.
function NewValue = LocalSetValue(this,NewValue,prop)

invaliddatatype = ~isa(NewValue,'double') || ~isreal(NewValue);
invalidlength = (~isempty(this.Nx)) && ...
        (~(length(NewValue)==this.Nx) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty',prop,this.Nx);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetKnownValue(this,NewValue)

invaliddatatype = (~isa(NewValue,'double') && ~isa(NewValue,'logical')) || ~isreal(NewValue);
invalidlength = (~isempty(this.Nx)) && ...
        (~(length(NewValue)==this.Nx) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty','Known',this.Nx);
end
