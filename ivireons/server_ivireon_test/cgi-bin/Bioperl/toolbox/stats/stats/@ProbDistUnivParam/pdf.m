function y=pdf(obj,x)
%PDF Probability density function.
%    Y = PDF(OBJ,X) returns an array Y containing the probability density
%    function (PDF) for the probability distribution object OBJ, evaluated
%    at values in X.
%
%    See also ProbDist, ProbDistUnivParam, PDF.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:25 $

% Check for valid input
if nargin ~= 2
    error('stats:ProbDistUnivParam:pdf:TooFewInputs',...
        'Two input arguments are required.');
end

y = paramcall(obj.pdffunc,x,obj.Params);

