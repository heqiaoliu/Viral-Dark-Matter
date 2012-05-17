function schema
%SCHEMA defines the distcomp.simpletask class
%

%   Copyright 2005 The MathWorks, Inc.

%   $Revision: 1.1.10.2 $  $Date: 2007/06/18 22:14:01 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstracttask');
schema.class(hThisPackage, 'simpletask', hParentClass);

