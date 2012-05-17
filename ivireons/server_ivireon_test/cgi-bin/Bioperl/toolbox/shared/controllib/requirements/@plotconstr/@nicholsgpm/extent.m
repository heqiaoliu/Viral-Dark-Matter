function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Author(s): A. Stothert
%   Revised:
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:03 $

Range = Constr.Origin + [-1 1] * unitconv(Constr.Data.xCoords,Constr.Data.xUnits,'deg');
RangePha = unitconv(Range, 'deg', Constr.xDisplayUnits);
RangeMag = unitconv([0 0], 'dB', Constr.yDisplayUnits);
Extent = [RangePha, RangeMag];
