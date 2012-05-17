function schema
%SCHEMA defines the distcomp.simplejob class
%

%   Copyright 2005 The MathWorks, Inc.

%   $Revision: 1.1.10.2 $  $Date: 2007/06/18 22:13:55 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractjob');
schema.class(hThisPackage, 'simplejob', hParentClass);
