function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:27 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'VariableSpec');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'StateSpec', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'ID', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'InitialValue', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetValue, p.Name };

p = schema.prop(c, 'Known', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetLogical, p.Name };

p = schema.prop(c, 'SteadyState', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetLogical, p.Name };

p = schema.prop(c, 'Minimum', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetValue, p.Name };

p = schema.prop(c, 'Maximum', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetValue, p.Name };

p = schema.prop(c, 'TypicalValue', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetValue, p.Name };

% ----------------------------------------------------------------------------
function value = LocalSetValue(this, value, pname)
if ~any( isnan(value(:)) )
  value = modelpack.utValidateValue(this, value, '(');
else
  ctrlMsgUtils.error( 'SLControllib:general:RealDoubleArrayValue', pname );
end

% ----------------------------------------------------------------------------
function value = LocalSetLogical(this, value, pname)
try
  value = logical(value);
catch
  ctrlMsgUtils.error( 'SLControllib:general:LogicalArrayValue', pname );
end
value = modelpack.utValidateValue(this, value, '(');
