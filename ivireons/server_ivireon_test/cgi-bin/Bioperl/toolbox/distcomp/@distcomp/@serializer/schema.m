function schema
%SCHEMA defines the distcomp.fileserializer class
%

%   Copyright 2005 The MathWorks, Inc.

%   $Revision: 1.1.10.1 $  $Date: 2005/12/22 17:51:18 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'serializer', hParentClass);

p = schema.prop(hThisClass, 'Storage', 'handle');
p.AccessFlags.PublicSet = 'off';