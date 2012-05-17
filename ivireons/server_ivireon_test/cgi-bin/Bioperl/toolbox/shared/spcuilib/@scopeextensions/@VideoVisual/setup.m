function setup(this, hVisParent)
%SETUP Setup the Visual

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/04/21 21:49:31 $

setupAxes(this, hVisParent);

defaultN = 1;

% Setup the default axes for video display.
set(this.Axes, ...
    'tag', 'VideoAxes',...
    'parent',hVisParent, ...
    'pos',[0 0 1 1], ...
    'vis','off', ...
    'xlim',[0.5 0.5+defaultN], ...
    'ylim', [0.5 0.5+defaultN], ...
    'ydir','reverse', ...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'climmode','manual',...
    'alimmode','manual',...
    'layer','bottom',...
    'nextplot','add', ...
    'dataaspectratio',[1 1 1], ...
    'drawmode','fast');

visState = 'off';
if ~isempty(this.Application.DataSource) && ~screenMsg(this)
    visState = 'on';
end

% Create the image object.
this.Image = image(...
    'xdata', [1 1], ...
    'ydata', [1 1], ...
    'tag', 'VideoImage',...
    'parent',this.Axes, ...
    'Visible', visState, ...
    'cdata',zeros(defaultN,defaultN,'uint8'));

hgaddbehavior(this.Image, uiservices.getPlotEditBehavior('select'));

if ~feature('hgusingmatlabclasses')
    set(this.Image, 'EraseMode', 'none');
end

% Create the color map dialog.  We defer the creation of the colormap to
% here so that it can update the figure's colormap now that it is rendered.
this.ColorMap = scopeextensions.ColorMap(this);
updateColorMap(this);
connect(this, this.ColorMap, 'down');

% Listen for changes in colormap scaling
this.ScalingChangedListener = handle.listener(this.Colormap, ...
    'ScalingChanged', @(hMap, ev) postColorMapUpdate(this));

% Update tooltip to react to current data format settings
hDims = this.Application.getGUI.findwidget({'StatusBar','StdOpts','scopeextensions.VideoVisual Dims'});
hDims.Tooltip = sprintf('Color Format: Height x Width');

% Update callback to open video info dialog
hDims.Callback = @(hco,ev) show(this.VideoInfo, true);

this.ScrollPanel = imscrollpanel(get(this.Axes, 'Parent'), this.Image);
set(this.ScrollPanel, 'units', 'normalized', ...
    'HitTest', 'Off');
set(findall(this.ScrollPanel, 'tag', 'hScrollable'),'HitTest', 'off');

% Update extension
this.Extension = this.Application.getExtInst('Tools:Image Navigation Tools');

% When there is a datasource use it to help setup the scrollpanel,
% otherwise this will get called from a listener.
if ~isempty(this.Application.DataSource)
    dataSourceChanged(this);
end

% [EOF]
