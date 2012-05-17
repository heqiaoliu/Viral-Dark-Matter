function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/12/14 15:01:35 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'VariableValue');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'ParameterValue', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'ID', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Dimension', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = [0 0];

p = schema.prop(c, 'isDimensionEditable', 'bool');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = true;

p = schema.prop(c, 'Value', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetValue, p.Name };

% ----------------------------------------------------------------------------
function value = LocalSetValue(this, value, pname)
if numel(value)>1 && ~isequal(this.getDimensions,size(value))
   ctrlMsgUtils.error('SLControllib:modelpack:SizeMismatch')
end
if isequal(this.getDimensions,[0 0]) && isempty(value)
   %Nothing to do
elseif ~any( isnan(value(:)) )
  value = modelpack.utValidateValue(this, value);
else
  ctrlMsgUtils.error( 'SLControllib:general:RealDoubleArrayValue', pname );
end
