function updateCoords(this,Orientation,fireEvent) %#ok<INUSL>
% One of the vertices has changed, synchronise other vertices based on 
% 'Linked' and orientation settings.

%   Author: A. Stothert 
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:06 $

if nargin < 3, fireEvent = true; end

nConstr = size(this.xCoords,1);

%Check that we have a valid constraint to update
if ~all(size(this.xCoords) == size(this.yCoords)) || ...
      size(this.Linked,1) ~= nConstr-1 
   return
else
   %Make sure we've a valid selected edge
   SE = this.SelectedEdge;
   if any(SE > nConstr)
      SE = SE(SE <= nConstr);
      this.SelectedEdge = SE;
   end
end

%Extract final and initial value data
sc = this.Requirement.getStepCharacteristics;
T0 = sc.StepTime; 
u0 = sc.InitialValue;
uf = sc.FinalValue;
posStep = sign(uf-u0);

%Based on step response shape update neighbouring elements
iElement = this.SelectedEdge;
xCoords = this.xCoords;
yCoords = this.yCoords;
if iElement == 1
   xCoords(1,1) = T0;
   xCoords(2,1) = xCoords(iElement,2);
   %xCoords(3,1) = xCoords(iElement,1);
   xCoords(4,2) = xCoords(iElement,2);
   xCoords(5,1) = xCoords(iElement,2);
end
if iElement == 2
   xCoords(1,2) = xCoords(iElement,1);
   xCoords(4,2) = xCoords(iElement,1);
   xCoords(5,1) = xCoords(iElement,1);
   xCoords(5,2) = xCoords(iElement,2);
   delta = posStep*(yCoords(iElement,1)-uf);
   yCoords(5,1:2) = uf-posStep*delta;
end
if iElement == 3
   xCoords(3,1) = T0;
   %xCoords(1,1) = xCoords(iElement,1);
   xCoords(4,1) = xCoords(iElement,2);
end
if iElement == 4
   xCoords(1,2) = xCoords(iElement,2);
   xCoords(2,1) = xCoords(iElement,2);
   xCoords(3,2) = xCoords(iElement,1);
   xCoords(5,1) = xCoords(iElement,2);
end
if iElement == 5
   xCoords(1,2) = xCoords(iElement,1);
   xCoords(2,1) = xCoords(iElement,1);
   xCoords(2,2) = xCoords(iElement,2);
   xCoords(4,2) = xCoords(iElement,1);
   delta = posStep*(uf-yCoords(5,1));
   yCoords(2,1:2) = uf+posStep*delta;
end
this.xCoords = xCoords;
this.yCoords = yCoords;

%Notify listeners that data has changed
if fireEvent
    this.send('DataChanged')
end

