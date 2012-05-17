function y = unifpdf(x,a,b)
%UNIFPDF Uniform (continuous) probability density function (pdf).
%   Y = UNIFPDF(X,A,B) returns the continuous uniform pdf on the
%   interval [A,B] at the values in X. By default A = 0 and B = 1.
%   
%   The size of Y is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.    
%
%   See also UNIFCDF, UNIFINV, UNIFIT, UNIFRND, UNIFSTAT, PDF.

%   Reference:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.34.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:07 $

if nargin < 1
    error('stats:unifpdf:TooFewInputs',...
          'Requires at least one input argument.'); 
end

if nargin == 1
    a = 0;
    b = 1;
end

[errorcode x a b] = distchck(3,x,a,b);

if errorcode > 0
    error('stats:unifpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero.
if isa(x,'single') || isa(a,'single') || isa(b,'single')
    y = zeros(size(x),'single');
else
    y = zeros(size(x));
end

y(a >= b) = NaN;

k = find(x >= a & x <= b & a < b);
if any(k),
    y(k) = 1 ./ (b(k) - a(k));
end
