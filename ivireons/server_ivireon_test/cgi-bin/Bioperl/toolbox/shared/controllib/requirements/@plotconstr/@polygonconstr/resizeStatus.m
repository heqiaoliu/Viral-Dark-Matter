function str = resizeStatus(this)
% RESIZESTATUS mehod to return string for status displya during move
% operation
%
 
% Author(s): A. Stothert 10-Mar-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:51 $

iEdge  = this.SelectedEdge;
xCoords = this.xCoords(iEdge,:);
yCoords = this.yCoords(iEdge,:);
LocStr = sprintf('Location:  from %0.3g to %0.3g',...
   xCoords(1),...
   xCoords(2));
SlopeStr = sprintf('Slope:  %0.3g rad',atan2(diff(yCoords),diff(xCoords)));
str = sprintf('%s\n%s',LocStr,SlopeStr);