function [CPX,CPY] = limitResize(Constr,CPX,CPY,moveIdx)
%LIMITRESIZE limits resize values for a constraint.

%   Author(s): A. Stothert
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:44 $

%Copy coordinate to limit so that can use same code block for both
%horizontal and vertical oriented constraints
switch Constr.Orientation
   case 'horizontal'
      CPV      = CPX;
      fldLimit = 'xCoords';
   case 'vertical'
      CPV      = CPY;
      fldLimit = 'yCoords';
   case 'both'
      %Nothing to do
      return
end

%Perform the limit check
iElement = Constr.SelectedEdge;
iElement = iElement(1);
minSize  = eps;   %Percentage used to limit minimum constraint size.
nEdge    = size(Constr.xCoords,1); 
switch moveIdx
   case 1
      %Left end selected
      if nEdge>1
         %Limit left extent to left end of next constraint
         if iElement > 1
            leftLimit = Constr.(fldLimit)(iElement-1,1);
            CPV       = max(CPV,leftLimit*(1+minSize*sign(leftLimit)));
         end
      end
      %Limit right extent to right end
      rightLimit = Constr.(fldLimit)(iElement,2);
      CPV        = min(CPV,rightLimit*(1-minSize*sign(rightLimit)));
   case 2
      %Right end selected
      if nEdge>1
         %Limit right extent to right end of next constraint
         if iElement < nEdge
            rightLimit = Constr.(fldLimit)(iElement+1,2);
            CPV        = min(CPV,rightLimit*(1-minSize*sign(rightLimit)));
         end
      end
      %Limit left extent to left end
      leftLimit = Constr.(fldLimit)(iElement,1);
      CPV       = max(CPV,leftLimit*(1+minSize*sign(leftLimit)));
end

%Limit correct return coordinate
switch Constr.Orientation
   case 'horizontal'
      CPX = CPV;
   case 'vertical'
      CPY = CPV;
end


