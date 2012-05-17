function schema
%SCHEMA defines the distcomp.cacheableobject class
%

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2007/06/18 22:11:18 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('configurableobject');
hThisClass   = schema.class(hThisPackage, 'cacheableobject', hParentClass);

p = schema.prop(hThisClass, 'UUID', 'net.jini.id.Uuid');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet  = 'off';
