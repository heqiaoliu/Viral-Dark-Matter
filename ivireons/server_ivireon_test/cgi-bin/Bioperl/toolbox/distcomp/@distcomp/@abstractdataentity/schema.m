function schema
%SCHEMA defines the distcomp.abstractdataentity class
%

%   Copyright 2005 The MathWorks, Inc.

%   $Revision: 1.1.10.2 $  $Date: 2008/06/24 17:00:43 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('cacheableobject');
hThisClass   = schema.class(hThisPackage, 'abstractdataentity', hParentClass);

p = schema.prop(hThisClass, 'Serializer', 'handle');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'Location', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'Type', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';


p = schema.prop(hThisClass, 'Name', 'string');
p.GetFunction = @pGetName;
p.SetFunction = @pSetName;

p = schema.prop(hThisClass, 'ID', 'double');
p.AccessFlags.PublicSet = 'off';

% If a abstractdataentity has been created in an uncached state then it is
% possible that once the true remote representation is made some subsequent
% calls may need to be made. This flag is used to indicate that some things
% may need to be done. This field is a cell array of cell array callbacks
% that will be executed after construction
p = schema.prop(hThisClass, 'PostConstructionFcns', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = cell(0, 2);

p = schema.prop(hThisClass, 'IsBeingConstructed', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = false;
