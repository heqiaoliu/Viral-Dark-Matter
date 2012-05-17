function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:41:41 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'ParameterSpec');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'UncertainSpec', hDeriveFromClass);

% ----------------------------------------------------------------------------

p = schema.prop(c,'EvaluateAllValues','bool');
p.FactoryValue = false;
p = schema.prop(c,'EvaluateNominal','bool');
p.FactoryValue = false;
p = schema.prop(c,'EvaluateMinMaxOnly','bool');
p.FactoryValue = false;
p = schema.prop(c,'UncertainValues','MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';



 
