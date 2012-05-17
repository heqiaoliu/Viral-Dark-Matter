function setXAxisLimits(ntx,xmin,xmax)
% Set new x-axis display limits, and switches
% x-axis to hold (non-autoscaling) mode.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:49 $

ntx.XAxisDisplayMin = xmin;
ntx.XAxisDisplayMax = xmax;
ntx.XAxisAutoscaling = false;
updateXTickLabels(ntx);
