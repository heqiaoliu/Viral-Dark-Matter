function y=cdf(obj,x)
%CDF Cumulative distribution function.
%    Y = CDF(PD,X) returns an array Y containing the cumulative
%    distribution function (CDF) for the probability distribution
%    PD, evaluated at values in X.
%
%    See also ProbDist, ProbDistUnivParam, CDF.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:17 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDistUnivParam:cdf:TooFewInputs',...
        'Two input arguments are required.');
end

y = paramcall(obj.cdffunc,x,obj.Params);
