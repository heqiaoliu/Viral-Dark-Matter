function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:42:04 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'simoptions');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'gradoptions', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'GradientType', 'Model_GradientType');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';

p = schema.prop(c, 'Perturbation', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';

% ----------------------------------------------------------------------------
