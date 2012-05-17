function y=cdf(obj,x)
%ProbDist/CDF Cumulative distribution function.
%    Y = CDF(PD,X) returns an array Y containing the cumulative
%    distribution function (CDF) for the ProbDist object PD, evaluated at
%    values in X.
%
%    See also ProbDist, CDF.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:59 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDist:cdf:TooFewInputs',...
        'Two input arguments are required.');
end

if isempty(obj.cdffunc)
    error('stats:ProbDist:cdf:Undefined',...
          'No CDF is defined for this distribution.');
else
    y = obj.cdffunc(x);
end
