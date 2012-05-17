function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/12/14 15:01:28 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'VariableSpec');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'ParameterSpec', hDeriveFromClass);

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

p = schema.prop(c, 'InitialValue', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';
p.SetFunction           = { @LocalSetValue, p.Name };

p = schema.prop(c, 'Known', 'MATLAB array');
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

% ----------------------------------------------------------------------------
function value = LocalSetLogical(this, value, pname)
if numel(value)>1 && ~isequal(this.getDimensions,size(value))
   ctrlMsgUtils.error('SLControllib:modelpack:SizeMismatch')
end
try
  value = logical(value);
catch
  ctrlMsgUtils.error( 'SLControllib:general:LogicalArrayValue', pname );
end
if ~(isequal(this.getDimensions,[0 0]) && isempty(value))
   value = modelpack.utValidateValue(this, value);
end
