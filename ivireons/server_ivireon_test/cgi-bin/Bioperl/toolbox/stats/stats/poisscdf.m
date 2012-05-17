function p = poisscdf(x,lambda)
%POISSCDF Poisson cumulative distribution function.
%   P = POISSCDF(X,LAMBDA) computes the Poisson cumulative
%   distribution function with parameter LAMBDA at the values in X.
%
%   The size of P is the common size of X and LAMBDA. A scalar input   
%   functions as a constant matrix of the same size as the other input.    
%
%   See also POISSFIT, POISSINV, POISSPDF, POISSRND, POISSTAT.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.22.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:59:12 $
 
if nargin < 2, 
    error('stats:poisscdf:TooFewInputs','Requires two input arguments.'); 
end

[errorcode x lambda] = distchck(2,x,lambda);

if errorcode > 0
    error('stats:poisscdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize P to zero.
if isa(x,'single') || isa(lambda,'single')
   p = zeros(size(x),'single');
else
   p = zeros(size(x));
end
p(isnan(x) | isnan(lambda)) = NaN;
if ~isfloat(x)
   x = double(x);
end
x = floor(x);

% Return NaN for invalid or indeterminate inputs
t = (lambda<0) | (x==Inf & lambda==Inf);
if any(t)
    p(t) = NaN;
end
todo = (x>=0) & ~t & isfinite(lambda);

% Return 1 for x=Inf as long as lambda is valid
t = (x==Inf & lambda>0 & isfinite(lambda));
if any(t)
    todo(t) = false;
    p(t) = 1;
end

% Compute P when X for the remaining cases
x = x(todo);
lambda = lambda(todo);
p(todo) = gammainc(lambda,x+1,'upper');
