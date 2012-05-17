function schema
% Sample object that implements getDialogSchema
% create its dialog by the following statement:
%
% >> h = DAStudio.SampleObject
% >> d = DAStudio.Dialog(h)

% Copyright 2004 The MathWorks, Inc.

% =========================================================================
% Class Definition
% =========================================================================
hSuperPackage = findpackage('DAStudio');
hSuperClass   = findclass(hSuperPackage, 'Object');
hPackage      = findpackage('DAStudio'); 
hThisClass    = schema.class(hPackage, 'SampleObject', hSuperClass);
  
% =========================================================================
% Class Methods
% =========================================================================
% getDialogSchema
m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

% myMethod
m = schema.method(hThisClass,'myMethod');
m.signature.varargin = 'off';
m.signature.InputTypes={'handle', 'int', 'string', 'bool'};

% =========================================================================
% Class Properties
% =========================================================================
schema.EnumType( ...
  'MassUnitsEnumType', ... 
  {'kg', 'g', 'mg', 'slug', 'lbm'}, ...
  [1 2 3 4 5] ...
);

schema.EnumType( ...
  'InertiaUnitsEnumType', ... 
  {'kg*m^2', 'g*cm^2', 'slug*ft^2', 'slug*in^2', 'lb*ft^2', 'lb*in^2'}, ...
  [1 2 3 4 5 6] ...
);

p = schema.prop(hThisClass, 'mass', 'string');
p = schema.prop(hThisClass, 'massUnits', 'MassUnitsEnumType');
p = schema.prop(hThisClass, 'inertia', 'string');
p = schema.prop(hThisClass, 'inertiaUnits', 'InertiaUnitsEnumType');
p = schema.prop(hThisClass, 'positionSchema', 'handle vector');
