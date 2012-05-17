function schema
%SCHEMA  Defines properties for @StatePoint class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2007/11/09 21:01:59 $

% Register class
c = schema.class(findpackage('opcond'), 'StatePoint');

% Public attributes
% Property storing the number of states in a block
schema.prop(c,'Nx','MATLAB array');

% Property for the simulink block name
schema.prop(c, 'Block', 'string');                   

% Property for the simulink state name
schema.prop(c, 'StateName', 'string');  

% Property for the value of the states
p = schema.prop(c, 'x', 'MATLAB array');             
p.SetFunction = {@LocalSetValue,'x'};

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
% Function to check for valid input arguments for the state x property
% type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetValue(this,NewValue,prop)

invaliddatatype = ~isa(NewValue,'double') || ~isreal(NewValue);
invalidlength = (~isempty(this.Nx)) && ...
        (~(length(NewValue)==this.Nx) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty',prop,this.Nx);
end
