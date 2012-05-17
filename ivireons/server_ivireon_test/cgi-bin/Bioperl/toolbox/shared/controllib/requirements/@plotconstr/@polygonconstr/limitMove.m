function [X,Y] = limitMove(Constr,X,Y,X0,Y0)
%LIMITMOVE  limits resize values for a constraint

%   Author(s): A. Stothert
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:42 $

   
%If part of a bound, check to prevent move beyond neighbours extremes.
nEdge = size(Constr.xCoords,1);
if nEdge>1
   minSize  = eps;  %Percentage for minimum length for an edge
   iElement = Constr.SelectedEdge;
   switch Constr.Orientation
      case 'horizontal'
         %Horizontal constraint, limit extent of x movement by neighbour
         xUnits        = Constr.xUnits;
         xDisplayUnits = Constr.getDisplayUnits('xUnits');
         if iElement < nEdge
            Xright = unitconv(Constr.xCoords(iElement+1,2),...
               xUnits,xDisplayUnits);
            X      = min(X, X0-Constr.AppData.xValue0(2) + ...
               Xright*(1-minSize*sign(Xright)));
         end
         if iElement > 1
            Xleft = unitconv(Constr.xCoords(iElement-1,1),...
               xUnits,xDisplayUnits);
            X     = max(X, X0-Constr.AppData.xValue0(1) + ...
               Xleft*(1+minSize*sign(Xleft)));
         end
      case 'vertical'
         %Vertical constraint, limit extent of y movement by neighbour
         yUnits        = Constr.yUnits;
         yDisplayUnits = Constr.getDisplayUnits('yUnits');
         if iElement < nEdge
            Yright = unitconv(Constr.yCoords(iElement+1,2), ...
               yUnits,yDisplayUnits);
            Y      = min(Y, Y0-Constr.AppData.yValue0(2) + ...
               Yright*(1-minSize*sign(Yright)));
         end
         if iElement > 1
            Yleft = unitconv(Constr.yCoords(iElement-1,1),...
               yUnits,yDisplayUnits);
            Y     = max(Y, Y0-Constr.AppData.yValue0(1) + ...
               Yleft*(1+minSize*sign(Yleft)));
         end
   end
end
   

