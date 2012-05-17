function schema

% Copyright 2006 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codetree');

p = schema.prop(cls,'VariableTable','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(cls,'CodeRoot','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

p = schema.prop(cls,'Name','String');
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'String','String');
p.Visible = 'off';

p = schema.prop(cls,'ParentRef','handle');

schema.event(cls,'MomentoComplete');