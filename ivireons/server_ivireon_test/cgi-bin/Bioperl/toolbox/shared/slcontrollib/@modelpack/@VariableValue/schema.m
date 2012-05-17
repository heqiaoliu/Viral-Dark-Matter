function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:26:00 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'VariableValue');

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Description', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';

p = schema.prop(c, 'Version', 'double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
