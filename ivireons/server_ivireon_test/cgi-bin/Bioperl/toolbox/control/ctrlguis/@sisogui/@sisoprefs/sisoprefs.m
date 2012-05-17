function h = sisoprefs(Target)
%SISOPREFS  SISO Tool preferences object constructor
%
%   TARGET is an instance of the @sisotool root class.

%   Author(s): A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.21.4.6 $  $Date: 2010/05/10 16:59:30 $

%---Create class instance
h = sisogui.sisoprefs;
h.Listeners = controllibutils.ListenerManager;

%---Get a copy of the toolbox preferences
h.ToolboxPreferences    = cstprefs.tbxprefs;

%---Copy relevant toolbox preferences
h.FrequencyUnits        = h.ToolboxPreferences.FrequencyUnits;
h.FrequencyScale        = h.ToolboxPreferences.FrequencyScale;
h.MagnitudeUnits        = h.ToolboxPreferences.MagnitudeUnits;
h.MagnitudeScale        = h.ToolboxPreferences.MagnitudeScale;
h.PhaseUnits            = h.ToolboxPreferences.PhaseUnits;
h.Grid                  = h.ToolboxPreferences.Grid;
h.TitleFontSize         = h.ToolboxPreferences.TitleFontSize;
h.TitleFontWeight       = h.ToolboxPreferences.TitleFontWeight;
h.TitleFontAngle        = h.ToolboxPreferences.TitleFontAngle;
h.XYLabelsFontSize      = h.ToolboxPreferences.XYLabelsFontSize;
h.XYLabelsFontWeight    = h.ToolboxPreferences.XYLabelsFontWeight;
h.XYLabelsFontAngle     = h.ToolboxPreferences.XYLabelsFontAngle;
h.AxesFontSize          = h.ToolboxPreferences.AxesFontSize;
h.AxesFontWeight        = h.ToolboxPreferences.AxesFontWeight;
h.AxesFontAngle         = h.ToolboxPreferences.AxesFontAngle;
h.AxesForegroundColor   = h.ToolboxPreferences.AxesForegroundColor;
h.CompensatorFormat     = h.ToolboxPreferences.CompensatorFormat;
h.ShowSystemPZ          = h.ToolboxPreferences.ShowSystemPZ;
h.LineStyle             = h.ToolboxPreferences.SISOToolStyle;
h.UnwrapPhase           = h.ToolboxPreferences.UnwrapPhase;
h.Target                = Target;
h.UIFontSize            = h.ToolboxPreferences.UIFontSize;
h.EditorFrame           = [];

%---Install listeners
pu = [findprop(h,'FrequencyUnits');...
      findprop(h,'MagnitudeUnits');...
      findprop(h,'PhaseUnits')];
ps = [findprop(h,'FrequencyScale');...
      findprop(h,'MagnitudeScale')];
psty = [findprop(h,'TitleFontSize');...
      findprop(h,'TitleFontSize');...
      findprop(h,'TitleFontWeight');...
      findprop(h,'TitleFontAngle');...
      findprop(h,'XYLabelsFontSize');...
      findprop(h,'XYLabelsFontWeight');...
      findprop(h,'XYLabelsFontAngle');...
      findprop(h,'AxesFontSize');...
      findprop(h,'AxesFontWeight');...
      findprop(h,'AxesFontAngle')];
L1 = [...
        handle.listener(h,ps,'PropertyPostSet',@localSetScale);...
        handle.listener(h,pu,'PropertyPostSet',@localSetUnits);...
        handle.listener(h,psty,'PropertyPostSet',@localSetStyle);...
        handle.listener(h,findprop(h,'Grid'),'PropertyPostSet',@localSetGrid);...
        handle.listener(h,findprop(h,'AxesForegroundColor'),...
        'PropertyPostSet',{@localSetEditor 'LabelColor'});...
        handle.listener(h,findprop(h,'LineStyle'),...
        'PropertyPostSet',{@localSetEditor 'LineStyle'});...
        handle.listener(h,findprop(h,'CompensatorFormat'),...
        'PropertyPostSet',@localChangeFormat);...
        handle.listener(h,findprop(h,'ShowSystemPZ'),...
        'PropertyPostSet',@localShowSystemPZ)];
    
