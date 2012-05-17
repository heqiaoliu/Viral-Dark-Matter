function [m, v] = nbinstat(r,p)
%NBINSTAT Mean and variance of the negative binomial distribution.
%   [M, V] = NBINSTAT(R,P) returns the mean and variance of the
%   negative binomial distribution with parameters R and P.
%
%   See also NBINCDF, NBINFIT, NBININV, NBINLIKE, NBINPDF, NBINRND.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:16:02 $

if nargin < 2, 
    error('stats:nbinstat:TooFewInputs','Requires two input arguments.'); 
end

[errorcode r p] = distchck(2,r,p);

if errorcode > 0
    error('stats:nbinstat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

if isa(r,'single') || isa(p,'single')
   m = zeros(size(r),'single');
else
   m = zeros(size(r));
end
v = zeros(size(r));

% Out of range or missing parameters return NaN.  Infinite values
% for R correspond to a Poisson, but its stats cannot be determined
% from the (R,P) parametrization.
nans = ~(0 < r & isfinite(r) & 0 < p & p <= 1);
m(nans) = NaN;
v(nans) = NaN;

k = find(~nans);
if any(k)
    q = 1 - p(k);
    m(k) = r(k) .* q ./ p(k);
    v(k) = r(k) .* q ./ (p(k) .* p(k));
end
