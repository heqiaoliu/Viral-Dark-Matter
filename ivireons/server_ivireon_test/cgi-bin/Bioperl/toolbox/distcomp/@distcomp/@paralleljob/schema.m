function schema
%SCHEMA defines the distcomp.paralleljob class
%

%  Copyright 2000-2005 The MathWorks, Inc.

%  $Revision: 1.1.10.2 $    $Date: 2007/06/18 22:13:44 $ 

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('job');
schema.class(hThisPackage, 'paralleljob', hParentClass);
