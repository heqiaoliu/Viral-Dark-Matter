function schema
%SCHEMA  Defines properties for @OutputReport class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/11/09 21:01:55 $

% Find the package
pkg = findpackage('opcond');

% Register class
c = schema.class(pkg, 'OutputReport');

% Public attributes
schema.prop(c, 'Block', 'string');                   % Simulink block
schema.prop(c, 'PortWidth', 'MATLAB array');         % Port Width
schema.prop(c, 'PortNumber', 'MATLAB array');         % Port Width
p = schema.prop(c, 'y', 'MATLAB array');             % Value of the input
p.SetFunction = {@LocalSetValue,'y'};

p = schema.prop(c, 'yspec', 'MATLAB array');             % Value of the input
p.SetFunction = {@LocalSetValue,'yspec'};

% Property for the known input flag
schema.prop(c, 'Known', 'MATLAB array');

% Property to store the lower bound of the constraint
p = schema.prop(c, 'Min', 'MATLAB array');       
p.SetFunction = {@LocalSetValue,'Max'};

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
