function [X,Y] = limitMove(Constr,X,Y,X0,Y0)
%LIMITMOVE  limits resize values for a constraint

%   Author(s): A. Stothert
%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:57 $

   
%If part of a bound, check to prevent move beyond neighbours extremes.
minSize  = eps;  %Percentage for minimum length for an edge
iElement = Constr.Data.SelectedEdge;

if numel(iElement) > 1
   %Quick return, cannot move whole piece
   X = X0; Y = Y0;
   return
end

%Horizontal movement restrictions, limit extent of x movement by neighbour
xUnits        = Constr.Data.getData('xUnits');
xDisplayUnits = Constr.getDisplayUnits('xUnits');
xCoords       = unitconv(Constr.Data.getData('xData'),xUnits,xDisplayUnits);
xValue0       = Constr.AppData.xValue0;
if iElement == 1
   Xlimit = xCoords(4,1); %Minimum right value
   X      = max(X,X0-xValue0(2) + ...
      Xlimit*(1-minSize*sign(Xlimit)));
   Xlimit = xCoords(2,2); %Maximum right value
   X      = min(X,X0-xValue0(2) + ...
      Xlimit*(1-minSize*sign(Xlimit)));
   Xlimit = xCoords(4,1); %Maximum left value
   X      = min(X,X0-xValue0(1) + ...
      Xlimit*(1-minSize*sign(Xlimit)));
end
if iElement == 2
   Xlimit = xCoords(4,1); %Minimum left value
   X      = max(X,X0-xValue0(1) + ...
      Xlimit*(1-minSize*sign(Xlimit)));
end
if any(iElement == [3 4])
   Xright = xCoords(iElement+1,2);
   X      = min(X, X0-xValue0(2) + ...
      Xright*(1-minSize*sign(Xright)));
end
if any(iElement == [4 5])
   Xleft = xCoords(iElement-1,1);
   X     = max(X, X0-xValue0(1) + ...
      Xleft*(1+minSize*sign(Xleft)));
end

%Vertical movement restrictions, limit extent of y movement by upper/lower
%bound
yUnits        = Constr.Data.getData('yUnits');
yDisplayUnits = Constr.getDisplayUnits('yUnits');
yCoords       = unitconv(Constr.Data.getData('yData'),yUnits,yDisplayUnits);
yValue0       = Constr.AppData.yValue0;
StepChar      = Constr.Requirement.getStepCharacteristics;
u0            = StepChar.InitialValue;
uf            = StepChar.FinalValue;

if uf > u0
   %Positive step response
   limitFcnMin   = @max;     %Function for minimum limits
   limitFcnMax   = @min;     %Function for maximum limits
else
   %Negative step response
   limitFcnMin   = @min;     %Function for minimum limits
   limitFcnMax   = @max;     %Function for maximum limits
end
   
if iElement == 1
   Ylimit = yCoords(5,1); %Minimum value
   Y      = limitFcnMin(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
end
if iElement == 2
   Ylimit = uf; %Minimum value
   Y      = limitFcnMin(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
   Ylimit = yCoords(1,1); %Maximum value
   Y      = limitFcnMax(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
end
if iElement == 3
   Ylimit = u0; %Maximum value
   Y      = limitFcnMax(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
end
if iElement == 4
   Ylimit = yCoords(5,1); %Maximum value
   Y      = limitFcnMax(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
   Ylimit = yCoords(3,1); %Minimum value
   Y      = limitFcnMin(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
end
if iElement == 5
   Ylimit = uf; %Maximum value
   Y      = limitFcnMax(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
   Ylimit = 2*uf-yCoords(1,1); %Minimum value
   Y      = limitFcnMin(Y,Y0-yValue0(1) + ...
      Ylimit*(1-minSize*sign(Ylimit)));
end

   

