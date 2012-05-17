function schema
% Defines properties for @series


% Register class 
c = schema.class(findpackage('datamanager'),'brushobj');

% Don;t serialize properties since objects will be invalid when pasted
p = schema.prop(c,'HGHandle','MATLAB array');
p.FactoryValue = [];
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'ContextMenu','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'SelectionListener','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'DeleteListener','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'DataListener','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'SelectionHandles','MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c,'CleanupListener','MATLAB array');
p.AccessFlags.Serialize = 'off';

