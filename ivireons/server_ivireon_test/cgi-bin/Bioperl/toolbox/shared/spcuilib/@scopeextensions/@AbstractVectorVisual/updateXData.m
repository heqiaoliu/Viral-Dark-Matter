function updateXData(this)
%UPDATEXDATA Update the XData of the plot.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:13 $

hLines = get(this, 'Lines');
hLines = hLines(ishghandle(hLines));

% Loop over each of the lines and calculate a new XData vector based on the
% current settings of the scope.
for indx = 1:length(hLines)
    set(hLines(indx), 'XData', this.Multiplier*calculateXData(this, numel(get(hLines(indx), 'Ydata'))));
end

% If the XLimMode is auto, we are seeing no update.  Force it back to
% manual and then to auto again to get the update.
if strcmp(get(this.Axes, 'XLimMode'), 'auto')
    set(this.Axes, 'XLimMode', 'manual');
    set(this.Axes, 'XLimMode', 'auto');
end

% If we are in compact display we need to make sure that we call the resize
% function because the number of xticks might have changed and we would
% need to redraw.
onResize(this);

% [EOF]
