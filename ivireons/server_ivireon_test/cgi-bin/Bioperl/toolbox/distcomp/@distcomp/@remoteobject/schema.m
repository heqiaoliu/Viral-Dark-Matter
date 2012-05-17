function schema
%SCHEMA defines the distcomp.remoteobject class
%

% Copyright 2004-2005 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('configurableobject');
hThisClass   = schema.class(hThisPackage, 'remoteobject', hParentClass);

p = schema.prop(hThisClass, 'UUID', 'net.jini.id.Uuid[]');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet  = 'off';

% p = schema.prop(hThisClass, 'ID', 'string');
% p.AccessFlags.PublicSet = 'off';
% p.AccessFlags.PrivateSet = 'off';
% p.GetFunction = @pGetID;

p = schema.prop(hThisClass, 'EventListeners', 'handle vector');
p.AccessFlags.PublicSet  = 'off';
p.AccessFlags.PublicGet  = 'off';
p.AccessFlags.Serialize = 'off';
