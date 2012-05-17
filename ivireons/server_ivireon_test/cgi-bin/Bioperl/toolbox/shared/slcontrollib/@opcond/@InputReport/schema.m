function schema
%SCHEMA  Defines properties for @InputReport class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/11/09 21:01:47 $

% Find the package
pkg = findpackage('opcond');

% Register class
c = schema.class(pkg, 'InputReport');

% Public attributes
schema.prop(c, 'Block', 'string');                   % Simulink block
schema.prop(c, 'PortWidth', 'MATLAB array');         % Port Width
p = schema.prop(c, 'u', 'MATLAB array');             % Value of the input
p.SetFunction = @LocalSetValue;

% Property for the known flag
schema.prop(c, 'Known', 'MATLAB array');

p = schema.prop(c, 'Min', 'MATLAB array');        % Lower Bound
p.SetFunction = @LocalSetValue;

p = schema.prop(c, 'Max', 'MATLAB array');        % Upper Bound
p.SetFunction = @LocalSetValue;

schema.prop(c, 'Description', 'string');             % User description

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid input arguments for the analysis point type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetValue(this,NewValue)

invaliddatatype = ~isa(NewValue,'double') || ~isreal(NewValue);
invalidlength = (~isempty(this.PortWidth)) && ...
        (~(length(NewValue)==this.PortWidth) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty','u',this.PortWidth);
end