function schema
% Defines properties for derived timeplot class.

%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2005/06/27 23:01:23 $

% Register class 
p = findpackage('tsguis');
pparent = findpackage('wavepack');
% Register class 
c = schema.class(p,'timeplot',findclass(pparent,'timeplot'));

% Data selection mode
if isempty(findtype('tsSelectionMode'))
    schema.EnumType('tsSelectionMode', ...
        {'None', 'DataSelect', 'TimeseriesTranslate','TimeseriesTranslating', ...
        'TimeseriesScale','TimeseriesScaling','TimeSelect','TimeSelecting'});
end
p = schema.prop(c,'State','tsSelectionMode');
p.FactoryValue = 'None';
schema.prop(c, 'Uistate', 'MATLAB array');

%% Absolute reference time for absolute time plots
schema.prop(c, 'Startdate', 'string');

%% AxesTable handle for Proeprty Editor Panels
schema.prop(c, 'PropEditor', 'MATLAB array');

%% Absolute/relative status of the time vector
p = schema.prop(c, 'Absolutetime', 'on/off');
p.FactoryValue = 'off';
p.AccessFlags.PublicSet = 'off';
p.GetFunction = @localGetAbsTime;

%% Time units for this plot
if isempty(findtype('TimeUnits'))
    schema.EnumType('TimeUnits', {'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'});
end
p = schema.prop(c, 'TimeUnits','TimeUnits');
p.Factoryvalue = 'seconds';

%% Absolute time display format
p = schema.prop(c, 'TimeFormat','string');
%p.Factoryvalue = 'dd-mmm-yyyy HH:MM:SS';

%% Store parent @tsseriesnode. This is needed so that context menus 
%% can invoke dialogs which are aware of sibling nodes in the htree
schema.prop(c, 'Parent', 'handle');

%% Storage for selected waveform
% Start point is the x-index of the dragged point
% Centroid is the y-mean of the time series being scaled
% Arrowpressed indicates an arrow key has been pressed, disabling mouse
% scaling
p = schema.prop(c, 'SelectionStruct', 'MATLAB array');
p.FactoryValue = struct('Selectedwave',[],'Arrowpressed',[],...
    'StartPoint',[],'Centroid',[],'XLimMode','','YLimMode','','History',{{}});

%% Link prop for time axies
schema.prop(c,'xaxeslink','MATLAB array');


%% Get function for absoluteTime property. 
function outData = localGetAbsTime(eventSrc,eventData)

if ~isempty(eventSrc.StartDate)
    outData = 'on';
else
    outData = 'off';
end