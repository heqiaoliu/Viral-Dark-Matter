function schema
% SCHEMA  Defines properties for idnlhwplot class

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/08/01 12:23:02 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('plotpack');

% Construct class
c = schema.class(hCreateInPackage, 'idnlhwplot');

%schema.prop(c,'WindowID','string'); %for tagging GUI plot windows in CED
p = schema.prop(c,'isDark','bool');
cols = get(0, 'defaultAxesColor');
if (sum(cols) < 1.5)
    p.FactoryValue = true;
else
    p.FactoryValue = false;
end

p = schema.prop(c,'isGUI','bool');
p.FactoryValue = false;
schema.prop(c,'Figure','handle');
schema.prop(c,'TopPanel','handle');
schema.prop(c,'MainPanels','handle vector');
schema.prop(c,'PatchHandles','handle vector');

p = schema.prop(c,'UIs','MATLAB array');
p.FactoryValue = struct('InputCombo',[],'OutputCombo',[],'LinearCombo',[],...
    'LinearPlotTypeText',[],'LinearPlotTypeCombo',[],'CollapseButton',[],...
    'TopText',[]);

p = schema.prop(c,'IONames','MATLAB array');
p.FactoryValue = struct('u',{{}},'y',{{}});

% plot contains one or more models; each model's info is stored in its
% ModelData object (an instance of @nlhwdata)
schema.prop(c,'ModelData','handle vector');

% current state of UIs
p = schema.prop(c,'Current','MATLAB array');
currentinfo = struct('InputComboValue',1,'OutputComboValue',1,...
    'LinearComboValue',1,'LinearPlotTypeComboValue',1,'Block','input',...
    'AxesHandles',struct('input',[],'step',[],'bode',[],'impulse',[],...
    'pzmap',[],'output',[]));

p.FactoryValue = currentinfo;

p = schema.prop(c,'NumSample','double');
p.FactoryValue = 100;

p = schema.prop(c,'Range','MATLAB array');
p.FactoryValue = struct('Input',[],'Output',[]);

schema.prop(c,'Time','MATLAB array');

p = schema.prop(c,'TimeUnits','MATLAB array');
p.FactoryValue = {};

schema.prop(c,'Frequency','MATLAB array');

% show/hide legend
p = schema.prop(c,'showLegend','bool');
p.FactoryValue = true;

% listener to model change events (add/remove/rename/activated/deactivated)
% also: axes limit change listeners
schema.prop(c,'Listeners','handle vector');
