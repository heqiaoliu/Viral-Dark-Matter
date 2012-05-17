function [r,type,coefs] = pearsrnd(mu,sigma,skew,kurt,varargin)
%PEARSRND Random arrays from the Pearson system of distributions.
%   R = PEARSRND(MU,SIGMA,SKEW,KURT,M,N) returns an M-by-N matrix of random
%   numbers drawn from the distribution in the Pearson system with mean MU,
%   standard deviation SIGMA, skewness SKEW, and kurtosis KURT.  MU, SIGMA,
%   SKEW, and KURT must be scalars.
%
%   Note: Because R is a random sample, its sample moments, especially the
%   skewness and kurtosis, will typically differ somewhat from the specified
%   distribution moments.
%
%   Some combinations of moments are not valid for any random variable, and in
%   particular, the kurtosis must be greater than the square of the skewness
%   plus 1.  The kurtosis of the normal distribution is defined to be 3.
%
%   R = PEARSRND(MU,SIGMA,SKEW,KURT) returns a scalar value.
%   R = PEARSRND(MU,SIGMA,SKEW,KURT,M,N,...) or
%   R = PEARSRND(MU,SIGMA,SKEW,KURT,[M,N,...]) returns an M-by-N-by-... array.
%
%   [R,TYPE] = PEARSRND(...) returns the type of the specified distribution
%   within the Pearson system.  Type is a scalar integer from 0 to 7.  Set M
%   and N to zero to identify the distribution type without generating any
%   random values.
%
%   The seven distribution types in the Pearson system correspond to the
%   following distributions:
%
%      Type 0: Normal distribution
%      Type 1: Four-parameter beta
%      Type 2: Symmetric four-parameter beta
%      Type 3: Three-parameter gamma
%      Type 4: Not related to any standard distribution.  Density proportional
%              to (1+((x-a)/b)^2)^(-c) * exp(-d*arctan((x-a)/b)).
%      Type 5: Inverse gamma location-scale
%      Type 6: F location-scale
%      Type 7: Student's t location-scale
%
%   [R,TYPE,C] = PEARSRND(...) returns the coefficients of the quadratic
%   polynomial that defines the distribution via the differential equation
%   d(log(p(x)))/dx = -(a + x) / (c(0) + c(1)*x + c(2)*x^2).
%
%   Examples
%      % Generate random values from the standard normal distribution
%      r = pearsrnd(0,1,0,3,100,1);  % equivalent to randn(100,1)
%
%      % Determine the distribution type
%      [r,type] = pearsrnd(0,1,1,4,0,0);  % returns [] for r
%
%   See also RANDOM, JOHNSRND.

%   PEARSRND uses transformations of various standard random variates for types
%   0-III and types V-VII, and a rejection algorithm for type IV.

%   References:
%      [1] Johnson, N.L., S. Kotz, and N. Balakrishnan (1994) Continuous
%          Univariate Distributions, Volume 1,  Wiley-Interscience.
%      [2] Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%          Springer-Verlag.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:43 $

if nargin < 4
    error('stats:pearsrnd:TooFewInputs','Requires at least four input arguments.');
elseif ~(isscalar(mu) && isscalar(sigma) && isscalar(skew) && isscalar(kurt))
    error('stats:pearsrnd:NonScalarInputs','MU, SIGMA, SKEW, and KURT must be scalars.');
end

[err, sizeOut] = statsizechk(4,mu,sigma,skew,kurt,varargin{:});
if err > 0
    error('stats:pearsrnd:InputSizeMismatch','Size information is inconsistent.');
end

outClass = superiorfloat(mu,sigma,skew,kurt);

beta1 = skew.^2;
beta2 = kurt;

% Return NaN for illegal parameter values.
if (sigma < 0) || (beta2 <= beta1 + 1)
    r = NaN(sizeOut,outClass);
    type = NaN;
    coefs = NaN(1,3,outClass);
    return
end

% Classify the distribution and find the roots of c0 + c1*x + c2*x^2
c0 = (4*beta2 - 3*beta1); % ./ (10*beta2 - 12*beta1 - 18);
c1 = skew .* (beta2 + 3); % ./ (10*beta2 - 12*beta1 - 18);
c2 = (2*beta2 - 3*beta1 - 6); % ./ (10*beta2 - 12*beta1 - 18);
if c1 == 0 % symmetric dist'ns
    if beta2 == 3
        type = 0;
    else
        if beta2 < 3
            type = 2;
        elseif beta2 > 3
            type = 7;
        end
        a1 = -sqrt(abs(c0./c2));
        a2 = -a1; % symmetric roots
    end
