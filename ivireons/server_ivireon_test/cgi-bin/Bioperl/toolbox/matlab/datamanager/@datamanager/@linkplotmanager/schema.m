function schema
% Defines properties for @linkplotmanager

mlock;

% Register class 
c = schema.class(findpackage('datamanager'),'linkplotmanager');

% Structure of variables and selections
schema.prop(c,'LinkListener','MATLAB array');
schema.prop(c,'Figures','MATLAB array');
p = schema.prop(c,'UndoRedoBlocked','bool');
p.FactoryValue = false;
p = schema.prop(c,'DebugMode','bool');
p.FactoryValue = false;