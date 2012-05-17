function schema
% SCHEMA Defines class properties

% Author(s): A. Stothert
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:41:15 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'PortID');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'STPortID', hDeriveFromClass);

% -------------------------------------------------------------------------
p = schema.prop(c, 'Dimension', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'Path', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(c, 'PortNumber', 'double');
p.FactoryValue = 1;
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PublicGet  = 'off';

p = schema.prop(c, 'Type', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

