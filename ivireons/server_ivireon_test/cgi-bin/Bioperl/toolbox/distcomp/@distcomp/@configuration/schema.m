function schema
%SCHEMA defines the distcomp.configuration class
%

%   Copyright 2007-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:58:20 $ 


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('object');
hThisClass   = schema.class(hThisPackage, 'configuration', hParentClass);
% Declare the interface that this class implements.
hThisClass.JavaInterfaces = {'com.mathworks.toolbox.distcomp.configurations.Configuration'};

% Load the distcomp.configsection type before declaring properties of that type.
hThisPackage.findclass('configsection');

% The private property that stores the configuration name.
% We can access this name without triggering any set or get function.
p = schema.prop(hThisClass, 'ActualName', 'string'); 
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% The publicly visible property that forwards to ActualName.
p = schema.prop(hThisClass, 'Name', 'string'); 
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';
p.SetFunction = @pSetName;
p.GetFunction = @pGetName;

% A text description of the configuration
p = schema.prop(hThisClass, 'Description', 'string');
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(hThisClass, 'findResource', 'distcomp.configsection');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(hThisClass, 'scheduler', 'distcomp.configsection');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(hThisClass, 'job', 'distcomp.configsection');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(hThisClass, 'paralleljob', 'distcomp.configsection');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

p = schema.prop(hThisClass, 'task', 'distcomp.configsection');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';

%%%
% Declare static methods
schema.method(hThisClass, 'createNew', 'static');
schema.method(hThisClass, 'createNewFromScheduler', 'static');
schema.method(hThisClass, 'importFromFile', 'static');
schema.method(hThisClass, 'deleteConfig', 'static');
schema.method(hThisClass, 'getJavaReference', 'static');
schema.method(hThisClass, 'pMapSchedClassTypeToFRType', 'static');
schema.method(hThisClass, 'pMapFRTypeToSchedClassType', 'static');
schema.method(hThisClass, 'upgradeConfigValuesStructToCurrentVersion', 'static');
schema.method(hThisClass, 'loadconfigfile', 'static');


%%%%
% Declare the public methods for the interface that this class implements.
m = schema.method(hThisClass, 'clone');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle'}; % The handle is for the object itself.
m.signature.OutputTypes = {'string'};

m = schema.method(hThisClass, 'load');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle'}; 
m.signature.OutputTypes = {};

m = schema.method(hThisClass, 'save');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle'}; 
m.signature.OutputTypes = {};

m = schema.method(hThisClass, 'exportToFile');
m.signature.varargin = 'off';
m.signature.InputTypes = {'handle', 'string'}; 
m.signature.OutputTypes = {};
