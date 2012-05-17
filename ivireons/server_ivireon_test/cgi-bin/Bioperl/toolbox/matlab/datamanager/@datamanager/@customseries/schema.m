function schema
% Defines properties for @series


% Register class 
p = findpackage('datamanager');
c = schema.class(p,'customseries',findclass(p,'brushobj'));

p = schema.prop(c,'DataListener','MATLAB array');
p.AccessFlags.Serialize = 'off';
schema.prop(c,'BehaviorObject','MATLAB array');
schema.prop(c,'LinkBehaviorObject','MATLAB array');


