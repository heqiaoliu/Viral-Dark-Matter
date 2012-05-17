function removeEdge(this,iElement,Orientation)
% Method to delete edge from constraint object

%   Author: A. Stothert 
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:42 $

%Only remove edge if have valid constraint
if ~this.isValid
   return
end

%If no edge specified use selected edge
if nargin < 2, iElement = this.SelectedEdge; end
%If no orientation specified use horizontal
if nargin <3, Orientation = 'horizontal'; end

nConstr = size(this.xCoords,1);
if nConstr==numel(iElement)
    %Want to remove all edges, delete the object
    delete(this)
    return
end

%Remove the selected edge from the x, y, and linked lists
this.xCoords = [...
   this.xCoords(1:iElement-1,:); ...
   this.xCoords(iElement+1:end,:)];
this.yCoords = [...
   this.yCoords(1:iElement-1,:); ...
   this.yCoords(iElement+1:end,:)];

%Update the Linked Elements
if iElement < nConstr
   this.Linked = [...
      this.Linked(1:iElement-1,:); ...
      this.Linked(iElement+1:end,:)];
else
   this.Linked = this.Linked(1:iElement-2,:);
end

%Update the weight vector
this.Weight = [...
   this.Weight(1:iElement-1); ...
   this.Weight(iElement+1:end)];

%Update the remaining edges to cover the removed edge
iElement = max(1,iElement-1);
switch Orientation
   case 'horizontal'
      if iElement < nConstr-1
         this.xCoords(iElement,2) = this.xCoords(iElement+1,1);
      end
   case 'vertical'
      if iElement < nConstr-1
         this.yCoords(iElement,2) = this.yCoords(iElement+1,1);
      end
   case 'both'
      if iElement < nConstr-1
         this.xCoords(iElement,2) = this.xCoords(iElement+1,1);
         this.yCoords(iElement,2) = this.yCoords(iElement+1,1);
      end
end

%Update the selected edge
this.SelectedEdge = max(iElement(1)-1,1);

%Notify listeners of data source change
this.send('DataChanged');