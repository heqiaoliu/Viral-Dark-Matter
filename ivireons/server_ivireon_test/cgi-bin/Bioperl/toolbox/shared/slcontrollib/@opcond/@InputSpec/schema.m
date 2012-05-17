function schema
%SCHEMA  Defines properties for @InputSpec class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/04/28 03:25:58 $

% Find the package
pkg = findpackage('opcond');

% Register class
c = schema.class(pkg, 'InputSpec');

% Public attributes
schema.prop(c, 'Block', 'string');                   % Simulink block
schema.prop(c, 'PortWidth', 'MATLAB array');         % Port Width
schema.prop(c, 'PortDimensions', 'MATLAB array');    % Port Dimensions
p = schema.prop(c, 'u', 'MATLAB array');             % Value of the input
p.SetFunction = {@LocalSetValue,'u'};

% Property for the known flag
p = schema.prop(c, 'Known', 'MATLAB array');
p.SetFunction = @LocalSetKnownValue;

p = schema.prop(c, 'Min', 'MATLAB array');        % Lower Bound
p.SetFunction = {@LocalSetValue,'Min'};

p = schema.prop(c, 'Max', 'MATLAB array');        % Upper Bound
p.SetFunction = {@LocalSetValue,'Max'};

schema.prop(c, 'Description', 'string');             % User description

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid input arguments for the analysis point type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetValue(this,NewValue,prop)

invaliddatatype = ~isa(NewValue,'double') || ~isreal(NewValue);
invalidlength = (~isempty(this.PortWidth)) && ...
        (~(length(NewValue)==this.PortWidth) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty',prop,this.PortWidth);
end

function NewValue = LocalSetKnownValue(this,NewValue)

invaliddatatype = (~isa(NewValue,'double') && ~isa(NewValue,'logical')) || ~isreal(NewValue);
invalidlength = (~isempty(this.PortWidth)) && ...
        (~(length(NewValue)==this.PortWidth) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty','Known',this.PortWidth);
end
