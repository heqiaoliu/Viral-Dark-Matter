function performAutoscale(this) 
% PERFORMAUTOSCALE interface method for PlotNavigation tool
%
 
% Author(s): A. Stothert 27-Apr-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/05/10 17:38:14 $

set(this.hPlot.AxesGrid,'XLimMode','auto','YLimMode','auto')
end