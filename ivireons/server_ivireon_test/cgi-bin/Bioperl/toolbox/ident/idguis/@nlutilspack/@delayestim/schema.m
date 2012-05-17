function schema
% SCHEMA  Defines properties for delayestim class.
%
% Inspect time plot and impulse response plots for input delay.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:55:02 $

% Construct class
hCreateInPackage   = findpackage('nlutilspack');
c = schema.class(hCreateInPackage, 'delayestim');

p = schema.prop(c,'isDark','bool');
cols = get(0, 'defaultAxesColor');
if (sum(cols) < 1.5)
    p.FactoryValue = true;
else
    p.FactoryValue = false;
end

% the figure 
schema.prop(c,'Figure','handle');

% data 
p = schema.prop(c,'Data','MATLAB array');
p.FactoryValue = struct('EstData',[],'isMultiExp',false,...
    'Orders',struct('na',3,'nb',2),'TimeUnit','');

p = schema.prop(c,'Current','MATLAB array');
p.FactoryValue = struct('ExpNumber',1,'InputNumber',1,'OutputNumber',1,'WorkingData',[],...
    'Mode','Time');

p = schema.prop(c,'TimeInfo','MATLAB array');
p.FactoryValue = struct('DelayStr','','MoveLines',[],'Axes',[],'InstrLabel',[],...
    'Message','','Delay',0);

p = schema.prop(c,'ImpulseInfo','MATLAB array');
p.FactoryValue = struct('DelayStr','','MoveLines',[],'Axes',[],'InstrLabel',[],...
    'Message','','Delay',0);

% panels
p = schema.prop(c,'Panels','MATLAB array');
p.FactoryValue = struct('Top',[],'Main',[],'Bottom',[]);

% Top panel contents
p = schema.prop(c,'UIs','MATLAB array');
p.FactoryValue = struct('uCombo',[],'yCombo',[],'CloseBtn',[],'HelpBtn',[],...
    'DelayLabel',[],'InsertBtn',[]);

% caller object
schema.prop(c,'Caller','MATLAB array');

% listeners
schema.prop(c,'Listeners','handle vector');
