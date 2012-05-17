function updateXTickLabels(this)
%UPDATEXTICKLABELS Update the XTick Labels

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/29 16:09:15 $

hAxes = this.Axes;
xTicks = get(hAxes, 'XTick');

% Create new labels for the ticks which match the multiplier.
xTicks = xTicks*this.TimeMultiplier;
xTickLabels = num2str(xTicks', 3);
set(hAxes, 'XTickLabel', xTickLabels)

% [EOF]
