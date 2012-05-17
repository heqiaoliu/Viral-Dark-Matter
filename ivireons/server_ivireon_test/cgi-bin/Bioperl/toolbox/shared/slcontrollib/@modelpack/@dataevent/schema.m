function schema
% SCHEMA  Class definition for subclass of EVENTDATA to handle property names
%         and old/new event data.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 18:55:58 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('handle');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'EventData');
hCreateInPackage   = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'dataevent', hDeriveFromClass);

% ----------------------------------------------------------------------------
p = schema.prop(c, 'PropertyName', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'OldValue', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c, 'NewValue', 'MATLAB array');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';
