function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:53:03 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'LinearizationIO');

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Description', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';

p = schema.prop(c, 'Version', 'double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
