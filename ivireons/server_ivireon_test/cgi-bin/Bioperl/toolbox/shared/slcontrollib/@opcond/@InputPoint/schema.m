function schema
%SCHEMA  Defines properties for @InputPoint class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2008/04/03 03:17:11 $

% Register class
c = schema.class(findpackage('opcond'), 'InputPoint');

% Public attributes
schema.prop(c, 'Block', 'string');                   % Simulink block
schema.prop(c, 'PortWidth', 'MATLAB array');         % Port Width
schema.prop(c, 'PortDimensions', 'MATLAB array');    % Port Dimensions
p = schema.prop(c, 'u', 'MATLAB array');             % Value of the input
p.SetFunction = @LocalSetValue;
schema.prop(c, 'Description', 'string');             % User description

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid input arguments for the port width.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetValue(this,NewValue)

invaliddatatype = ~isa(NewValue,'double') || ~isreal(NewValue);
invalidlength = (~isempty(this.PortWidth)) && ...
        (~(length(NewValue)==this.PortWidth) && ~(isempty(NewValue)));
    
if invalidlength || invaliddatatype
    ctrlMsgUtils.error('SLControllib:opcond:InvalidDataPortProperty','u',this.PortWidth);
end