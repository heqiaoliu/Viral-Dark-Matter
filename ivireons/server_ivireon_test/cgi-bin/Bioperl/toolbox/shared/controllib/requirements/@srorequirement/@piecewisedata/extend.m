function extend(this) 
% EXTEND  Method to toggle the state of the extends to infinity flag(s) of 
% a piecewisedata object. 
%
 
% Author(s): A. Stothert 02-May-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:38 $


%Get current settings
nSelected = this.SelectedEdge;
OpenEnd   = this.OpenEnd;
nEdges    = size(this.xCoords,1);

%Check for any changes
NewVal = false;
if nSelected==1
   %First edge selected
   OpenEnd(1) = ~OpenEnd(1);
   NewVal = true;
end
if nEdges==nSelected
   %Last edge selected
   OpenEnd(2) = ~OpenEnd(2);
   NewVal = true;
end

%Set any new values and update
if NewVal
   this.OpenEnd = OpenEnd;
   %Notify listeners of data source change
   this.send('DataChanged');
end


