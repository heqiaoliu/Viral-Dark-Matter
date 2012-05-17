function p = unifcdf(x,a,b);
%UNIFCDF Uniform (continuous) cumulative distribution function (cdf).
%   P = UNIFCDF(X,A,B) returns the cdf for the uniform distribution
%   on the interval [A,B] at the values in X.
%
%   The size of P is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.    
% 
%   By default, A = 0 and B = 1.
%
%   See also UNIFINV, UNIFIT, UNIFPDF, UNIFRND, UNIFSTAT, CDF.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:04 $

if nargin < 1, 
    error('stats:unifcdf:TooFewInputs',...
          'Requires at least one input argument.'); 
end

if nargin == 1
    a = 0;
    b = 1;
end

[errorcode x a b] = distchck(3,x,a,b);

if errorcode > 0
    error('stats:unifcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single') || isa(a,'single') || isa(b,'single')
    p = zeros(size(x),'single');
else
    p = zeros(size(x));
end

p(a >= b) = NaN;

% P = 1 when X >= B
p(x >= b) = 1;

k = find(x > a & x < b & a < b);
if any(k),
    p(k) = (x(k) - a(k)) ./ (b(k) - a(k));
end
