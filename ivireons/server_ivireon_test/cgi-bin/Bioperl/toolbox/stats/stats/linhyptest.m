function [p,t,rankH] = linhyptest(mu,Sigma,C,H,dfe)
%LINHYPTEST Linear hypothesis test on parameter estimates.
%   P=LINYPTEST(B,COVB,C,H,DFE) returns the p-value P of a hypothesis test
%   on a vector of parameters.  B is a vector of K parameter estimates.
%   COVB is the K-by-K estimated covariance matrix of the parameter
%   estimates.  C and H specify the null hypothesis:  H*b=C, where b is the
%   vector of unknown parameters estimated by B.  DFE is the degrees of
%   freedom for the COVB estimate, or Inf if COVB is known rather than
%   estimated.
%
%   B is required.  The remaining arguments have default values:
%      COVB = eye(K)
%      C = zeros(K,1)
%      H = eye(K)
%      DFE = Inf
%   Note that if H is omitted, C must have K elements and it specifies the
%   null hypothesis values for the entire parameter vector.
%
%   [P,T,R]=LINHYPTEST(...) also returns the test statistic T and the rank R
%   of the hypothesis matrix H.  If DFE is Inf or is not given, T*R is a
%   chi-square statistic with R degrees of freedom .  If DFE is specified as
%   a finite value, T is an F statistic with R and DFE degrees of freedom.
%
%   LINHYPTEST performs a test based on an asymptotic normal distribution
%   for the parameter estimates.  It can be used after any estimation
%   procedure for which the parameter covariances are available, such as
%   REGSTATS or GLMFIT.  For linear regression, the p-values are exact.
%   For other procedures, the p-values are approximate, and may be less
%   accurate than other procedures such as those based on a likelihood
%   ratio.
%
%   See also REGSTATS, GLMFIT, ROBUSTFIT, MNRFIT, NLINFIT, COXPHFIT.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:15:12 $

error(nargchk(1,Inf,nargin,'struct'));

if ~isvector(mu) || ~isnumeric(mu)
    error('stats:linhyptest:BadB','B must be a numeric vector.');
else
    mu = mu(:);
end
k = numel(mu);
if nargin<2 || isempty(Sigma)
    Sigma = eye(k);
elseif ~isnumeric(Sigma) || ~isequal(size(Sigma),[k k])
    error('stats:linhyptest:BadSigma',...
          'Sigma must be a %d-by-%d numeric matrix.',k,k)
end
% check for eigenvalues < -tol

if nargin<3 || isempty(C)
    C = zeros(k,1);
elseif islogical(C)
    C = double(C);
end    
if ~isvector(C) || ~isnumeric(C)
    error('stats:linhyptest:BadC','C must be a numeric vector.');
else
    C = C(:);
end
nC = numel(C);

if nargin<4 || isempty(H)
    if nC~=k
        error('stats:linhyptest:BadC',...
              'The default hypothesis matrix H requires C to have the same length as MU.');
    end
    H = eye(k);
elseif islogical(H)
    H = double(H);
end
if ndims(H)>2 || ~isnumeric(H) || ~isequal(size(H),[nC k])
    error('stats:linhyptest:BadH',...
          'H must be a %d-by-%d numeric matrix.',nC,k);
end

[ok,rankH,H,C] = fullrankH(H,C);
if ~ok
    error('stats:linhyptest:BadH',...
          'H is not full rank and hypotheses are not consistent.')
end


if nargin<5 || isempty(dfe)
    dfe = Inf;
elseif ~isscalar(dfe) || ~isnumeric(dfe) || dfe<=0
    error('stats:linhyptest:BadDfe','DFE must be a positive scalar.');
end

c0 = H*mu;
v0 = H*Sigma*H';
t = (((c0-C)'*inv(v0)*(c0-C)) / nC);
p = fpval(t,rankH,dfe);

% ------------------------
function [ok,p,H,C]=fullrankH(H,C)
%FULLRANKH Make sure hypothesis matrix has full rank
% Find the rank of h and a basis for the row space
[q,r,e] = qr(H',0);
tol = eps(norm(H))^(3/4);
p = sum(abs(diag(r)) > max(size(H))*tol*abs(r(1,1)));

% Get a list of linearly dependent contrasts
E = e(1:p);

% Find coefficients that satisfy these contrasts
b = H(E,:)\C(E);

% Make sure they satisfy the entire set of contrasts
ok = all(abs(H*b-C) < tol);

% Now it is sufficient to use a full-rank subset
H = H(E,:);
C = C(E);
