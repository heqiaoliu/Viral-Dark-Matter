function s=std(obj)
%STD Standard deviation of distribution.
%    V=STD(PD) returns the standard deviation S for the probability
%    distribution PD.
%
%    See also ProbDist, ProbDistUnivParam, STD.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:27 $

s = sqrt(var(obj));
