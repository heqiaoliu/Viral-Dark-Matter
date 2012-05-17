function [m,v]= nctstat(nu,delta)
%NCTSTAT Mean and variance for the noncentral t distribution.
%   [M,V] = NCTSTAT(NU,DELTA) returns the mean and variance
%   of the noncentral t pdf with NU degrees of freedom and
%   noncentrality parameter, DELTA.
%
%   See also NCTCDF, NCTINV, NCTPDF, NCTRND, TSTAT.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley
%      1993 p. 147-148.

%   Copyright 1993-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:12 $

if nargin < 2, 
    error('stats:nctstat:TooFewInputs','Requires two input arguments.'); 
end

[errorcode, nu, delta] = distchck(2,nu,delta);

if errorcode > 0
    error('stats:nctstat:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize the mean and variance to NaN.
if isa(nu,'single') || isa(delta,'single')
   m = NaN(size(nu),'single');
else
   m = NaN(size(nu));
end
v = m;

% Mean is defined if NU is greater than 1.
k = (nu > 1);
if any(k(:))
    m(k) = delta(k) .* sqrt((nu(k)/2)) .* gamma((nu(k) - 1)/2) ./ ...
           gamma(nu(k)/2);
end

% Variance is defined if NU is greater than 2.
k = (nu > 2);
if any(k(:))
    v(k) = (nu(k) ./ (nu(k) - 2)) .* (1 + delta(k) .^2) ...
            - 0.5*(nu(k) .* delta(k).^2) ...
                   .* exp(2*(gammaln((nu(k)-1)/2) - gammaln(nu(k)/2)));
end
