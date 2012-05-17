function plugInGUI = createGUI(this)
%CREATEGUI Create the GUI components

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:38:05 $

b1 = uimgr.uitoggletool('ZoomIn');
b1.iconAppData = 'toggle_zoom_in';
b1.WidgetProperties = {'TooltipString', uiscopes.message('ZoomInTooltip'), ...
   'ClickedCallback',@(hcbo,ev) toggle(this,'ZoomIn'), ...
   'Tag', 'Exploration.ZoomIn'};

b2 = uimgr.uitoggletool('ZoomX');
b2.iconAppData = 'toggle_zoom_x';
b2.WidgetProperties = {'TooltipString', uiscopes.message('ZoomXTooltip'), ...
   'ClickedCallback',@(hcbo,ev) toggle(this,'ZoomX'), ...
   'Tag', 'Exploration.ZoomX'};

b3 = uimgr.uitoggletool('ZoomY');
b3.iconAppData = 'toggle_zoom_y';
b3.WidgetProperties = {'TooltipString', uiscopes.message('ZoomYTooltip'), ...
   'ClickedCallback',@(hcbo,ev) toggle(this,'ZoomY'), ...
   'Tag', 'Exploration.ZoomY'};

locZoomButtons = 2;
bZoom = uimgr.uibuttongroup('Zoom', locZoomButtons, b1, b2, b3);

mZoomIn = uimgr.spctogglemenu('ZoomIn', uiscopes.message('ZoomIn'));
mZoomIn.WidgetProperties = { ...
   'Callback', @(hcbo, ev) toggle(this, 'ZoomIn')};

mZoomX = uimgr.spctogglemenu('ZoomX', uiscopes.message('ZoomX'));
mZoomX.WidgetProperties = { ...
   'Callback', @(hcbo, ev) toggle(this, 'ZoomX')};

mZoomY = uimgr.spctogglemenu('ZoomY', uiscopes.message('ZoomY'));
mZoomY.WidgetProperties = { ...
   'Callback', @(hcbo, ev) toggle(this, 'ZoomY')};

mZoom = uimgr.uimenugroup('Zoom', 1, mZoomIn, mZoomX, mZoomY);

% Add state synchronizers
sync2way(mZoom, bZoom);

% Define the autoscale button and menus
bAutoscale = uimgr.uipushtool('Autoscale');
bAutoscale.IconAppData = 'fit_to_view';
bAutoscale.WidgetProperties = {'TooltipString', uiscopes.message('ScaleAxesLimitsTooltip'), ...
   'ClickedCallback',@(hcbo,ev) performAutoscale(this, true)};

autoMode = getPropValue(this, 'AutoscaleMode');

mPerformAutoscale = uimgr.uimenu('PerformAutoscale', uiscopes.message('ScaleAxesLimits'));
mPerformAutoscale.WidgetProperties = { ...
   'Accelerator', 'A', ...
   'Callback', @(hcbo, ev) performAutoscale(this, true)};

mAutoscaleMode = uimgr.spctogglemenu('EnableAutoscale', uiscopes.message('AutoScaleAxesLimits'));
mAutoscaleMode.WidgetProperties = { ...
   'Checked', uiservices.logicalToOnOff(strcmpi(autoMode, 'auto')), ...
   'Callback', @(hcbo, ev) toggleAutoscale(this, 'Auto')};
mAutoscaleMode.Visible = 'off';

mOnceAtStopMode = uimgr.spctogglemenu('EnableOnceAtStop', uiscopes.message('ScaleAxesLimitsAtStop'));
mOnceAtStopMode.WidgetProperties = { ...
   'Checked', uiservices.logicalToOnOff(strcmpi(autoMode, 'once at stop')), ...
   'Callback', @(hcbo, ev) toggleAutoscale(this, 'Once at stop')};
mOnceAtStopMode.Visible = 'off';

mOptions = uimgr.uimenu('AxesScalingOptions', uiscopes.message('AxesScalingOptions'));
mOptions.WidgetProperties = { ...
   'Callback', @(hcbo, ev) editOptions(this)};
mOptions.Visible = 'off';

% Add the autoscale menus to a group.
mAutoscale = uimgr.uimenugroup('Autoscale', ...
   mAutoscaleMode, mOnceAtStopMode, mPerformAutoscale, mOptions);

% Add the zoom and autoscale items together into groups so that they will
% stay next to each other when rendered.
mZoomAuto = uimgr.uimenugroup('ZoomAndAutoscale', 1, mZoom, mAutoscale);
bZoomAuto = uimgr.uibuttongroup('ZoomAndAutoscale', locZoomButtons, bZoom, bAutoscale);

plugInGUI = uimgr.uiinstaller({ ...
   bZoomAuto, 'Base/Toolbars/Playback'; ...
   mZoomAuto,  'Base/Menus/Tools'});

% -------------------------------------------------------------------------
function editOptions(this)

this.Application.ExtDriver.editOptions(this);

% -------------------------------------------------------------------------
function toggle(this, zmode)
% If we are toggling the current mode, then turn it off.  Otherwise, set
% the current mode to what we are toggling.

zoomObject = zoom(this.Application.Parent);
set(zoomObject, 'ActionPostCallback', @(h, ev) postZoomCallback(this))

if strcmpi(zmode, this.ZoomMode)
   this.ZoomMode = 'off';
else
   this.ZoomMode = zmode;
end

% -------------------------------------------------------------------------
function toggleAutoscale(this, newMode)

hProp = findProp(this, 'AutoscaleMode');
if strcmp(hProp.Value, newMode)
   hProp.Value = 'Manual';
else
   hProp.Value = newMode;
end

% -------------------------------------------------------------------------
function postZoomCallback(this)

if strcmp(getPropValue(this, 'AutoscaleMode'), 'Auto')
   setPropValue(this, 'AutoscaleMode', 'Manual');
end

% [EOF]
