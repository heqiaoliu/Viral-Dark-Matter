function onResize(this)
%ONRESIZE Handle the resize of the visualization area

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 16:09:38 $

% Based on code originally from sdspfscope2.

% Remove the old ticks.
oldXTicks = this.InsideXTicks;
oldYTicks = this.InsideYTicks;
delete(oldXTicks(ishghandle(oldXTicks)));
delete(oldYTicks(ishghandle(oldYTicks)));

hAxes = this.Axes;

delete(findobj(hAxes, 'Tag', 'AbstractLineVisualInsideXTick'));
delete(findobj(hAxes, 'Tag', 'AbstractLineVisualInsideYTick'));

% There's nothing to do if we're not in the compact display.
if ~this.findProp('Compact').Value;
    return;
end

xtick = get(hAxes, 'XTick');
ytick = get(hAxes, 'YTick');
xlim  = get(hAxes, 'XLim');
ylim  = get(hAxes, 'YLim');

% If there's only 1 tick, use its value for spacing, otherwise use the
% distance between the first and second.
if length(xtick) == 1
    dx = xtick;
else
    dx = xtick(2)-xtick(1);
end

if length(ytick) == 1
    dy = ytick;
else
    dy = ytick(2)-ytick(1);
end

% Remove any ticks that are too close to the edges.
if isApproxEqual(xlim(1),xtick(1)),
    xtick(1)=[];
end
if isApproxEqual(xlim(2),xtick(end)),
    xtick(end)=[];
end

if isApproxEqual(ylim(1),ytick(1)),
    ytick(1)=[];
end
if isApproxEqual(ylim(2),ytick(end)),
    ytick(end)=[];
end

% Calculate where to put the labels.
xForY = repmat(xlim(1)+dx*.05, 1, numel(ytick));
yForX = repmat(ylim(1)+dy*.05, 1, numel(xtick));

% Generate the xtick strings.
xStr = cell(1,length(xtick));
for indx = 1:length(xtick)
    xStr{indx} = sprintf('%g', xtick(indx));  % don't use + sign
end

% Generate the ytick strings.
yStr = cell(1,length(ytick));
for indx = 1:length(ytick)
    yStr{indx} = sprintf('%+g', ytick(indx));  % use + sign
end

pvPairs = {'Color', [.5 .5 .5], 'Parent', hAxes};

visState = get(this.Axes, 'Visible');

this.InsideXTick = text(xtick, yForX, xStr, pvPairs{:}, ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','bottom', ...
    'Tag', 'AbstractLineVisualInsideXTick', ...
    'Visible', visState)';
this.InsideYTick = text(xForY, ytick, yStr, pvPairs{:}, ...
    'Vertical', 'Base', ...
    'Tag', 'AbstractLineVisualInsideYTick', ...
    'Visible', visState)';

% ------------------------------------------------------------
function z = isApproxEqual(x,y)

% different if difference in the two numbers
% is more than 1 percent of the maximum of
% the two:
tol = max(abs(x),abs(y)) * 1e-2;
z = (abs(x-y) < tol);

% [EOF]
