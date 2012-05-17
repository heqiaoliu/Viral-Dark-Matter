function schema
%SCHEMA defines the distcomp.fileserializer class
%

%   Copyright 2005 The MathWorks, Inc.

%   $Revision: 1.1.10.2 $  $Date: 2008/02/02 12:59:46 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('serializer');
hThisClass   = schema.class(hThisPackage, 'fileserializer', hParentClass);

jobEnum  = findtype('distcomp.jobexecutionstate');
taskEnum = findtype('distcomp.taskexecutionstate');

p = schema.prop(hThisClass, 'ValidStateStrings', 'string vector');
p.AccessFlags.Listener = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = union(jobEnum.Strings, taskEnum.Strings);
p.AccessFlags.AbortSet  = 'off';
