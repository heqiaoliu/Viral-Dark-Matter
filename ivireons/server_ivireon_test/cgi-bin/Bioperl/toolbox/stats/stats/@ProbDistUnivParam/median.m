function m=median(obj)
%MEDIAN Median of distribution.
%    M=MEDIAN(PD) returns the median M of the probability distribution PD.
%
%    See also ProbDist, ProbDistUnivParam, MEDIAN.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:23 $

m = icdf(obj,0.5);
