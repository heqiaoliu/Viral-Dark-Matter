function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:41 $

if Constr.Ts
    rho = Constr.geometry;
    Extent = [-rho rho -rho rho];
else
    alpha = Constr.geometry;
    Extent = [1.05*alpha 0.95*alpha 0 0];
end