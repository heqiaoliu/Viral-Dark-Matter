function performAutoscale(this, ~)
%PERFORMAUTOSCALE Perform the autoscale action.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:38:07 $

%Call autoscale on the visualization
hVis = this.Application.Visual;
if ~isempty(hVis)
   performAutoscale(hVis)
end
end