function p = unidcdf(x,n);
%UNIDCDF Uniform (discrete) cumulative distribution function.
%   P = UNIDCDF(X,N) returns the cumulative distribution function
%   for a random variable uniform on (1,2,...,N), at the values in X.
%
%   The size of P is the common size of X and N. A scalar input   
%   functions as a constant matrix of the same size as the other input.    
%
%   See also UNIDINV, UNIDPDF, UNIDRND, UNIDSTAT, CDF.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:17:59 $

if nargin < 2, 
    error('stats:unidcdf:TooFewInputs','Requires two input arguments.'); 
end

[errorcode x n] = distchck(2,x,n);

if errorcode > 0
    error('stats:unidcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single') || isa(n,'single')
   p = zeros(size(x),'single');
else
   p = zeros(size(x));
end

% P = 1 when X >= N
p(x >= n) = 1;

xx=floor(x);

k = find(xx >= 1 & xx <= n);
if any(k),
    p(k) = xx(k) ./ n(k);
end

p(n < 1 | round(n) ~= n) = NaN;
