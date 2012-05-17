function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2006/09/30 00:23:18 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('modelpack');

% Construct class
c = schema.class(hCreateInPackage, 'Model');

% ----------------------------------------------------------------------------
p = schema.prop(c, 'Description', 'string');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'on';

p = schema.prop(c, 'Version', 'double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% ----------------------------------------------------------------------------
% Define events
% ----------------------------------------------------------------------------
% Generic event to notify listeners of property changes.
% Use it with the firePropertyChange() method to attach data to it.
schema.event(c, 'PropertyChange');
