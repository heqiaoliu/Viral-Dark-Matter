function schema
%SCHEMA defines the distcomp.simplematlabpooljob class

% Copyright 2007-2009 The MathWorks, Inc.

% $Revision: 1.1.6.3 $  $Date: 2009/12/03 19:00:16 $

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('simpleparalleljob');
hThisClass   = schema.class(hThisPackage, 'simplematlabpooljob', hParentClass);

p = schema.prop(hThisClass, 'Task', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';
p.GetFunction = @pGetTask;

p = schema.prop(hThisClass, 'IsPoolTask', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = false;

p = schema.prop(hThisClass, 'PoolShutdownSuccessful', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = true;