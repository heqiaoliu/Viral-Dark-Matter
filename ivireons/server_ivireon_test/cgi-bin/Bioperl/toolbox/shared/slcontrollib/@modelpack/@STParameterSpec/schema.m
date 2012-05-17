function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/10/16 06:40:04 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'ParameterSpec');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'STParameterSpec', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Format', 'double');
p.FactoryValue = 1;
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(c, 'FormatOptions', 'string vector');
p.FactoryValue = {''};
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(c, 'Listeners', 'handle vector');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';



