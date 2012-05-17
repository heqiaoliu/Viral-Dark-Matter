function y = nctpdf(x,nu,delta)
%NCTPDF Noncentral T probability density function (pdf).
%   Y = NCTPDF(X,V,DELTA) Returns the noncentral T pdf with V degrees 
%   of freedom and noncentrality parameter, DELTA, at the values in X. 
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     
%
%   See also NCTCDF, NCTINV, NCTRND, NCTSTAT, TPDF, PDF.

%   Reference:
%      Johnson, Kotz, and Balakrishnan, "Continuous Univariate
%        Distributions, Vol. 2" (2nd edition), Wiley, 1995.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:16:10 $
if nargin <  3, 
    error('stats:nctpdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode,x,nu,delta] = distchck(3,x,nu,delta);
if errorcode > 0
    error('stats:nctpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

if isa(x,'single') || isa(nu,'single') || isa(delta,'single')
    y = zeros(size(x),'single');
else
    y = zeros(size(x));
end

% Out of range or missing parameters and missing data return NaN.
nans = ~((nu > 0) & isfinite(nu) & isfinite(delta)) | isnan(x);
y(nans) = NaN;

% Negative data -- use left tail of CDF to get PDF.  -Infs return zero.
k = find((x < 0) & isfinite(x) & ~nans);
if any(k)
    y(k) = (nu(k)./x(k)) .* ...
        (nctcdf(x(k).*sqrt((nu(k)+2)./nu(k)), nu(k)+2, delta(k)) ...
                                        - nctcdf(x(k), nu(k), delta(k)));
end

% Positive data -- reflect about zero and use left tail of reflected CDF
% to get PDF.  Infs return zero.
k = find((x > 0) & isfinite(x) & ~nans);
if any(k)
    y(k) = (-nu(k)./x(k)) .* ...
        (nctcdf(-x(k).*sqrt((nu(k)+2)./nu(k)), nu(k)+2, -delta(k)) ...
                                        - nctcdf(-x(k), nu(k), -delta(k)));
end

% Zero is a special case -- use (single term) power series.
k = find((x == 0) & ~nans);
if any(k)
    y(k) = exp(-0.5*delta(k).^2 - 0.5*log(pi*nu(k)) ...
                           + gammaln(0.5*(nu(k)+1)) - gammaln(0.5*nu(k)));
end
