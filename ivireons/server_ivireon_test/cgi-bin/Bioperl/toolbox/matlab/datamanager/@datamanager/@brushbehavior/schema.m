function schema

% Copyright 2007 The MathWorks, Inc.

hPk = findpackage('datamanager');
cls = schema.class(hPk,'brushbehavior');

schema.prop(cls,'DrawFcn','MATLAB array');
schema.prop(cls,'LinkBrushFcn','MATLAB array');
schema.prop(cls,'UserData','MATLAB array');
p = schema.prop(cls,'Enable','bool');
p.FactoryValue = true;

% In general DataManager behavior objects will not serialize since their
% UDD state objects will not serialize
p = schema.prop(cls,'Serialize','MATLAB array');
p.FactoryValue = false;
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'Brush';