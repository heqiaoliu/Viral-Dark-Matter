function addVertex(this,X,Y,iElement,Orientation)
% Method to add a vertex to the constraint. 
% 
% The 'iElement' input is only used for constraints with orientation 'both' 
% and indicates that the vertex should be added between the iElement and 
% iElement+1 edge. iElement can be zero implying that the new vertex 
% should be the first of the constraint. iElement can be bigger than the
% number of edges implying that the new vertex should be the last of the
% constraint.

%   Author: A. Stothert 
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:37 $

%Identify the iElement to use
switch Orientation
   case 'horizontal'
      iElement = localFindIndex(X,this.xCoords);
   case 'vertical'
      iElement = localFindIndex(Y,this.yCoords);
   case 'both'
      if nargin < 4, 
         %No edge selected, default to end
         iElement = size(this.xCoords,1)+1; 
      end
      %Check to see if duplicating vertex.
      Dist = (this.xCoords(:)-X).^2+(this.yCoords(:)-Y).^2;
      if any(Dist < sqrt(eps)),
         %Vertex already exists
         iElement = [];
      end
end

if isempty(iElement)
   %Trying to add point 'on top of' existing point
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errDuplicateVertex');
end

%Split existing constraint edge to create new vertex and adjust its
%coordinates.
if iElement == 0
   %Need to add vertex before first edge
   X0 = this.xCoords(1,1);
   Y0 = this.yCoords(1,1);
   this.splitEdge(1);
   this.xCoords(1,1) = X;
   this.xCoords(1,2) = X0;
   this.yCoords(1,1) = Y;
   this.yCoords(1,2) = Y0;
elseif iElement > size(this.xCoords,1)
   %Need to add element after last edge
   X0 = this.xCoords(end,2);
   Y0 = this.yCoords(end,2);
   this.splitEdge(size(this.xCoords,1));
   this.xCoords(end,2) = X;
   this.xCoords(end-1,2) = X0;
   this.yCoords(end,2) = Y;
   this.yCoords(end-1,2) = Y0;
else
   this.splitEdge(iElement);
   this.xCoords(iElement,2) = X;
   this.xCoords(iElement+1,1) = X;
   this.yCoords(iElement,2) = Y;
   this.yCoords(iElement+1,1) = Y;
end

%--------------------------------------------------------------------------
function iElement = localFindIndex(pt,coords)

iElement = find((pt > coords(:,1))&(pt < coords(:,2)));
if isempty(iElement)
   %Vertex is beyond current limits
   if pt>=coords(end,2)
      iElement = size(coords,1)+1;
   elseif pt <= coords(end,1)
      iElement = 0;
   end
end





