function schema
%SCHEMA defines the distcomp.configurableobject class
%  Copyright 2007 The MathWorks, Inc.

hThisPackage = findpackage( 'distcomp' );
hParentClass = hThisPackage.findclass( 'object' );
hThisClass   = schema.class( hThisPackage, 'configurableobject', hParentClass );

p = schema.prop(hThisClass, 'Configuration', 'string');
p.SetFunction = @pSetConfiguration;
% Always set the property value, even when setting it to the same value as it
% had previously.  
%
% Rationale: The use may do set(obj, 'Configuration', 'a'); then edit
% configuration 'a' and save it, then do set(obj, 'Configuration', 'a'); again.
p.AccessFlags.AbortSet  = 'off';

p = schema.prop(hThisClass, 'ConfigurationListener', 'handle');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Stores whether what part of a configuration applies to this object.
p = schema.prop(hThisClass, 'ConfigurationSection', 'string');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Allow sub-classes to indicate that the next set should be ignored by the
% configurable object. Perhaps the sub-class knows that this set should not
% change the current configuration
p = schema.prop(hThisClass, 'IgnoreNextSet', 'bool');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init      = 'on';
p.FactoryValue = false;

% If a sub-class wishes to know that the property is being set by a
% configuration then they should look at this property, which will hold the
% name of the configuration the property is being set from. If a property
% is being set independently of a configuration then this property will be
% empty
p = schema.prop(hThisClass, 'ConfigurationCurrentlyBeingSet', 'string');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init      = 'on';
p.FactoryValue = '';

p = schema.prop(hThisClass, 'IsBeingConfigured', 'bool');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init      = 'on';
p.FactoryValue = false;

% This field is a cell array of cell array callbacks
% that will be executed after construction
p = schema.prop(hThisClass, 'PostConfigurationFcns', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = cell(0, 2);

%%%
% Declare static methods.
schema.method(hThisClass, 'pPostConfigurablePropertySet', 'static');
schema.method(hThisClass, 'pGetConfigNameFromConfigPair', 'static');
