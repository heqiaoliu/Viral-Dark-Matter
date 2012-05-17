function schema
% SCHEMA  Defines properties for idnlarxplot class

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:25 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('plotpack');

% Construct class
c = schema.class(hCreateInPackage, 'idnlarxplot');

%schema.prop(c,'WindowID','string'); %for tagging GUI plot windows in CED
p = schema.prop(c,'isDark','bool');
cols = get(0, 'defaultAxesColor');
if (sum(cols) < 1.5)
    p.FactoryValue = true;
else
    p.FactoryValue = false;
end

p = schema.prop(c,'NumSample','double');
p.FactoryValue = 20;

p = schema.prop(c,'isGUI','bool');
p.FactoryValue = false;

schema.prop(c,'Figure','handle');
schema.prop(c,'TopPanel','handle');
schema.prop(c,'MainPanels','handle vector');
schema.prop(c,'ControlPanel','handle');

p = schema.prop(c,'UIs','MATLAB array');
p.FactoryValue = struct('OutputCombo',[],'CollapseButton',[],'CurrentOutputLabel','',...
    'Reg1Combo',[],'Reg1RangeEdit',[],'Reg2Combo',[],'Reg2RangeEdit',[],...
    'CenterPointButton',[],'ApplyButton',[]);

p = schema.prop(c,'Current','MATLAB array');
p.FactoryValue = struct('OutputComboValue',1,'MultiOutputAxesTag','');

% per-output data as a struct array with an element struct for each output
p = schema.prop(c,'RegressorData','MATLAB array');
p.FactoryValue = handle([]);
p.AccessFlags.AbortSet = 'off';

schema.prop(c,'CenterPointTable',...
    'com.mathworks.toolbox.ident.nlidutils.centerpointtable');

schema.prop(c,'OutputNames','MATLAB array');

% vector of nlarxdata object handles
schema.prop(c,'ModelData','handle vector');

% show/hide legend
p = schema.prop(c,'showLegend','bool');
p.FactoryValue = true;

% listener to model change events 
% (add/remove/rename/activate/deactivate/change color)
schema.prop(c,'Listener','handle vector');
