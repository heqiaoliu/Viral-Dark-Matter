function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:20 $

if Constr.Ts
    Extent = [-1 1 -1 1];
else
    Extent = [-1.05*Constr.Frequency 0 0 0];
end