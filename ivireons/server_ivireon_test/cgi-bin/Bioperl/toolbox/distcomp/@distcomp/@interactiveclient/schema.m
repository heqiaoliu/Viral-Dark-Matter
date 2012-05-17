function schema
%SCHEMA defines the distcomp.interactiveclient class
%

%   Copyright 2006 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hThisClass   = schema.class(hThisPackage, 'interactiveclient');
mlock;

p = schema.prop(hThisClass, 'ConnectionManager', 'com.mathworks.toolbox.distcomp.pmode.io.ConnectionManager' );
p.AccessFlags.PublicSet = 'on';

% The name of the current user.
p = schema.prop(hThisClass, 'UserName', 'string');
p.AccessFlags.PublicSet = 'off';

% The tag we use to tag all the parallel jobs we create.
p = schema.prop(hThisClass, 'Tag', 'string');
p.AccessFlags.PublicSet = 'off';

% The timeout is in number of seconds.
p = schema.prop(hThisClass, 'JobStartupTimeout', 'double');
p.AccessFlags.PublicSet = 'on';

p = schema.prop(hThisClass, 'ParallelJob', 'handle');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'IsGUIOpen', 'bool');
p.AccessFlags.PublicSet = 'off';

% The type of interactivity we are part of
p = schema.prop(hThisClass, 'CurrentInteractiveType', 'distcomp.interactivetype');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 'none';

p = schema.prop(hThisClass, 'IsStartupComplete', 'bool');
p.AccessFlags.PublicSet = 'off';

