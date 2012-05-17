function x = ncfinv(p,nu1,nu2,delta)
%NCFINV Inverse of the noncentral F cumulative distribution function (cdf).
%   X = NCFINV(P,NU1,NU2,DELTA) Returns the inverse of the noncentral F cdf with 
%   numerator degrees of freedom (df), NU1, denominator df, NU2, and noncentrality
%   parameter, DELTA, for the probabilities, P.
%
%   The size of X is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     
%
%   See also NCFCDF, NCFPDF, NCFRND, NCFSTAT, FINV, ICDF.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 73-74.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:16:04 $

if nargin <  4, 
    error('stats:ncfinv:TooFewInputs','Requires four input arguments.'); 
end

[errorcode, p, nu1, nu2, delta] = distchck(4,p,nu1,nu2,delta);

if errorcode > 0
    error('stats:ncfinv:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize x to return NaN for arguments are outside their respective limits.
if isa(p,'single') || isa(nu1,'single') || isa(nu2,'single') || isa(delta,'single')
   x = NaN(size(p),'single');
   crit = sqrt(eps('single'));
else
   x = NaN(size(p));
   crit = sqrt(eps);
end

% If some delta==0, call finv for those entries, call ncfinv for other entries.
f = (delta == 0);
if any(f(:))
   x(f) = finv(p(f),nu1(f),nu2(f));
   f = ~f;
   if any(f(:)), x(f) = ncfinv(p(f),nu1(f),nu2(f),delta(f)); end
   return
end

okParams = (nu1 > 0 & nu2 > 0 & delta >= 0);

% The inverse cdf of 0 is 0, and the inverse cdf of 1 is Inf.
x(p == 0 & okParams) = 0;
x(p == 1 & okParams) = Inf;

k = find(p > 0 & p < 1 & okParams);

% if nothing left, return.
if isempty(k), return; end

% Reset variables so that we don't have to deal with unnecessary indices,
% and at the same time convert everything to vectors
p = p(k);
nu1 = nu1(k);
nu2 = nu2(k);
delta = delta(k);

% Start at the mean, if the mean exists (if nu2>2)
y = nu2.*(nu1+delta) ./ (nu1.*max(1,nu2-2));

% Newton's Method.
% Permit no more than count_limit iterations.
count_limit = 100;
count = 0;

h = y;

% Iterate until the last update is very small compared to x,
% or we have made too many iterations
oldh = 0;
F = ncfcdf(y,nu1,nu2,delta);
while(count<count_limit)
   count = count+1;

   f = ncfpdf(y,nu1,nu2,delta);
   h = (F - p) ./ f;

   % If iterations appear to be oscillating, damp them out
   if length(h)==length(oldh)
      t = sign(h)==-sign(oldh);
      h(t) = sign(h(t)) .* min(abs(h(t)),abs(oldh(t)))/2;
   end

   % Avoid stepping too far
   newy = max(y/5, min(5*y, y-h));

   % Back off if the step gives a worse result
   newF = ncfcdf(newy,nu1,nu2,delta);
   while(true)
      worse = (abs(newF-p) > abs(F-p)*(1+crit)) & ...
              (abs(y-newy) > crit*y);
      if ~any(worse), break; end
      newy(worse) = 0.5 * (newy(worse) + y(worse));
      newF(worse) = ncfcdf(newy(worse),nu1(worse),nu2(worse),delta(worse));
   end
   x(k) = newy;
   
   % See which elements have not yet converged
   h = y - newy;
   mask = (abs(h) > crit*abs(y));
   if ~any(mask), break; end
   
   % Save parameters for only these elements
   F = newF(mask);
   y = newy(mask);
   oldh = h(mask);
   if ~all(mask)
      nu1 = nu1(mask);
      nu2 = nu2(mask);
      delta = delta(mask);
      p = p(mask);
      k = k(mask);
   end
end

if count==count_limit
    fprintf('\nWarning: NCFINV did not converge.\n');
    fprintf(['The last step was:  ' num2str(h(:)') '\n']);
end

