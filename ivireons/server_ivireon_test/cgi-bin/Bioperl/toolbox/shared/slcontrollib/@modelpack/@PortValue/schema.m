function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:00:29 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'VariableValue');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'PortValue', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'ID', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Value', 'MATLAB array');
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
