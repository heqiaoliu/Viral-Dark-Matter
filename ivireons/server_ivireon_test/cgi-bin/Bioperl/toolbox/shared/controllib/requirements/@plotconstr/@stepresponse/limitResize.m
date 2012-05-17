function [CPX,CPY] = limitResize(Constr,CPX,CPY,moveIdx)
%LIMITRESIZE limits resize values for a step response constraint.

%   Author(s): A. Stothert
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:58 $

iElement = Constr.SelectedEdge;  %Selected edge
iElement = iElement(1);

%Perform the limit check
xCoords  = Constr.Data.getData('xData');
minSize  = eps;   %Percentage used to limit minimum constraint size.
switch moveIdx
   case 1
      %Left end selected
      switch iElement
         case {1, 3}
            %First segment no limit
            leftLimit = -inf;  %Minimum limit
            CPX       = max(CPX,leftLimit*(1+minSize*sign(leftLimit)));
            leftLimit = xCoords(4,1);  %Maximum limit
            CPX       = min(CPX,leftLimit*(1+minSize*sign(leftLimit)));
         case 2
            %Overshoot segment, can't end before rise time
            leftLimit = xCoords(4,1);
            CPX       = max(CPX,leftLimit*(1+minSize*sign(leftLimit)));
         otherwise
            %Limit left extent to left end of previous constraint
            leftLimit = xCoords(iElement-1,1);
            CPX       = max(CPX,leftLimit*(1+minSize*sign(leftLimit)));
      end
      %Limit right extent to right end
      rightLimit = xCoords(iElement,2);
      CPX        = min(CPX,rightLimit*(1-minSize*sign(rightLimit)));
      %Make sure yCoord doesn't change as want to keep line slopes 
      %constant
      yCoords = Constr.Data.getData('yData');
      CPY = yCoords(iElement,1);
   case 2
      %Right end selected
      switch iElement
         case {2, 5}
            %Right segment, no limit
            rightLimit = inf;
            CPX        = min(CPX,rightLimit*(1-minSize*sign(rightLimit)));
         case 1
            %Overshoot segment, can't end before rise time
            rightLimit = xCoords(4,1);  %Minimum limit
            CPX        = max(CPX,rightLimit*(1-minSize*sign(rightLimit)));
            rightLimit = xCoords(2,2);  %Maximum limit
            CPX        = min(CPX,rightLimit*(1-minSize*sign(rightLimit)));
         otherwise
            %Limit right extent to right end of next constraint
            rightLimit = xCoords(iElement+1,2);
            CPX        = min(CPX,rightLimit*(1-minSize*sign(rightLimit)));
      end
      %Limit left extent to left end
      leftLimit = xCoords(iElement,1);
      CPX       = max(CPX,leftLimit*(1+minSize*sign(leftLimit)));
      %Make sure yCoord doesn't change as want to keep line slopes
      %constant
      yCoords = Constr.Data.getData('yData');
      CPY = yCoords(iElement,2);
end



