function schema

% Copyright 2003-2006 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codeargument');

% Add new enumeration type
if (isempty(findtype('ArgumentType')))
  schema.EnumType('ArgumentType',{'PropertyName','PropertyValue','None'});
end

% Public properties
schema.prop(cls,'Name','MATLAB array');
schema.prop(cls,'Value','MATLAB array');
p = schema.prop(cls,'IsParameter','MATLAB array');
set(p,'FactoryValue',false);
p = schema.prop(cls,'Ignore','MATLAB array');
set(p,'FactoryValue',false);
schema.prop(cls,'Comment','MATLAB array');
p = schema.prop(cls,'ArgumentType','ArgumentType');
set(p,'FactoryValue','None');
p= schema.prop(cls,'DataTypeDescriptor','DataTypeDescriptor');
set(p,'FactoryValue','Auto');
p = schema.prop(cls,'IsOutputArgument','MATLAB array');
set(p,'Visible','on');
set(p,'FactoryValue',false);

% Hidden properties
% These properties should have package visibility but
% that can't be done in MATLAB now.
p = schema.prop(cls,'String','MATLAB array');
set(p,'Visible','off');
p = schema.prop(cls,'VariableTable','handle');
set(p,'Visible','off');
% A list of functions which use the variable as an output argument and a
% corresponding array of flags which determine whether the variable can be
% removed.
p = schema.prop(cls,'AllowRemovalList','MATLAB array');
set(p,'Visible','off');
p = schema.prop(cls,'FunctionList','MATLAB array');
set(p,'Visible','off');
set(p,'FactoryValue',handle([]));
% A reference to the active variable. Used by the
% code generator to determine whether output arguments may be removed.
p = schema.prop(cls,'ActiveVariable','handle');
set(p,'Visible','off');