function schema
% Defines properties for @series


% Register class 
p = findpackage('datamanager');
c = schema.class(p,'series',findclass(p,'brushobj'));

p = schema.prop(c,'SelectionListener','MATLAB array');
p.AccessFlags.Serialize = 'off';


