function schema
%SCHEMA  Define properties for @tscollection handle class.

%   Copyright 2004-2006 The MathWorks, Inc.

p = findpackage('tsdata');
c = schema.class(p,'tscollection');

schema.prop(c,'TsValue','MATLAB array');
p = schema.prop(c,'Name','string');  
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Name');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Name');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'Time','MATLAB array');
p.GetFunction = @(es,ed) getInternalProp(es,ed,'Time');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'Time');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'TimeInfo','MATLAB array'); 
p.GetFunction = @(es,ed) getInternalProp(es,ed,'TimeInfo');
p.SetFunction = @(es,ed) setInternalProp(es,ed,'TimeInfo');
p.AccessFlags.Init = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'DataChangeEventsEnabled', 'bool');
p.FactoryValue = true;

% define events
schema.event(c,'datachange'); 