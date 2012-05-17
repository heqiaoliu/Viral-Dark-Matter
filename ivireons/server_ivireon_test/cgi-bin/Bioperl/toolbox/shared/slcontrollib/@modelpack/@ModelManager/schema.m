function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2008/07/14 17:12:07 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'ModelManager');

% ---------------------------------------------------------------------------- %
p = schema.prop(c, 'Models', 'mxArray');     %struct('hModel',[],'refCount',0);
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop( c, 'ModelListeners', 'handle vector' );
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

p = schema.prop( c, 'Listeners', 'handle vector' );
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
