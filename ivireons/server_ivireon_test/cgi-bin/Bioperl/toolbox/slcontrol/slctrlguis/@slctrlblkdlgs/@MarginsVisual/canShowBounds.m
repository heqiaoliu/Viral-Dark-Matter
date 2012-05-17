function  canShow = canShowBounds(this)
% CANSHOWBOUNDS interface method to determine whether the visualization can
% display bounds or not
%
% Used by the requirement viewer tool. The requirement tool calls this
% method to determine whether to update the visualization with bounds


% Author(s): A. Stothert 17-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/31 18:59:39 $

canShow = ~strcmp(this.PlotType,'table');
end