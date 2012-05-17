function schema
%SCHEMA SISO Tool preferences schema

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.5.4.4 $  $Date: 2010/04/11 20:30:22 $

%---Register class
c = schema.class(findpackage('sisogui'),'sisoprefs');

%---Define properties

%---Units/Scales
schema.prop(c,'FrequencyUnits',        'string');
schema.prop(c,'FrequencyScale',        'string');
schema.prop(c,'MagnitudeUnits',        'string');
schema.prop(c,'MagnitudeScale',        'string');
schema.prop(c,'PhaseUnits',            'string');

%---Grids
schema.prop(c,'Grid',                  'string');

%---Fonts
schema.prop(c,'TitleFontSize',         'MATLAB array');
schema.prop(c,'TitleFontWeight',       'string');
schema.prop(c,'TitleFontAngle',        'string');
schema.prop(c,'XYLabelsFontSize',      'MATLAB array');
schema.prop(c,'XYLabelsFontWeight',    'string');
schema.prop(c,'XYLabelsFontAngle',     'string');
schema.prop(c,'AxesFontSize',          'MATLAB array');
schema.prop(c,'AxesFontWeight',        'string');
schema.prop(c,'AxesFontAngle',         'string');

%---Colors
schema.prop(c,'AxesForegroundColor',   'MATLAB array');
p = schema.prop(c,'RequirementColor', 'MATLAB array'); 
p.FactoryValue = [250   250   210]/255;

%---Siso Tool Options
schema.prop(c,'CompensatorFormat',     'string');
schema.prop(c,'ShowSystemPZ',          'string');
schema.prop(c,'LineStyle',             'MATLAB array');
p = schema.prop(c,'PadeOrder',         'MATLAB array'); % Pade order
set(p,'FactoryValue',2)

PadeOrderSelectionData = struct(...
   'PadeOrder', 2,...
   'Bandwidth', 10,...
   'UseBandwidth', false);
p = schema.prop(c,'PadeOrderSelectionData','MATLAB array'); % Pade Selection Data for GUI
set(p,'FactoryValue',PadeOrderSelectionData)


MultiModelFrequencySelectionData = struct(...
   'AutoModeData', logspace(-2,2,300),...
   'UserModeString', 'logspace(-2,2,300)',...
   'UserModeData', logspace(-2,2,300), ...
   'UseAutoMode', true);
p = schema.prop(c,'MultiModelFrequencySelectionData','MATLAB array'); % Frequency Selection Data for GUI
set(p,'FactoryValue',MultiModelFrequencySelectionData)


%---Phase Wrapping
schema.prop(c,'UnwrapPhase',           'string');

%---Handle to Figure containing target SISO Tool
schema.prop(c,'Target',                'MATLAB array');

%---UI Preferences
schema.prop(c,'UIFontSize',            'MATLAB array');

%---Handle to Toolbox Preferences
schema.prop(c,'ToolboxPreferences',    'handle');

%---Handle to Frame used to edit these preferences
schema.prop(c,'EditorFrame',           'MATLAB array');

%---Listeners
schema.prop(c,'Listeners',             'MATLAB array'); % Property to ListenerManager


