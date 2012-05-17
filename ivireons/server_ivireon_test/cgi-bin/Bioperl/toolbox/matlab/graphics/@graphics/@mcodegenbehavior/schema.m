function schema

% Copyright 2003-2006 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'mcodegenbehavior');

p = schema.prop(cls,'Enable','bool');
p.FactoryValue = true;

p = schema.prop(cls,'Serialize','MATLAB array');
p.FactoryValue = true;
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'MCodeGeneration';
p.AccessFlags.Serialize = 'off';

schema.prop(cls,'MCodeConstructorFcn','MATLAB callback');
schema.prop(cls,'MCodeIgnoreHandleFcn','MATLAB callback');