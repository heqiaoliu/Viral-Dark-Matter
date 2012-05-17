function schema
%SCHEMA defines the distcomp.abstractscheduler class

% Copyright 2005-2010 The MathWorks, Inc.

% $Revision: 1.1.10.7 $  $Date: 2010/03/01 05:20:02 $

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('cacheableobject');
hThisClass   = schema.class(hThisPackage, 'abstractscheduler', hParentClass);

p = schema.prop(hThisClass, 'Storage', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.SetFunction = @pSetStorage;

p = schema.prop(hThisClass, 'DefaultJobConstructor', 'MATLAB callback');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = @distcomp.simplejob;

p = schema.prop(hThisClass, 'DefaultParallelJobConstructor', 'MATLAB callback');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = @distcomp.simpleparalleljob;

p = schema.prop(hThisClass, 'DefaultMatlabPoolJobConstructor', 'MATLAB callback');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = @distcomp.simplematlabpooljob;

p = schema.prop(hThisClass, 'Type', 'string');
p.AccessFlags.PublicSet = 'off';

% This is the public interface to the internal storage property
p = schema.prop(hThisClass, 'DataLocation', 'MATLAB array');
p.SetFunction = @pSetDataLocation;
p.GetFunction = @pGetDataLocation;

p = schema.prop(hThisClass, 'HasSharedFilesystem', 'bool');
p.SetFunction = @pSetHasSharedFilesystem;
p.GetFunction = @pGetHasSharedFilesystem;


p = schema.prop(hThisClass, 'Jobs', 'handle vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PrivateSet  = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = handle(-ones(0, 1));
p.GetFunction = @pGetJobs;

p = schema.prop(hThisClass, 'ClusterMatlabRoot', 'string');
p.SetFunction = @pSetClusterMatlabRoot;
p.GetFunction = @pGetClusterMatlabRoot;
p.AccessFlags.Init = 'on';
p.FactoryValue = '';


% Need to know this, sadly
p = schema.prop( hThisClass, 'ClusterOsType', 'distcomp.workertype' ); %'pc', 'unix' or 'mixed'
p.AccessFlags.Init = 'on';
p.SetFunction = @pSetClusterOsType;
p.GetFunction = @pGetClusterOsType;
if ispc
    p.FactoryValue = 'pc';
else
    p.FactoryValue = 'unix';
end

schema.prop(hThisClass, 'UserData', 'MATLAB array');

p = schema.prop(hThisClass, 'ClusterSize', 'double');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetClusterSize;
p.GetFunction = @pGetClusterSize;
p.FactoryValue = Inf;
