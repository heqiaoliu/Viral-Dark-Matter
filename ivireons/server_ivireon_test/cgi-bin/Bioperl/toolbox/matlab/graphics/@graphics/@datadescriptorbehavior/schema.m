function schema

% Copyright 2004 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'datadescriptorbehavior');

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'DataDescriptor';

p = schema.prop(cls,'Enable','MATLAB array');
p.FactoryValue = true;

