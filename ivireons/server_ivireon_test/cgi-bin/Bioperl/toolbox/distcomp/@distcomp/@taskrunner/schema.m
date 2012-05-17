function schema
%SCHEMA defines the distcomp.lsfscheduler class
%

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2005/12/22 17:52:12 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractscheduler');
hThisClass   = schema.class(hThisPackage, 'taskrunner', hParentClass);

p = schema.prop(hThisClass, 'DependencyDirectory', 'string');

