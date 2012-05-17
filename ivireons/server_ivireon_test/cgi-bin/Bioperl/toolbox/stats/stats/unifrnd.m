function r = unifrnd(a,b,varargin)
%UNIFRND Random arrays from continuous uniform distribution.
%   R = UNIFRND(A,B) returns an array of random numbers chosen from the
%   continuous uniform distribution on the interval from A to B.  The size
%   of R is the common size of A and B if both are arrays.  If either
%   parameter is a scalar, the size of R is the size of the other
%   parameter.
%
%   R = UNIFRND(A,B,M,N,...) or R = UNIFRND(A,B,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also UNIFCDF, UNIFINV, UNIFPDF, UNIFSTAT, UNIDRND, RANDOM.

%   UNIFRND uses a linear transformation of standard uniform random values.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:08 $

if nargin < 2
    error('stats:unifrnd:TooFewInputs','Requires at least two input arguments.'); 
end

[err, sizeOut] = statsizechk(2,a,b,varargin{:});
if err > 0
    error('stats:unifrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Avoid    a+(b-a)*rand   in case   a-b > realmax
a2 = a/2;
b2 = b/2;
mu = a2+b2;
sig = b2-a2;

r = mu + sig .* (2*rand(sizeOut)-1);

% Fill in elements corresponding to illegal parameter values
if ~isscalar(a) || ~isscalar(b)
    r(a > b) = NaN;
elseif a > b
    r(:) = NaN;
end
