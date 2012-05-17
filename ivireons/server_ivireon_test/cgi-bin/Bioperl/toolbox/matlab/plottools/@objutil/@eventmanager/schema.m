function schema

% Copyright 2007-2009 The MathWorks, Inc.

hPk = findpackage('objutil');
cls = schema.class(hPk,'eventmanager');
% TargetListeners and RootNode are of type: MATLAB array to accommodate
% both UDD and MCOS listeners for the hg2 migration.
schema.prop(cls,'TargetListeners','MATLAB array');
schema.prop(cls,'RootNode','MATLAB array');
schema.prop(cls,'ExclusionTag','string');
schema.prop(cls,'Filter','MATLAB array');
prop = schema.prop(cls,'Enable','on/off');
prop.FactoryValue = 'on';
% Add a UseMCOS to avoid repeated calls to the feature function
prop = schema.prop(cls,'UseMCOS','bool');
prop.FactoryValue = false;
schema.event(cls,'NodeChanged');
schema.event(cls,'NewNode');