elseif c2 == 0 % kurt = 3 + 1.5*skew^2 
    type = 3;
    a1 = -c0 ./ c1; % single root
else
    kappa = c1.^2 ./ (4*c0.*c2);
    if kappa < 0
        type = 1;
    elseif kappa < 1-eps
        type = 4;
    elseif kappa <= 1+eps
        type = 5;
    else
        type = 6;
    end
    % Solve the quadratic for general roots a1 and a2 and sort by their real parts
    tmp = -(c1 + sign(c1).*sqrt(c1.^2 - 4*c0.*c2)) ./ 2;
    a1 = tmp ./ c2;
    a2 = c0 ./ tmp;
    if (real(a1) > real(a2)), tmp = a1; a1 = a2; a2 = tmp; end
end

denom = (10*beta2 - 12*beta1 - 18);
if abs(denom) > sqrt(realmin)
    c0 = c0 ./ denom;
    c1 = c1 ./ denom;
    c2 = c2 ./ denom;
    coefs = [c0 c1 c2];
else
    type = 1; % this should have happened already anyway
    % beta2 = 1.8 + 1.2*beta1, and c0, c1, and c2 -> Inf.  But a1 and a2 are
    % still finite.
    coefs = Inf(1,3,outClass);
end

% generate standard (zero mean, unit variance) values
switch type
case 0
    % normal: standard support (-Inf,Inf)
    m1 = zeros(outClass);
    m2 = ones(outClass);
    r = normrnd(m1,m2,sizeOut);
case 1
    % four-parameter beta: standard support (a1,a2)
    if abs(denom) > sqrt(realmin)
        m1 = (c1 + a1) ./ (c2 .* (a2 - a1));
        m2 = -(c1 + a2) ./ (c2 .* (a2 - a1));
    else
        % c1 and c2 -> Inf, but c1/c2 has finite limit
        m1 = c1 ./ (c2 .* (a2 - a1));
        m2 = -c1 ./ (c2 .* (a2 - a1));
    end
    r = a1 + (a2 - a1) .* betarnd(m1+1,m2+1,sizeOut);
case 2
    % symmetric four-parameter beta: standard support (-a1,a1)
    m = (c1 + a1) ./ (c2 .* 2*abs(a1));
    r = a1 + 2*abs(a1) .* betarnd(m+1,m+1,sizeOut);
case 3
    % three-parameter gamma: standard support (a1,Inf) or (-Inf,a1)
    m = (c0./c1 - c1) ./ c1;
    r = c1 .* gamrnd(m+1,1,sizeOut) + a1;
case 4
    % Pearson IV is not a transformation of a standard distribution: density
    % proportional to (1+((x-lambda)/a)^2)^(-m) * exp(-nu*arctan((x-lambda)/a)),
    % standard support (-Inf,Inf)
    m = 1 ./ (2*c2);
    nu = 2.*c1.*(1 - m) ./ sqrt((4.*c0.*c2 - c1.^2));
    b = 2*(m-1);
    a = sqrt(b.^2 .* (b-1) ./ (b.^2 + nu.^2)); % gives unit variance
    lambda = a.*nu ./ b; % gives zero mean
    r = pearson4rnd(m,nu,a,lambda,sizeOut);
case 5
    % inverse gamma location-scale: standard support (-C1,Inf) or (-Inf,-C1)
    C1 = c1 ./ (2*c2);
    r = -((c1 - C1) ./ c2) ./ gamrnd(1./c2 - 1,1,sizeOut) - C1;
case 6
    % F location-scale: standard support (a2,Inf) or (-Inf,a1)
    m1 = (a1 + c1) ./ (c2.*(a2 - a1));
    m2 = -(a2 + c1) ./ (c2.*(a2 - a1));
    % a1 and a2 have the same sign, and they've been sorted so a1 < a2
    if a2 < 0
        nu1 = 2*(m2 + 1);
        nu2 = -2*(m1 + m2 + 1);
        r = a2 + (a2 - a1) .* (nu1./nu2) .* frnd(nu1,nu2,sizeOut);
    else % 0 < a1
        nu1 = 2*(m1 + 1);
        nu2 = -2*(m1 + m2 + 1);
        r = a1 + (a1 - a2) .* (nu1./nu2) .* frnd(nu1,nu2,sizeOut);
    end
