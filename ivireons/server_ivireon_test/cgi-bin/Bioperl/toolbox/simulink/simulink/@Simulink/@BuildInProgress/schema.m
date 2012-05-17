function schema

% Copyright 2004-2009 The MathWorks, Inc.

% get package handle
hCreateInPackage = findpackage('Simulink');

% create class
hThisClass = schema.class(hCreateInPackage, 'BuildInProgress');

% add properties
hThisProp = schema.prop(hThisClass, 'ModelName', 'string');
hThisProp.FactoryValue = '';

hThisProp = schema.prop(hThisClass, 'ModelObj', 'handle');
hThisProp.FactoryValue = [];

hThisProp = schema.prop(hThisClass, 'Listener', 'handle');
hThisProp.FactoryValue = [];
