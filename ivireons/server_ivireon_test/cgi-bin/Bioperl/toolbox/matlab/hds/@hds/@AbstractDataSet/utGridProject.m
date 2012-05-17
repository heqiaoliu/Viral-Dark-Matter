function idx = utGridProject(this,idx,GridSize,GridDim)
%GRIDPROJECT  Projects index vector onto specified grid dimension.
%
%   Converts absolute index vector relative to the entire grid 
%   into index vector relative to a particular grid dimension.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:13:46 $
idx = idx-1;
for ct=1:GridDim,
   r = rem(idx,GridSize(ct));
   idx = floor(idx/GridSize(ct));
end
idx = r+1;
