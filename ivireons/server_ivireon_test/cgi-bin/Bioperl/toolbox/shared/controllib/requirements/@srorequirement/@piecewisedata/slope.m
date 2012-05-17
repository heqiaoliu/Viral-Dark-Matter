function Slope = slope(this,iEdge)
% SLOPE Computes constraint slope
%
 
% Author(s): A. Stothert 04-Apr-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:45 $

if nargin < 2, iEdge = this.SelectedEdge; end

yCoords = this.yCoords;
xCoords = this.xCoords;
dY      = diff(yCoords(iEdge,:),1,2);
dX      = diff(xCoords(iEdge,:),1,2);
dX(abs(dX)<eps) = nan;   %Avoid division by zero problems

Slope = dY./dX;