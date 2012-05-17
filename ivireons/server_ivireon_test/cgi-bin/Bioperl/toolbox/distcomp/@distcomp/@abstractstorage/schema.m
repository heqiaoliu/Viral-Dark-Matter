function schema
%SCHEMA defines the distcomp.abstractstorage class
%

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2005/12/22 17:48:09 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'abstractstorage', hParentClass);

p = schema.prop(hThisClass, 'Serializer', 'handle');
p.AccessFlags.PublicSet = 'off';


p = schema.prop(hThisClass, 'StorageLocation', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.SetFunction = @pSetStorageLocation;

p = schema.prop(hThisClass, 'IsReadOnly', 'bool');
p.AccessFlags.PublicSet = 'off';

