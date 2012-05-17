function schema
%SCHEMA defines the distcomp.object class
%

% Copyright 2008 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
schema.class(hThisPackage, 'lockedobject', hParentClass);
mlock;