L2 = addlistener(Target.Figure,'CSHelpMode','PostSet',@LocalSwitchMode);

L3 = handle.listener(Target.LoopData,'ConfigChanged',@(es,ed) LocalConfigChanged(h));
    
h.Listeners.deleteListeners;
h.Listeners.addListeners(L1);
h.Listeners.addListeners(L2);
h.Listeners.addListeners(L3);


%-------------------- Listeners callbacks --------------------------------

% Set units (for all editors)
function localSetUnits(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
% Graphical editors
Editors = sisodb.PlotEditors;
for ct=1:length(Editors)
   Editors(ct).setunits(eventSrc.Name,eventData.NewValue)
end
% Text editors
if strcmp(eventSrc.Name,'FrequencyUnits') && ~isempty(sisodb.TextEditors)
   set(sisodb.TextEditors(1),'FrequencyUnits',eventData.NewValue);
end


% Set scales
function localSetScale(eventSrc,eventData)
Editors = eventData.AffectedObject.Target.PlotEditors;
for ct=1:length(Editors)
   Editors(ct).setscale(eventSrc.Name,eventData.NewValue)
end    


% Set editor property (for all editors)
function localSetEditor(eventSrc,eventData,EditorProperty)
sisodb = eventData.AffectedObject.Target;
set(sisodb.PlotEditors,EditorProperty,eventData.NewValue);


% Set grid (for all editors)
function localSetGrid(eventSrc,eventData)
Editors = eventData.AffectedObject.Target.PlotEditors;
for ct=1:length(Editors)
   Editors(ct).Axes.Grid = eventData.NewValue;
end


% Set label or axes style
function localSetStyle(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
switch lower(eventSrc.Name([1 2]))
case 'ti'
   % Title related
   Property = strrep(eventSrc.Name,'Title','');
   for ct=1:length(sisodb.PlotEditors)
      set(sisodb.PlotEditors(ct).Axes.TitleStyle,Property,eventData.NewValue);
   end
case 'xy'
   % XY label related
   Property = strrep(eventSrc.Name,'XYLabels','');
   for ct=1:length(sisodb.PlotEditors)
      set(sisodb.PlotEditors(ct).Axes.XLabelStyle,Property,eventData.NewValue);
      set(sisodb.PlotEditors(ct).Axes.YLabelStyle,Property,eventData.NewValue);
   end
case 'ax'
   % Axes style
   Property = strrep(eventSrc.Name,'Axes','');
   for ct=1:length(sisodb.PlotEditors)
      set(sisodb.PlotEditors(ct).Axes.AxesStyle,Property,eventData.NewValue);
   end
end    


% Set system pole/zero visibility 
function localShowSystemPZ(eventSrc,eventData)
Editors = eventData.AffectedObject.Target.PlotEditors;
for ct=1:length(Editors)
   if isa(Editors(ct),'sisogui.bodeditorOL') || isa(Editors(ct),'sisogui.nicholseditor')
      Editors(ct).ShowSystemPZ = eventData.NewValue;
   end
end


function localChangeFormat(eventSrc,eventData)
% Change compensator format
LoopData = eventData.AffectedObject.Target.LoopData;
set(LoopData.C,'Format',eventData.NewValue);
% Update all plots when changing format (the "normalized" data used in the root locus
% and bode editors becomes stale, causing bad behaviors when changing format, then
% modifying the loop gain, see geck 88273)
LoopData.dataevent('all')


% Enable/disable java GUI based on CSHelpMode
function LocalSwitchMode(eventSrc,eventData)
sisodb = eventData.AffectedObject.UserData;
if ~isempty(sisodb.Preferences.EditorFrame)
   if strcmpi(eventData.NewValue,'on')
      sisodb.Preferences.EditorFrame.setEnabled(false)
   else
      sisodb.Preferences.EditorFrame.setEnabled(true)
   end
end

function LocalConfigChanged(this)
this.MultiModelFrequencySelectionData.AutoModeData = [];
