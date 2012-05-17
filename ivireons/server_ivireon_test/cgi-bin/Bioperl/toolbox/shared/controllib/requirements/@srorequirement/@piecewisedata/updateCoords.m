function updateCoords(this,Orientation,fireEvent)
% One of the vertices has changed, synchronise other vertices based on 
% 'Linked' and orientation.

%   Author: A. Stothert 
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:47 $

if nargin < 3, fireEvent = true; end

nConstr = size(this.xCoords,1);

%Check that we have a valid constraint to update
if ~all(size(this.xCoords) == size(this.yCoords)) || ...
      size(this.Linked,1) ~= nConstr-1 
   return
else
   %Make sure we've a valid selected edge
   iElement = this.SelectedEdge;
   if any(iElement > nConstr)
      iElement = iElement(iElement <= nConstr);
      this.SelectedEdge = iElement;
   end
end

%Constraint property has been updated
switch Orientation
   case 'vertical'
      fldNormal = {'yCoords'};
      fldGlue   = 'xCoords';
      idxOrientation = 1;      %x-coordinate is free
   case 'horizontal'
      fldNormal = {'xCoords'};
      fldGlue   = 'yCoords';
      idxOrientation = 2;      %y-coordinate is free
   case 'both'
      fldNormal = {'yCoords','xCoords'};
      idxOrientation = [];     %neither coordinate is free
end

%Based on orientation update neighbouring elements
if iElement < nConstr
   for iNormal = 1:numel(fldNormal)
      this.(fldNormal{iNormal})(iElement+1,1) = this.(fldNormal{iNormal})(iElement,2);
      if ~isempty(idxOrientation)&&...
            this.Linked(iElement,idxOrientation)
         this.(fldGlue)(iElement+1,1) = this.(fldGlue)(iElement,2);
      end
   end
end
if iElement > 1
   for iNormal = 1:numel(fldNormal)
      this.(fldNormal{iNormal})(iElement-1,2) = this.(fldNormal{iNormal})(iElement,1);
      if ~isempty(idxOrientation)&&...
            this.Linked(iElement-1,idxOrientation)
         this.(fldGlue)(iElement-1,2) = this.(fldGlue)(iElement,1);
      end
   end
end

%Notify listeners that data has changed
if fireEvent
    this.send('DataChanged')
end