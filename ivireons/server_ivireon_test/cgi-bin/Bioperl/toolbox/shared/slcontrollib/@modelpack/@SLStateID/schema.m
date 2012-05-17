function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:00 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('modelpack');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'StateID');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'SLStateID', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Dimensions', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Path', 'string');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Ts', 'double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'Aliases', 'string vector');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
