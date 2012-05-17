function XYZExtents = getXYZExtents(this)
%GETXYZEXTENTS Get the xYZExtents.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/29 16:09:35 $

hAxes = this.Axes;
hAll = this.Lines;

if isempty(hAll)
    XYZExtents = [NaN NaN; NaN NaN; NaN NaN];
    return;
end

currentXLim = get(hAxes, 'XLim');

% Calculate the minimum and maximum limits based on the ydata.
ymin = inf;
ymax = -inf;
xmin = inf;
xmax = -inf;
isXLimAuto = strcmp(get(hAxes, 'XLimMode'), 'auto');
xdata = get(hAll, 'XData');
ydata = get(hAll, 'YData');

if ~iscell(xdata)
    xdata = {xdata};
    ydata = {ydata};
end
for indx = 1:numel(hAll)
    
    if isempty(xdata{indx})
        xdata{indx} = NaN;
    end
    if isempty(ydata{indx})
        ydata{indx} = NaN;
    end
    
    % If we are autoscaling the xaxis, find the min and max of all the
    % xdata.  If we are not autoscaling the xaxis, convert the ydata to be
    % just the ydata that is visible between xlim(1) and xlim(2).
    xmin = min(xmin, min(xdata{indx}(:)));
    xmax = max(xmax, max(xdata{indx}(:)));
    if ~isXLimAuto
        % If the XLimMode is set to auto, then we do not want to bother
        % checking the xlim values.  Assume that everything is visible and
        % do not spend any more time here.
        
        % Find the indices of the first and last visible point.
        minIndex = find(xdata{indx} >= currentXLim(1), 1);
        maxIndex = find(xdata{indx} <= currentXLim(2), 1, 'last');
        
        % Remove the extra points from ydata.
        ydata{indx} = ydata{indx}(minIndex:maxIndex);
    end
    
    % Calculate the minimum and maximum ydata.
    ymin = min(ymin, min(ydata{indx}(:)));
    ymax = max(ymax, max(ydata{indx}(:)));
end
if ymin == inf
    ymin = NaN;
end
if ymax == -inf;
    ymax = NaN;
end

XYZExtents = [xmin xmax; ymin ymax; -1 1];

% [EOF]
