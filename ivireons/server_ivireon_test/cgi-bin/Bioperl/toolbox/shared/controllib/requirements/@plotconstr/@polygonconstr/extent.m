function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:35 $

xCoords = Constr.xCoords(:);
yCoords = Constr.yCoords(:);
Extent = [min(xCoords) max(xCoords) , ...
   min(yCoords) max(yCoords)];
%Perform any necessary unit conversions
Extent(1:2) = unitconv(Extent(1:2),Constr.xUnits,Constr.xDisplayUnits);
Extent(3:4) = unitconv(Extent(3:4),Constr.yUnits,Constr.yDisplayUnits);
