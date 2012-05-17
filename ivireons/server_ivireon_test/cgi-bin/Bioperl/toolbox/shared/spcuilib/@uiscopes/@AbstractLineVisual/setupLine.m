function setupLine(this, hVisParent)
%SETUP    Setup the line specific portions of the visualization area.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/03/08 21:44:09 $

setupAxes(this, hVisParent);
updateGrid(this);

visState = 'off';
if ~isempty(this.Application.DataSource) && ~screenMsg(this)
    visState = 'on';
end

% Turn the box property of the axes on.
hAxes = this.Axes;
set(hAxes, ...
    'Box', 'On', ...
    'Visible', visState)
updateYAxisLimits(this);
ylabel(hAxes, getPropValue(this, 'YLabel'));

% set(hVisParent, 'ResizeFcn', @(h, ev) onResize(this));

onResize(this);

% Add a context menu to the axes for autoscale.
addAxesContextMenu(this);

this.LimitListener = [...
    uiservices.addlistener(this.Axes, 'YLim',  'PostSet', @(h, ev) onYLimChange(this)) ...
    uiservices.addlistener(this.Axes, 'XLim',  'PostSet', @(h, ev) onXLimChange(this))]; % ...
%     uiservices.addlistener(this.Axes, 'XTick', 'PostSet', @(h, ev) onResize(this))];

% propertyChanged(this, 'Compact');

% -------------------------------------------------------------------------
function addAxesContextMenu(this)

this.AxesContextMenu = uicontextmenu('Parent', ancestor(this.Axes, 'figure'));
set(this.Axes, 'UIContextMenu', this.AxesContextMenu);

uimenu(this.AxesContextMenu, ...
    'Label', [this.Register.Name ' options'], ...
    'Tag', 'LineVisualOptions', ...
    'Callback', @(hcbo, ev) editOptions(this));

% -------------------------------------------------------------------------
function onXLimChange(this)

newXLim = get(this.Axes, 'XLim');
defaultXLim = calculateXLim(this);

% If the new xlim matches what the object defines as the 'Auto' limits,
% check the auto box.  Otherwise, uncheck the box and use the new limits as
% the min and max.
if isequal(defaultXLim, newXLim)
    setPropValue(this, 'AutoDisplayLimits', true, false);
else
    setPropValue(this, 'AutoDisplayLimits', false, ...
        'MinXLim', sprintf('%.20g', newXLim(1)), 'MaxXLim', sprintf('%.20g', newXLim(2)), false);
end

% -------------------------------------------------------------------------
function onYLimChange(this)

newYLim = get(this.Axes, 'YLim');
setPropValue(this, 'MinYLim', sprintf('%.20g', newYLim(1)), 'MaxYLim', sprintf('%.20g', newYLim(2)), true);

% -------------------------------------------------------------------------
function editOptions(this)

this.Application.ExtDriver.editOptions(this);

% [EOF]
