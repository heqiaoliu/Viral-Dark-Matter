function schema
%SCHEMA defines the distcomp.object class
%

% Copyright 2004-2006 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'objectroot', hParentClass);

p = schema.prop(hThisClass, 'ProxyHashtable', 'java.util.Hashtable');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'ProxyToUddAdaptor', 'handle');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(hThisClass, 'ProxyToUddAdaptorListener', 'handle');
p.AccessFlags.PublicSet = 'off';

% Fields to hold information about the currently executing task, job,
% worker and jobmanager
p = schema.prop(hThisClass, 'CurrentJobmanager', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'CurrentWorker', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'CurrentJob', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'CurrentTask', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'CurrentRunprop', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

p = schema.prop(hThisClass, 'CurrentErrorHandlers', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';

% Some derived properties
p = schema.prop(hThisClass, 'DependencyDirectory', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';
p.GetFunction = @iGetDependencyDirectory;


function val = iGetDependencyDirectory(obj, val) %#ok<INUSD>
if ishandle(obj.CurrentRunprop)
    val = obj.CurrentRunprop.DependencyDirectory;
else
    val = '';
end
