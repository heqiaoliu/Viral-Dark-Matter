function schema

% Copyright 2007 The MathWorks, Inc.

hPk = findpackage('objutil');
cls = schema.class(hPk,'plottoolsbehavior');

% Property Editor java panel class and custom UDD state object
schema.prop(cls,'PropEditPanelJavaClass','string');
schema.prop(cls,'PropEditPanelObject','handle');

p = schema.prop(cls,'Enable','bool');
p.FactoryValue = true;

% In general PlotTools behavior objects will not serialize since their
% UDD state objects will not serialize
p = schema.prop(cls,'Serialize','MATLAB array');
p.FactoryValue = false;
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'PlotTools';

% Turn on Plot Edit mode when the plot tools are opened
p = schema.prop(cls,'ActivatePlotEditOnOpen','bool');
p.FactoryValue = true;

% g620127
mlock;
