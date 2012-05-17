function schema
% Defines properties for @brushmanager

mlock;

% Register class 
c = schema.class(findpackage('datamanager'),'brushmanager');

% Structure of variables and selections
schema.prop(c,'SelectionTable','MATLAB array');
schema.prop(c,'VariableNames','MATLAB array');
schema.prop(c,'DebugMFiles','MATLAB array');
schema.prop(c,'DebugFunctionNames','MATLAB array');
schema.prop(c,'ArrayEditorVariables','MATLAB array');
schema.prop(c,'ArrayEditorSubStrings','MATLAB array');
schema.prop(c,'UndoData','MATLAB array');
schema.prop(c,'ApplicationData','MATLAB array');
% Add a UseMCOS to avoid repeated calls to the feature function
prop = schema.prop(c,'UseMCOS','bool');
prop.FactoryValue = false;





