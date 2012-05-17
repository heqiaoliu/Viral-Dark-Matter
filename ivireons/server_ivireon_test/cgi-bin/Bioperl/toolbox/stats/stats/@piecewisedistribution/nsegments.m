function n = nsegments(obj)
%NSEGMENTS Number of segments defined in piecewise distribution.
%    N=NSEGMENTS(OBJ) returns the number of segments in the piecewise
%    distribution defined by OBJ.
%
%    See also PIECEWISEDISTRIBUTION, PIECEWISEDISTRIBUTION/BOUNDARY, PIECEWISEDISTRIBUTION/SEGMENT.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:21:04 $

n = numel(obj.P)+1;
        
