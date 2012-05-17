function schema
%SCHEMA defines the distcomp.matlabpoolclient class

% Copyright 2007 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hThisClass   = schema.class(hThisPackage, 'matlabpoolclient');

p = schema.prop(hThisClass, 'ConnectionManager', 'com.mathworks.toolbox.distcomp.pmode.io.ConnectionManager' );
p.AccessFlags.PublicSet = 'on';

% The timeout is in number of seconds.
p = schema.prop(hThisClass, 'JobStartupTimeout', 'double');
p.AccessFlags.PublicSet = 'on';

p = schema.prop(hThisClass, 'IsClientOnlySession', 'bool');
p.AccessFlags.PublicSet = 'on';
