function schema
% Constructor for a code routine

% Copyright 2006 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'coderoutine');

% Hidden properties
schema.prop(cls,'Name','MATLAB array');
p = schema.prop(cls,'String','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'Argout','MATLAB array');
p.Visible = 'off';
p.FactoryValue = {};
p = schema.prop(cls,'Argin','MATLAB array');
p.Visible = 'off';
p.FactoryValue = {};
p = schema.prop(cls,'Functions','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'SubFunctionList','MATLAB array');
p.Visible = 'off';
p = schema.prop(cls,'VariableTable','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
schema.prop(cls,'ParentRef','handle');
schema.prop(cls,'Comment','String');
schema.prop(cls,'SeeAlsoList','MATLAB array');