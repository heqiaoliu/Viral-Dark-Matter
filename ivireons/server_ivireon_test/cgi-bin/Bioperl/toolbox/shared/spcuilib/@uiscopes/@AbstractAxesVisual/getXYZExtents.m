function XYZExtents = getXYZExtents(this)
%GETXYZEXTENTS Get the xYZExtents.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/16 22:34:35 $

hAxes = this.Axes;
hAll = findobj(hAxes, '-property', 'YData', 'Visible', 'on');

if isempty(hAll)
    XYZExtents = [NaN NaN; NaN NaN; NaN NaN];
    return;
end

currentXLim = get(hAxes, 'XLim');

% Calculate the minimum and maximum limits based on the ydata.
ymin = inf;
ymax = -inf;
isXLimAuto = strcmp(get(hAxes, 'XLimMode'), 'auto');
xmin = inf;
xmax = -inf;
for indx = 1:numel(hAll)
    ydata = get(hAll(indx), 'YData');
    xdata = get(hAll(indx), 'XData');
    
    % If we are autoscaling the xaxis, find the min and max of all the
    % xdata.  If we are not autoscaling the xaxis, convert the ydata to be
    % just the ydata that is visible between xlim(1) and xlim(2).
    xmin = min(xmin, min(xdata(:)));
    xmax = max(xmax, max(xdata(:)));
    if ~isXLimAuto
        % If the XLimMode is set to auto, then we do not want to bother
        % checking the xlim values.  Assume that everything is visible and
        % do not spend any more time here.
        
        % Find the indices of the first and last visible point.
        minIndex = find(xdata >= currentXLim(1), 1);
        maxIndex = find(xdata <= currentXLim(2), 1, 'last');
        
        % Remove the extra points from ydata.
        ydata = ydata(minIndex:maxIndex);
    end
    
    % Calculate the minimum and maximum ydata.
    ymin = min(ymin, min(ydata(:)));
    ymax = max(ymax, max(ydata(:)));
end

XYZExtents = [xmin xmax; ymin ymax; -1 1];

% [EOF]
