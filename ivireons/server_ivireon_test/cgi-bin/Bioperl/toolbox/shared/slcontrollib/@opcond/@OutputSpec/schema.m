function schema
%SCHEMA  Defines properties for @OutputSpec class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2008/04/28 03:26:00 $

% Find the package
pkg = findpackage('opcond');

% Register class
c = schema.class(pkg, 'OutputSpec');

% Public attributes
schema.prop(c, 'Block', 'string');                   % Simulink block
schema.prop(c, 'PortWidth', 'MATLAB array');         % Port Width
schema.prop(c, 'PortNumber', 'MATLAB array');         % Port Width
p = schema.prop(c, 'y', 'MATLAB array');             % Value of the input
p.SetFunction = {@LocalSetValue,'y'};

% Property for the known input flag
p = schema.prop(c, 'Known', 'MATLAB array');
p.SetFunction = @LocalSetKnownValue;

% Property to store the lower bound of the constraint
p = schema.prop(c, 'Min', 'MATLAB array');       
p.SetFunction = {@LocalSetValue,'Min'};

% Property to store the upper bound of the constraint
p = schema.prop(c, 'Max', 'MATLAB array');     
p.SetFunction = {@LocalSetValue,'Max'};

schema.prop(c, 'Description', 'string');             % User description

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid input arguments for the port width.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetValue(this,NewValue,prop)

invaliddatatype = ~isa(NewValue,'double') || ~isreal(NewValue);
invalidlength = (~isempty(this.PortWidth)) && ...
        (~(length(NewValue)==this.PortWidth) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty',prop,this.PortWidth);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetKnownValue(this,NewValue)

invaliddatatype = (~isa(NewValue,'double') && ~isa(NewValue,'logical')) || ~isreal(NewValue);
invalidlength = (~isempty(this.PortWidth)) && ...
        (~(length(NewValue)==this.PortWidth) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty','Known',this.PortWidth);
end
