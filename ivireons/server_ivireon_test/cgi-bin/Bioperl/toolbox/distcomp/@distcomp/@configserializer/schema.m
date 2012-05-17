function schema
%SCHEMA defines the distcomp.configserializer class
%

%   Copyright 2007-2008 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('lockedobject');
hThisClass   = schema.class(hThisPackage, 'configserializer', hParentClass);
mlock;

% Stores a subset of the preferences as a struct.
p = schema.prop(hThisClass, 'Cache', 'MATLAB array'); 
p.AccessFlags.PublicSet = 'off';

% A counter that we increment every time we flush the cache so that clients can
% know when to update their respective cache.
p = schema.prop(hThisClass, 'CacheCounter', 'double'); 
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 0;

% Should only be 'normal' or 'deployed'
p = schema.prop(hThisClass, 'CacheInvariantMode', 'string'); 
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'normal';

% If false then the cache is never flushed to prefs
p = schema.prop(hThisClass, 'FlushCache', 'bool'); 
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = true;

% A struct vector where each struct contains the fields
% redo, undo, action, config
p = schema.prop(hThisClass, 'UndoList', 'MATLAB array'); 
p.AccessFlags.PublicSet = 'off';

% Index into UndoList.  Equals length(UndoList) if the user hasn't performed
% any undo's.  Points to the next action that we might undo.
p = schema.prop(hThisClass, 'UndoIndex', 'double'); 
p.AccessFlags.PublicSet = 'off';

% Implementations of 
% com.mathworks.toolbox.distcomp.configurations.ConfigUndoStateListener
% stored as handles.
p = schema.prop(hThisClass, 'UndoListeners', 'handle vector'); 
p.AccessFlags.PublicSet = 'off';

% The group name that is used when calling getpref and setpref. 
p = schema.prop(hThisClass, 'Group', 'string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'DCTConfigurations';


% Declare the static methods.
schema.method(hThisClass, 'clone', 'static');
schema.method(hThisClass, 'createNew', 'static');
schema.method(hThisClass, 'deleteConfig', 'static');
schema.method(hThisClass, 'getAllNames', 'static');
schema.method(hThisClass, 'getCacheCounter', 'static');
schema.method(hThisClass, 'getCurrentName', 'static');
schema.method(hThisClass, 'load', 'static');
schema.method(hThisClass, 'rename', 'static');
schema.method(hThisClass, 'save', 'static');
schema.method(hThisClass, 'setCurrentName', 'static');
schema.method(hThisClass, 'pGetInstance', 'static');
% Static methods that handle the undo support.
schema.method(hThisClass, 'undo', 'static');
schema.method(hThisClass, 'undoAll', 'static');
schema.method(hThisClass, 'redo', 'static');
schema.method(hThisClass, 'redoAll', 'static');
schema.method(hThisClass, 'addUndoStateListener', 'static');
schema.method(hThisClass, 'removeUndoStateListener', 'static');


