function setupAxes(this, hVisParent)
%SETUPAXES Setup the axes

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/01/25 22:47:22 $

hAxes = axes( ...
    'tag', 'VisualAxes',...
    'parent',hVisParent, ...
    'OuterPosition',[0 0 1 1], ...
    'vis','off', ...
    'layer','bottom',...
    'nextplot','add', ...
    'drawmode','fast');

axesProps = getPropValue(this, 'AxesProperties');
if ~isempty(axesProps)
    
    xlabel(hAxes, axesProps.XLabel);
    ylabel(hAxes, axesProps.YLabel);
    zlabel(hAxes, axesProps.ZLabel);
    title(hAxes, axesProps.Title);
    
    set(hAxes, rmfield(axesProps, {'XLabel', 'YLabel', 'ZLabel', 'Title'}));
end

this.Axes = hAxes;

hgaddbehavior(hAxes, uiservices.getPlotEditBehavior('select'));

% Text display to use for screen message. Use screenMsg method to activate.
% Use FixedWidthFontName on windows, but Courier on Unix/Linux/Mac so that
% we can change the font size.
if ispc
    fontName = get(0,'FixedWidthFontName');
else
    fontName = 'Courier';
end
this.MessageText = text( ...
    'parent',      hAxes, ...
    'Tag',         'ScreenMessage', ...
    'units',       'norm', ...
    'horizontal',  'center', ...
    'interpreter', 'none', ...
    'vertical',    'middle', ...
    'position',    [.5 .5],...
    'string',      '', ...
    'FontName',    fontName, ...
    'FontSize',    16, ...
    'Visible',     'off');

hgaddbehavior(this.MessageText, uiservices.getPlotEditBehavior('disabled'));

% If we have anything in the ScreenMessageCache, display it.
if ~isempty(this.ScreenMessageCache)
    screenMsg(this, this.ScreenMessageCache);
    this.ScreenMessageCache = '';
end

% Set the visualization area's resize function to update the screen message
this.VisualResizedListener = ...
    handle.listener(this.Application, 'VisualResized', makeResizeFcn(this));

% -------------------------------------------------------------------------
function cb = makeResizeFcn(this)

cb = @(h, ev) onVisualResized(this, ev);

% [EOF]
