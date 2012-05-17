function y = ncx2pdf(x,v,delta)
%NCX2PDF Non-central chi-square probability density function (pdf).
%   Y = NCX2PDF(X,V,DELTA) Returns the non-central chi-square pdf with V 
%   degrees of freedom and non-centrality parameter, DELTA, at the values 
%   in X.
%
%   The size of Y is the common size of the input arguments. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.     
%
%   Some texts refer to this distribution as the generalized Rayleigh,
%   Rayleigh-Rice, or Rice distribution.
%
%   See also NCX2CDF, NCX2INV, NCX2RND, NCX2STAT, CHI2PDF, PDF.

%   Reference:
%      [1]  Evans, Merran, Hastings, Nicholas and Peacock, Brian,
%      "Statistical Distributions, Second Edition", Wiley 1993 p. 50-52.
%      [2]  R. Kan and X. Zhao, "Computing the Density Function of
%      Non-central Chi-squared Distribution", unpublished manuscript, 2010.
%      [3]  C. Loader, "Fast and Accurate Calculations of Binomial
%      Probabilities", 2000.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:58:59 $

if nargin < 3
    error('stats:ncx2pdf:TooFewInputs','Requires three input arguments.'); 
end

[errorcode x v delta] = distchck(3,x,v,delta);

if errorcode > 0
    error('stats:ncx2pdf:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Initialize Y to zero.
if isa(x,'single') || isa(v,'single') || isa(delta,'single')
   y = zeros(size(x),'single');
else
   y=zeros(size(x));
end
y(isnan(x) | isnan(v) | isnan(delta)) = NaN;

% Flatten input arrays to be able to use []
x = x(:);
v = v(:);
delta = delta(:);

% Half v
v = v/2;

% Compute special cases
isx0v1 = x==0 & v==1;
y(isx0v1) = 0.5*exp(-0.5*delta(isx0v1));
y(x==0 & v<1) = Inf;

y(delta < 0) = NaN; % Can't have negative non-centrality parameter.
y(v < 0) = NaN; % Can't have negative number of degrees of freedom.

iscentral = delta==0 & v>0; % Without non-centrality, gampdf is faster.
y(iscentral) = gampdf(x(iscentral),v(iscentral),2);

% Compute normal cases
todo = find(x>0 & x<Inf & delta>0 & v>=0);
if isempty(todo)
    return;
end

x = x(todo);
delta = delta(todo);
v = v(todo)-1;

x1 = sqrt(x);
delta1 = sqrt(delta);

% Get some constants
lnrealmin = -708.3964185322641; % log(realmin)
ln2 = 0.6931471805599453; % log(2)

% Upper limit on density
smallv = v<=-0.5;
largev = ~smallv;
ul = zeros(size(x));
ul(smallv) = -0.5*(delta(smallv)+x(smallv)) ...
    +0.5*x1(smallv).*delta1(smallv)./(v(smallv)+1) ...
    +v(smallv).*(log(x(smallv))-ln2) -ln2 -gammaln(v(smallv)+1);
ul(largev) = -0.5*(delta1(largev)-x1(largev)).^2 ...
    +v(largev).*(log(x(largev))-ln2) -ln2 -gammaln(v(largev)+1) ...
    +(v(largev)+0.5).*log( (v(largev)+0.5)./(x1(largev).*delta1(largev) + v(largev)+0.5) );

ULunderflow = ul<lnrealmin;
y(todo(ULunderflow)) = 0;

todo(ULunderflow) = [];
if isempty(todo)
    return;
end
x(ULunderflow) = [];
delta(ULunderflow) = [];
v(ULunderflow) = [];
x1(ULunderflow) = [];
delta1(ULunderflow) = [];

% Can use the scaled Bessel function?
sbes = besseli(v,delta1.*x1,1);
useSB = sbes>0 & sbes<Inf;
y(todo(useSB)) = exp(-ln2 -0.5*(x1(useSB)-delta1(useSB)).^2 ...
    +v(useSB).*log(x1(useSB)./delta1(useSB))) .* sbes(useSB);

todo(useSB) = [];
if isempty(todo)
    return;
end
x(useSB) = [];
delta(useSB) = [];
v(useSB) = [];
x1(useSB) = [];
delta1(useSB) = [];

% Can we use the Bessel function without scaling?
bes = besseli(v,delta1.*x1);
useB = bes>0 & bes<Inf;
y(todo(useB)) = exp(-ln2 -0.5*(x(useB)+delta(useB)) ...
    +v(useB).*log(x1(useB)./delta1(useB))) .* bes(useB);

todo(useB) = [];
if isempty(todo)
    return;
end
x(useB) = [];
delta(useB) = [];
v(useB) = [];

% If neither Bessel function works, use recursion. When non-centrality
% parameter is very large, the initial values of the Poisson numbers used
% in the approximation are very small, smaller than epsilon. This would
% cause premature convergence. To avoid that, we start from the peak of the
% Poisson numbers, and go in both directions.
lnsr2pi = 0.9189385332046727; % log(sqrt(2*pi))
dx = delta.*x/4;

K = max(0,floor(0.5*(sqrt(v.^2+4*dx) - v)));

lntK = zeros(size(K));
isKzero = K==0;
lntK(isKzero) = -lnsr2pi -0.5*(delta(isKzero)+log(v(isKzero))) ...
    -stirlerr(v(isKzero)) -binodeviance(v(isKzero),x(isKzero)/2);
lntK(~isKzero) = -2*lnsr2pi ...
    -0.5*(log(K(~isKzero))+log(v(~isKzero)+K(~isKzero))) ...
    -stirlerr(K(~isKzero)) -stirlerr(v(~isKzero)+K(~isKzero)) ...
    -binodeviance(K(~isKzero),delta(~isKzero)/2) ...
    -binodeviance(v(~isKzero)+K(~isKzero),x(~isKzero)/2);

sumK = ones(size(K));

keep = K>0;
term = ones(size(K));
k = K;
while any(keep)
    term(keep) = term(keep).*(v(keep)+k(keep)).*k(keep)./dx(keep);
    sumK(keep) = sumK(keep) + term(keep);
    keep = keep & k>0 & term>eps(sumK);
    k = k-1;
end

keep = true(size(K));
term = ones(size(K));
k = K+1;
while any(keep)
    term(keep) = term(keep)./(v(keep)+k(keep))./k(keep).*dx(keep);
    sumK(keep) = sumK(keep) + term(keep);
    keep = keep & term>eps(sumK);
    k = k+1;
end

y(todo) = 0.5*exp(lntK + log(sumK));
