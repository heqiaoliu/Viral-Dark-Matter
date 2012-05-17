function join(this, WhichEnd,Orientation)
% Method to join adjacent ends of edges in the constraint.

%   Author: A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:41 $

iElement = this.SelectedEdge; %Needed as index can change

%Make sure we're not trying to join the last element
if (iElement == 1) && strcmp(WhichEnd,'left') || ...
      (iElement == size(this.xCoords,1)) && strcmp(WhichEnd,'right')
   %Nothing to do
   return
end

%Check which end needs to be joined
switch WhichEnd
   case 'left'
      iEnd = 1;
   case 'right'
      iEnd = 2;
end

%Check coordinate is free to be toggled
switch Orientation
   case 'horizontal'
      freeCoord = 2;   %y-coordinate is free
   case 'vertical'
      freeCoord = 1;   %x-coordinate is free
end

%Find the correct link index and toggle. 
switch WhichEnd
   case 'left'
      iLink = iElement-1;
      this.Linked(iLink,freeCoord) = ~this.Linked(iLink,freeCoord);
   case 'right'
      iLink = iElement+1;
      this.Linked(iElement,freeCoord) = ~this.Linked(iElement,freeCoord);
end

%Update the coordinate if necessary
if freeCoord == 2
   this.yCoords(iElement,iEnd) = this.yCoords(iLink,3-iEnd);
elseif freeCoord == 1
   this.xCoords(iElement,iEnd) = this.yCoords(iLink,3-iEnd);
end

%Notify listeners of data source change
this.send('DataChanged');
