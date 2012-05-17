function v=var(obj)
%VAR Variance of distribution.
%    V=VAR(PD) returns the variance V for the probability
%    distribution PD.
%
%    See also ProbDist, ProbDistUnivParam, VAR.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:29 $

[ignore,v] = stats(obj);
