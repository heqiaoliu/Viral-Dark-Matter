function y=iqr(obj)
%IQR Interquartile range of distribution.
%    Y=IQR(PD) returns the interquartile range Y for the probability
%    distribution PD.  The interquartile range is the distance
%    between the 75th and 25th percentiles.
%
%    See also ProbDist, ProbDistUnivParam, IQR, ProbDistUnivParam/ICDF.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:21 $

y = diff(icdf(obj,[0.25 0.75]));
