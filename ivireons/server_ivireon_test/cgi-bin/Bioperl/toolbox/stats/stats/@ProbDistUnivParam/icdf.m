function y=icdf(obj,p)
%ICDF Inverse cumulative distribution function.
%    Y = ICDF(PD,P) returns an array Y containing the inverse cumulative
%    distribution function (ICDF) for the probability distribution
%    PD, evaluated at values in P.
%
%    See also ProbDist, ProbDistUnivParam, CDF.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:20 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDistUnivParam:icdf:TooFewInputs',...
        'Two input arguments are required.');
end

y = paramcall(obj.icdffunc,p,obj.Params);
