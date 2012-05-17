function y = ncfpdf(x,nu1,nu2,delta)
%NCFPDF Noncentral F probability density function (pdf).
%   Y = NCFPDF(X,NU1,NU2,DELTA) returns the noncentral F pdf with numerator 
%   degrees of freedom (df) NU1, denominator df NU2, and noncentrality
%   parameter DELTA, at the values in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     
%
%   See also NCFCDF, NCFINV, NCFRND, NCFSTAT, FPDF, PDF.

%   Reference:
%      [1] Johnson, Kotz, and Balakrishnan, "Continuous Univariate
%        Distributions, Vol. 2" (2nd edition), Wiley, 1995, eq. 30.7.
%      [2]  R. Kan and X. Zhao, "Algorithm of sglncfpdf_raw.m", unpublished
%      manuscript, 2010.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:58:56 $

if nargin < 4
    error('stats:ncfpdf:TooFewInputs','Requires four input arguments.');
end

[errorcode, x, nu1, nu2, delta] = distchck(4,x,nu1,nu2,delta);

if errorcode > 0
    error('stats:ncfpdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero.
if isa(x,'single') || isa(nu1,'single') || isa(nu2,'single') || isa(delta,'single')
   y = zeros(size(x),'single');
else
   y = zeros(size(x));
end
y(isnan(x) | isnan(nu1) | isnan(nu2) | isnan(delta)) = NaN;

% Take care of special cases:
% For invalid parameters, result is NaN
k = nu1<=0 | nu2<=0 | delta<0;
y(k) = NaN;

% Edge case (x=0):
y(x==0 & nu1<2 & ~k) = Inf;       % if nu1<2, result is Inf
k2 = x==0 & nu1==2 & ~k;
if any(k2(:))
    y(k2) = exp(-delta(k2)/2);    % if nu1==2, this is the result
end

% Central distribution, delta==0
central = delta==0 & ~k & x>0;
if any(central(:))
    y(central) = fpdf(x(central),nu1(central),nu2(central));
end
todo = find(x>0 & ~(k | central));
if isempty(todo) 
    return; 
end

% Use good indices only
nu1 = nu1(todo);
nu2 = nu2(todo);
x = x(todo);
delta = delta(todo);

% To simplify computation, pre-divide nu1, nu2 and delta
nu1 = nu1/2; nu2 = nu2/2; delta = delta/2;

% Use z and scaled x for convenience
z = nu1.*x ./ (nu1.*x+nu2);
z1 = nu2 ./ (nu1.*x+nu2);
xs = delta.*z;

% Make constants
lnsr2pi = 0.9189385332046728;

% Find max K at which we start the recursion series
K = zeros(size(x));
termK = zeros(size(x));
rsum = zeros(size(x));

% Integer nu2
intnu2 = nu2==round(nu2);
if any(intnu2(:))
    smallx = xs<=nu1./nu2; % K=0
    largex = xs>=nu2.*(nu1+nu2-1) & ~smallx; % K=nu2
    K(intnu2 & largex) = nu2(intnu2 & largex);
    idx = intnu2 & ~(smallx | largex); % Solve eqn for K
    if any(idx(:))
        d = 0.5*(1-xs(idx)-nu1(idx));
        K(idx) = floor(d + sqrt(d.^2 + xs(idx).*(nu2(idx)+1)));
    end

    % Case K==nu2
    keqnu2 = intnu2 & K==nu2;
    idz = keqnu2 & z<0.9;
    termK(idz) = (nu1(idz)+nu2(idz)-1).*log(z(idz));
    idz1 = keqnu2 & ~idz;
    termK(idz1) = (nu1(idz1)+nu2(idz1)-1).*log1p(-z1(idz1));

    % Case K==0
    zerok = intnu2 & (nu1+K)<=1;
    termK(zerok) = stirlerr(nu1(zerok)+nu2(zerok)) ...
        -stirlerr(nu1(zerok)) -stirlerr(nu2(zerok)) ...
        -binodeviance(nu1(zerok),(nu1(zerok)+nu2(zerok)).*z(zerok)) ...
        -binodeviance(nu2(zerok),(nu1(zerok)+nu2(zerok)).*z1(zerok));
    
    % All K's but K==nu2 or K==0
    other = intnu2 & ~(keqnu2 | zerok);
    termK(other) = stirlerr(nu1(other)+nu2(other)-1) ...
        -stirlerr(nu1(other)+K(other)-1) ...
        -stirlerr(nu2(other)-K(other)) ...
        -binodeviance(nu1(other)+K(other)-1,(nu1(other)+nu2(other)-1).*z(other)) ...
        -binodeviance(nu2(other)-K(other),(nu1(other)+nu2(other)-1).*z1(other));
    
    % Poisson density for the leading term
    x1 = delta.*z1;
    smallk = intnu2 & K<=x1*realmin;
    y(todo(smallk)) = termK(smallk)-x1(smallk);
    otherk = intnu2 & ~smallk;
    y(todo(otherk)) = termK(otherk) -lnsr2pi -0.5*log(K(otherk)) ...
        -stirlerr(K(otherk)) -binodeviance(K(otherk),x1(otherk));

    % Sum recursively downwards
    term = ones(size(x));
    k = K;
    ok = intnu2 & k>0;
    while any(ok(:))
        k(ok) = k(ok)-1;
        term(ok) = term(ok).*(k(ok)+1).*(k(ok)+nu1(ok))./(nu2(ok)-k(ok))./xs(ok);
        ok = ok & term>=eps(rsum);
        rsum(ok) = rsum(ok) + term(ok);
    end

    % Sum recursively upwards
    term = ones(size(x));
    k = K;
    ok = intnu2 & k<nu2;
    while any(ok(:))
        term(ok) = term(ok).*xs(ok).*(nu2(ok)-k(ok))./(k(ok)+nu1(ok))./(k(ok)+1);
        ok = ok & term>=eps(rsum);
        rsum(ok) = rsum(ok) + term(ok);
        k(ok) = k(ok)+1;
    end
end

% Non-integer nu2
if any(~intnu2(:))
    % Compute K for large x. Otherwise set K to 0.
    largex = ~intnu2 & xs>nu1./(nu1+nu2);
    d = 0.5*(1+xs(largex)-nu1(largex));
    K(largex) = floor(d + sqrt(d.^2 + xs(largex).*(nu1(largex)+nu2(largex)-1)));
    
    % Case for K==0
    zerok = ~intnu2 & (nu1+K)<=1;
    termK(zerok) = stirlerr(nu1(zerok)+nu2(zerok)) ...
        -stirlerr(nu1(zerok)) -stirlerr(nu2(zerok)) ...
        -binodeviance(nu1(zerok),(nu1(zerok)+nu2(zerok)).*z(zerok)) ...
        -binodeviance(nu2(zerok),(nu1(zerok)+nu2(zerok)).*z1(zerok));
    
    % Case for K~=0
    other = ~intnu2 & ~zerok;
    termK(other) = stirlerr(nu1(other)+nu2(other)+K(other)-1) ...
        -stirlerr(nu1(other)+K(other)-1) -stirlerr(nu2(other)) ...
        -binodeviance(nu1(other)+K(other)-1,(nu1(other)+nu2(other)+K(other)-1).*z(other)) ...
        -binodeviance(nu2(other),(nu1(other)+nu2(other)+K(other)-1).*z1(other));
    
    % Poisson density at the leading term
    smallk = ~intnu2 & K<=delta*realmin;
    y(todo(smallk)) = termK(smallk)-delta(smallk);
    other = ~intnu2 & ~smallk;
    y(todo(other)) = termK(other) -lnsr2pi -0.5*log(K(other)) ...
        -stirlerr(K(other)) -binodeviance(K(other),delta(other));

    % Sum recursively downwards
    term = ones(size(x));
    k = K;
    ok = ~intnu2 & k>0;
    while any(ok(:))
        k(ok) = k(ok)-1;
        term(ok) = term(ok).*(k(ok)+1).*(k(ok)+nu1(ok))./(k(ok)+nu1(ok)+nu2(ok))./xs(ok);
        ok = ok & term>=eps(rsum);
        rsum(ok) = rsum(ok) + term(ok);
    end
    
    % Sum recursively upwards
    term = ones(size(x));
    k = K;
    ok = ~intnu2;
    while any(ok(:))
        term(ok) = term(ok).*xs(ok).*(k(ok)+nu1(ok)+nu2(ok))./(k(ok)+nu1(ok))./(k(ok)+1);
        ok = ok & term>=eps(rsum);
        rsum(ok) = rsum(ok) + term(ok);
        k(ok) = k(ok)+1;
    end
end

% Use the recursively accumulated sum and the leading term to compute the
% density
zerok = (nu1+K)<=1;
y(todo(zerok)) = exp(y(todo(zerok))) .*(1+rsum(zerok)) ...
    .*sqrt(nu1(zerok).*nu2(zerok)./(nu1(zerok)+nu2(zerok))/(2*pi)) ./x(zerok);
keqnu2 = ~zerok & intnu2 & K==nu2;
y(todo(keqnu2)) = exp(y(todo(keqnu2))) .*(1+rsum(keqnu2)) .*nu1(keqnu2).*z1(keqnu2);
idx = ~zerok & intnu2 & ~keqnu2;
y(todo(idx)) = exp(y(todo(idx))) .*(1+rsum(idx)) .*nu1(idx).*z1(idx) ...
    .*sqrt((nu1(idx)+nu2(idx)-1)./(nu2(idx)-K(idx))./(nu1(idx)+K(idx)-1)/(2*pi));
idx = ~intnu2 & ~zerok;
y(todo(idx)) = exp(y(todo(idx))) .*(1+rsum(idx)) .*nu1(idx).*z1(idx) ...
    .*sqrt((nu1(idx)+nu2(idx)+K(idx)-1)./nu2(idx)./(nu1(idx)+K(idx)-1)/(2*pi));
