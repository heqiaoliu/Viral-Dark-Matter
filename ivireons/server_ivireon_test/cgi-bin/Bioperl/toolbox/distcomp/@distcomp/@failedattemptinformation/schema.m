function schema
%SCHEMA defines the distcomp.failedattemptinformation class
%

% Copyright 2008 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'failedattemptinformation', hParentClass);

p = schema.prop(hThisClass, 'StartTime', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'ErrorMessage', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'ErrorIdentifier', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'CommandWindowOutput', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'Worker', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.AbortSet  = 'off';

