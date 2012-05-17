function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2007/11/09 21:02:16 $

% Construct class
c = schema.class(findpackage('slcontrol'), 'Parameter');

% Class properties
% Parameter name
p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicSet = 'off';

% Parameter dimensions
p = schema.prop(c, 'Dimensions', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.SetFunction = @LocalSetDimensions;
p.Visible = 'off';

% Parameter values
p = schema.prop(c, 'Value', 'MATLAB array');
p.SetFunction = { @LocalSetValue, p.Name };

% Initial guess
p = schema.prop(c, 'InitialGuess', 'MATLAB array');
p.SetFunction = { @LocalSetValue, p.Name };

% Minimum values
p = schema.prop(c, 'Minimum', 'MATLAB array');
p.SetFunction = { @LocalSetValue, p.Name };

% Maximum value
p = schema.prop(c, 'Maximum', 'MATLAB array');
p.SetFunction = { @LocalSetValue, p.Name };

% Typical value of the parameter
p = schema.prop(c, 'TypicalValue', 'MATLAB array');
p.SetFunction = { @LocalSetValue, p.Name };

% Referencing blocks
p = schema.prop(c, 'ReferencedBy', 'string vector');

% User defined description
p = schema.prop(c, 'Description', 'string');

% Object version number
p = schema.prop(c, 'Version', 'double');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 1.0;
p.Visible = 'off';

% ----------------------------------------------------------------------------- %
function value = LocalSetDimensions(this, value)
if isnumeric(value) && isreal(value) && isvector(value)
  value = reshape(value,[1 numel(value)]);  % Make it a row vector.
else
  ctrlMsgUtils.error( 'SLControllib:slcontrol:IntegerVectorValue', 'Dimensions' );
end

% --------------------------------------------------------------------------- %
function value = LocalSetValue(this, value, pname)
if ~any( isnan(value(:)) )
  value = utCheckSize(this,value);
else
  ctrlMsgUtils.error( 'SLControllib:general:RealDoubleArrayValue', pname );
end
