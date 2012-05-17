function schema
%SCHEMA defines the distcomp.configpropstorage class
%

% Copyright 2007 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hThisClass   = schema.class(hThisPackage, 'configpropstorage');

% Stores information about all the configurable properties that have been
% registered.
p = schema.prop(hThisClass, 'PropertyInfo', 'MATLAB array'); % A struct
p.AccessFlags.PublicSet = 'off';

%%%
% Declare static methods.
schema.method(hThisClass, 'getConfigurableProperties', 'static');
schema.method(hThisClass, 'pGetInstance', 'static');
% The following method contains >>THE<< list of configurable properties.
schema.method(hThisClass, 'pGetAllConfigurableProperties', 'static');
schema.method(hThisClass, 'pVerifyClassName', 'static');
schema.method(hThisClass, 'pGetDataTypeInformation', 'static');
