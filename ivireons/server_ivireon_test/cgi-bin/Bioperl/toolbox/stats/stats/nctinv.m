function x = nctinv(p,nu,delta)
%NCTINV Inverse of the noncentral T cumulative distribution function (cdf).
%   X = NCTINV(P,NU,DELTA) Returns the inverse of the noncentral T cdf with
%   NU degrees of freedom and noncentrality parameter, DELTA, for the
%   probabilities, P.
%
%   The size of X is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   See also NCTCDF, NCTPDF, NCTRND, NCTSTAT, TINV, ICDF.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 147-148.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:09 $

if nargin <  3,
    error('stats:nctinv:TooFewInputs','Requires three input arguments.');
end

[errorcode, p, nu, delta] = distchck(3,p,nu,delta);

if errorcode > 0
    error('stats:nctinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize x to return NaN for arguments are outside their respective limits.
if isa(p,'single') || isa(nu,'single') || isa(delta,'single')
   x = NaN(size(p),'single');
   crit = sqrt(eps('single'));
else
   x = NaN(size(p));
   crit = sqrt(eps);
end

% If some delta==0, call tinv for those entries, call nctinv for other entries.
f = (delta == 0);
if any(f(:))
   x(f) = tinv(p(f),nu(f));
   f = ~f;
   if any(f(:)), x(f) = nctinv(p(f),nu(f),delta(f)); end
   return
end

okParams = (nu > 0 & ~isnan(delta));

% The inverse cdf of 0 is -Inf, and the inverse cdf of 1 is Inf.
x(p == 0 & okParams) = -Inf;
x(p == 1 & okParams) = Inf;

% Remove the bad/edge cases.
k = (p > 0 & p < 1 & okParams);
pk = p(k);
vk = nu(k);
dk = delta(k);

% Newton's Method.
% Permit no more than count_limit iterations.
count_limit = 100;
count = 0;

% Use delta as a starting guess for x.
xk = dk;

h = ones(size(xk),class(xk));

% Break out of the iteration loop for the following:
%  1) The last update is very small (compared to x or in abs. value).
%  2) There are more than 100 iterations.

F =  nctcdf(xk,vk,dk);
while(any(abs(h)>crit*abs(xk)) && ...
      max(abs(h))>crit && ...
      count<count_limit)
    count = count+1;
    f =  nctpdf(xk,vk,dk);
    h = (F - pk) ./ f;

    % Avoid stepping too far
    xnew = max(-5*abs(xk), min(5*abs(xk), xk-h));

    % Back off if the step gives a worse result
    Fnew = nctcdf(xnew,vk,dk);
    while(true)
       worse = (abs(Fnew-pk) > abs(F-pk)*(1+crit)) & ...
               (abs(xk-xnew) > crit*abs(xk));
       if ~any(worse), break; end
       xnew(worse) = 0.5 * (xnew(worse) + xk(worse));
       Fnew(worse) = nctcdf(xnew(worse),vk(worse),dk(worse));
    end

    xk = xnew;
    F = Fnew;
end

% Return the converged value(s).
x(k) = xk;

if count==count_limit
    warning('stats:nctinv:NoConvergence',...
            'NCTINV did not converge.  The maximum last step size was %g.', ...
            max(abs(h(:))));
end

