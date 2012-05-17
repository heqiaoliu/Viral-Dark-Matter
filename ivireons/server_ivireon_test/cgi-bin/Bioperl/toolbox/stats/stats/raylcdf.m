function p = raylcdf(x,b)
%RAYLCDF  Rayleigh cumulative distribution function.
%   P = RAYLCDF(X,B) returns the Rayleigh cumulative distribution 
%   function with parameter B at the values in X.
%
%   The size of P is the common size of X and B. A scalar input   
%   functions as a constant matrix of the same size as the other input.    
%
%   See also RAYLFIT, RAYLINV, RAYLPDF, RAYLRND, RAYLSTAT, CDF.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 134-136.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:08 $

if nargin < 1
    error('stats:raylcdf:TooFewInputs',...
          'Requires at least one input argument.'); 
end
if nargin<2
    b = 1;
end

[errorcode x b] = distchck(2,x,b);

if errorcode > 0
    error('stats:raylcdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single') || isa(b,'single')
    p=zeros(size(x),'single');
else
    p=zeros(size(x));
end

% Return NaN if B is not positive.
p(b <= 0) = NaN;

k=find(b > 0 & x >= 0);
if any(k),
    xk = x(k);
    bk = b(k);
    p(k) = 1 - exp(-xk .^ 2 ./ (2*bk .^ 2));
end
