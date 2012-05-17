function y=pdf(obj,x)
%ProbDist/PDF Probability density function.
%    Y = PDF(PD,X) returns an array Y containing the probability density
%    function (PDF) for the ProbDist object PD, evaluated at values in X.
%
%    See also ProbDist, PDF.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:02 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDist:pdf:TooFewInputs',...
        'Two input arguments are required.');
end

if isempty(obj.pdffunc)
    error('stats:ProbDist:pdf:Undefined',...
          'No PDF is defined for this distribution.');
else
    y = obj.pdffunc(x);
end
