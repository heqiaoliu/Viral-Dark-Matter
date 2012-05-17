function Extent = extent(Constr) 
% EXTENT  method to return graphical extent of constraint
%
 
% Author(s): A. Stothert 19-Dec-2005
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:14 $

%Find annotated text
hGroup    = Constr.Elements;
hChildren = hGroup.Children;
Tags      = get(hChildren,'Tag');
idx       = strcmp(Tags,'ConstraintText');

%Return extent
Extent = get(hChildren(idx),'Extent');
Extent = [Extent(1), sum(Extent([1 3])), ...
   Extent(2), sum(Extent([2 4]))];            %[xExtent, yExtent]