case 7
    % t location-scale: standard support (-Inf,Inf)
    nu = 1./c2 - 1;
    r = sqrt(c0 ./ (1-c2)) .* trnd(nu,sizeOut);
end

% scale and shift
r = r.*sigma + mu;


function r = pearson4rnd(m,nu,a,lambda,sizeOut)
% PEARSON4RND Generate Pearson type 4 random variates.
%
%   Based on the exponential rejection method for log-concave densities in
%   Devroye, Section VII.2.  Valid only when m>1, which is if called by PEARSRND.
%
%   References:
%      [1] Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%          Springer-Verlag.  Also available in PDF format on-line at
%          http://cgm.cs.mcgill.ca/~luc/rnbookindex.html.
%      [2] Heinrich, J. (2004) "A Guide to the Pearson Type IV Distribution",
%          CDF/MEMO/STATISTICS/PUBLIC/6820, available on-line at 
%          http://www-cdf.fnal.gov/publications/cdf6820_pearson4.pdf.

logK = -logHypGeo(m,nu/2) + (gammaln(m) - gammaln(m-.5)) - log(sqrt(pi)*a);

% Generate y = arctan(x) with density g(y) = K*cos(y)^(2m-1)*exp(-nu*y)
b = 2*(m-1);
M = atan(-nu./b); % mode of y = arctan(x)
cosM = a ./ sqrt(b-1);
loggM = b.*log(cosM) - nu.*M; % log(g(mode)) + log(K)
invgM = exp(-loggM - logK); % 1/g(mode)

outClass = superiorfloat(m,nu,a,lambda);
r = zeros(sizeOut,outClass);
j = 1:numel(r);
while length(j) > 0
    U = 4*rand(size(j)); % dist'd Unif([0,4])
    S = (U>2); % use this to get a random +1/-1
    U(S) = U(S) - 2; % now dist'd Unif([0,2])
    negEstar = log(max(U,1)-(U>1)); % zero for U<=1, dist'd Exp(1) for U>1
    X = min(U,1) - negEstar; % U or 1+Estar
    Z = log(rand(size(j))) + negEstar; % -E or -E-Estar
    X = M + (2*S-1).*X.*invgM;
    k = (abs(X) < pi/2) & (Z <= b.*log(abs(cos(X))) - nu.*X - loggM);
    r(j(k)) = X(k);
    j(k) = [];
end

% Transform, scale, and shift to standard Pearson type IV
r = a.*tan(r) + lambda;


function logF = logHypGeo(x,y)
% LOGHYPGEO A special case of the hypergeometric function.
%
% Returns log F(-iy,iy,x,1) = log abs(gamma(x)/gamma(x+iy))^2, where F is the
% complex hypergeometric function.  Based on methods described in Heinrich, J. (2004)
% "A Guide to the Pearson Type IV Distribution", CDF/MEMO/STATISTICS/PUBLIC/6820.

% For small x, compute (1+(y/x)^2)*...*(1+(y/(x+n))^2) which scales F(-iy,iy,x,1)
% to F(-iy,iy,x+n,1), which we can compute quickly if x+n is large.
if x < 100
    xstep = x:1:100;
    % r = prod(1 + (y./xstep).^2);
    logr = sum(log1p((y./xstep).^2));
    x = xstep(end) + 1;
else
    logr = 0;
end

% Compute F(-iy,iy,x+n,1), then multiply by r to get F(-iy,iy,x,1)
logs = zeros(class(y)); logp = zeros(class(y)); f = zeros(class(y));
while logp-logs > log(eps)
    % p = p .* (y.^2 + f.^2) ./ (x.*(f+1));
    logp = logp + log(y.^2 + f.^2) - log(x.*(f+1));
    x = x + 1;
    f = f + 1;
    % s = s + p;
    logs = logs + log1p(exp(logp - logs));
end
% F = r.*s;
logF = logr + logs;
