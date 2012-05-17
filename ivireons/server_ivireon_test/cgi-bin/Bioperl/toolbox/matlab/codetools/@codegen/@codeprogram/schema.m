function schema

% Copyright 2006 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codeprogram');

% Hidden properties
p = schema.prop(cls,'SubFunctionList','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p = schema.prop(cls,'FunctionTable','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

schema.event(cls,'TextComplete');
