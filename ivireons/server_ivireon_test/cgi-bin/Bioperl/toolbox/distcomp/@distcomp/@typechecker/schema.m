function schema
%SCHEMA defines the distcomp.typechecker class
%

%   Copyright 2007-2009 The MathWorks, Inc.


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'typechecker', hParentClass);
% Declare the interface that this class implements.
hThisClass.JavaInterfaces = {'com.mathworks.toolbox.distcomp.configurations.TypeChecker'};
%%%%
% Ensure that the classes defining the types have been loaded:
% 1. Load distcomp.mpiexecenvtype from the mpiexec schema.
% 2. Load distcomp.ccsclusterversion from the ccsscheduler schema
hThisPackage.findclass('mpiexec');
hThisPackage.findclass('ccsscheduler');

%%%%
% Declare all the properties that represent data types.
p = schema.prop(hThisClass, 'MATLAB_array', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'MATLAB_callback', 'MATLAB callback');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'bool', 'bool');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'distcomp_mpiexecenvtype', 'distcomp.mpiexecenvtype');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'distcomp_workertype', 'distcomp.workertype');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'double', 'double');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'string', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'string_vector', 'string vector');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(hThisClass, 'distcomp_microsoftclusterversion', 'distcomp.microsoftclusterversion');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';


%%%%
% Store the mapping between data types and object properties as well as enum
% values.
%
% The constructor relies on this being the only object property which does not
% represent a data type.
p = schema.prop(hThisClass, 'PropertyInfo', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

%%%%
% Declare the static methods.
schema.method(hThisClass, 'getDefaultValue', 'static');
schema.method(hThisClass, 'getEnumValues', 'static');
schema.method(hThisClass, 'isCorrectType', 'static');
schema.method(hThisClass, 'getAllTypes', 'static');
schema.method(hThisClass, 'pGetInstance', 'static');
schema.method(hThisClass, 'callback2string', 'static');
schema.method(hThisClass, 'string2callback', 'static');
