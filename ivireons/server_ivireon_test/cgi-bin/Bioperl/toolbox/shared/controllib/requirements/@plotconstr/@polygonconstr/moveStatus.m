function str = moveStatus (this)
% MOVESTATUS mehod to return string for status displya during move
% operation
%
 
% Author(s): A. Stothert 10-Mar-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:48 $

iElement = this.SelectedEdge;
xLoc = unitconv(this.xCoords(iElement,:),...
   this.xUnits,...
   this.getDisplayUnits('XUnits'));
LocStr = sprintf('Current location:  from %0.3g to %0.3g',...
   xLoc(1),xLoc(end));
str = sprintf('Move requirement to desired location and release the mouse.\n%s',LocStr);