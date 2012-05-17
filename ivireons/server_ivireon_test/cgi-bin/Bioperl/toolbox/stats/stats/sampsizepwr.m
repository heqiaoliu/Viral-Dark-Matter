function out=sampsizepwr(TestType,params,p1,power,n,varargin)
%SAMPSIZEPWR Sample size and power calculation for hypothesis test.
%   N=SAMPSIZEPWR('TESTTYPE',P0,P1) returns the sample size N required for
%   a two-sided test of the specified type to have a power (probability of
%   rejecting the null hypothesis when the alternative is true) of 0.90
%   when the significance level (probability of rejecting the null
%   hypothesis when the null hypothesis is true) is 0.05.  P0 specifies the
%   parameter values under the null hypothesis.  P1 specifies the value of
%   the single parameter being tested under the alternative hypothesis.
%
%   The following TESTTYPE values are available:
%
%     'z'   z-test for normally distributed data with known standard
%           deviation.  P0 is a two-element vector [MU0 SIGMA0] of the mean
%           and standard deviation, respectively, under the null hypothesis.
%           P1 is the value of the mean under the alternative hypothesis.
%     't'   t-test for normally distributed data with unknown standard
%           deviation.  P0 is a two-element vector [MU0 SIGMA0] of the mean
%           and standard deviation, respectively, under the null hypothesis.
%           P1 is the value of the mean under the alternative hypothesis.
%     'var' Chi-square test of variance for normally distributed data.
%           P0 is the variance under the null hypothesis.  P1 is the variance
%           under the alternative hypothesis.
%     'p'   Test of the P parameter (success probability) for a binomial
%           distribution.  P0 is the value of P under the null hypothesis.
%           P1 is the value of P under the alternative hypothesis.
%
%           The 'p' test for the binomial distribution is a discrete test for
%           which increasing the sample size does not always increase the
%           power.  For N values larger than 200, there may be values smaller
%           than the returned N value that also produce the desired power.
%
%   N=SAMPSIZEPWR('TESTTYPE',P0,P1,POWER) returns the sample size N such that
%   the power is POWER for the parameter value P1.
%
%   POWER=SAMPSIZEPWR('TESTTYPE',P0,P1,[],N) returns the power achieved for a
%   sample size of N when the true parameter value is P1.
%
%   P1=SAMPSIZEPWR('TESTTYPE',P0,[],POWER,N) returns the parameter value
%   detectable with the specified sample size N and power POWER.
%
%   When computing P1 for the 'p' test, if no alternative can be rejected
%   for a given P0 and ALPHA value, the function displays a warning message
%   and returns NaN.
%
%   [...]=SAMPSIZEPWR(...,N,'PARAM1',val1,'PARAM2',val2,...) specifies one or
%   more of the following name/value pairs:
%
%      'alpha'    Significance level of the test (default 0.05)
%      'tail'     The type of test is one of the following:
%         'both'    two-sided test for an alternative not equal to P0
%         'right'   one-sided test for an alternative larger than P0
%         'left'    one-sided test for an alternative smaller than P0
%
%   The SAMPSIZEPWR function computes the sample size, power, or alternative
%   hypothesis value given values for the other two.  Specify one of these as
%   [] to compute it.  The remaining parameters (and ALPHA) can be scalars or
%   arrays of the same size.
%
%   Example:
%      Compute the mean closest to 100 that can be determined to be
%      significantly different from 100 using a t-test with a sample size
%      of 60 and a power of 0.8.
%        mu1 = sampsizepwr('t',[100 10],[],.8,60)
%
%      Compute the sample size N required to distinguish p=.26 from p=.2
%      with a binomial test.  The result is approximate, so make a plot to
%      see if any smaller N values also have the required power of 0.6.
%        Napprox = sampsizepwr('p',.2,.26,.6)
%        nn = 1:250;
%        pwr = sampsizepwr('p',.2,.26,[],nn);
%        Nexact = min(nn(pwr>=.6))
%        plot(nn,pwr,'b-', [Napprox Nexact],pwr([Napprox Nexact]),'ro');
%        grid on
% 
%   See also VARTEST, TTEST, ZTEST, BINOCDF.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:25 $

% Check inputs
error(nargchk(3,Inf,nargin,'struct'));
if nargin==3
    power = 0.90;
    n = [];
elseif nargin==4
    n = [];
end
[TestType,p0,p1,power,n,powerfun,outclass,args,tail,alpha] = ...
              errorcheck(TestType,params,p1,power,n,varargin{:});
% Note: args is a cell array containing 0 or more parameters that define
% the null distribution but that are not being tested.  At the moment args
% will either be {} or {sigma}.

% Allocate output of proper size and class.  With a mixture of empty,
% scalar, and larger inputs, alpha is guaranteed to have the right size.
out = zeros(size(alpha),outclass);

% Compute whichever one of power/n/p1 that is now empty
if isempty(power)
    % Compute power given effect size and sample size
    out(:) = powerfun(p0,p1,args{:},alpha,tail,n);
    
elseif isempty(n)
    % Compute sample size given power and effect size
    switch(TestType)
      case {'Z', 't'}
        % Calculate one-sided Z value directly
        out(:) = z1testN(p0,p1,args{1},power,alpha,tail);
        
        % Iterate upward from there for the other cases
        if TestType(1)=='t' || tail==0
            if TestType(1)=='t'
                out = max(out,2); % t test requires at least 2
            end
            out(:) = searchupN(out,powerfun,p0,p1,args,power,alpha,tail);
        end

      case 'Variance'
        % Use a binary search method
        out(:) = searchbinaryN(powerfun,[1 100],p0,p1,power,alpha,tail);

      case 'P'
        % Use a binary search method
        out(:) = searchbinaryN(powerfun,[0 100],p0,p1,power,alpha,tail);
        
        % Adjust for discrete distribution
        t = out<=200;
        if any(t(:))
            % Try values from 1 up to N (out) and pick the smallest
            % acceptable value
            out(t) = adjdiscreteN(out(t),powerfun,p0,p1(t),alpha(t),tail,power(t));
        end
        if any(~t(:))
            warning('stats:sampsizepwr:ApproximateN',...
                    ['Values N>200 are approximate.  Plotting the power as a function\n' ...
                     'of N may reveal lower N values that have the required power.']);
        end
    end

else
    % Compute effect size given power and sample size
    switch(TestType)
      case 'Z'
        % Z (normal) test
        out(:) = findP1z(p0,args{1},power,n,alpha,tail);
        
      case 't'
        % t test
        out(:) = findP1t(p0,args{1},power,n,alpha,tail);

      case 'Variance'
        % chi-square (variance) test
        out(:) = findP1v(p0,power,n,alpha,tail);

      case 'P'
        % binomial (p) test
        out(:) = findP1p(p0,power,n,alpha,tail);
    end
end

% -------------------------
function N=z1testN(mu0,mu1,sig,desiredpower,alpha,tail)
%Z1TESTN Sample size calculation for the one-sided Z test

% Compute the one-sided normal value directly.  Note that we cannot do this
% for the t distribution, because tinv depends on the unknown degrees of
% freedom (n-1).
if tail==0
    alpha = alpha/2;
end
z1 = -norminv(alpha);
z2 = norminv(1-desiredpower);
mudiff = abs(mu0 - mu1) / sig;
N = ceil(((z1-z2) ./ mudiff).^2);

% -------------------------
function mu1=findP1z(mu0,sig,desiredpower,N,alpha,tail)
%FINDP1Z Find alternative hypothesis parameter value P1 for Z test

if tail==0
    alpha = alpha/2;
end
sig = sig./sqrt(N);

% Get quantiles of the normal or t distribution
if tail==-1        % lower tailed test
    z1 = norminv(alpha);          % get lower tail under H0
    z2 = norminv(desiredpower);   % match to upper tail under H1
else               % upper or two-sided
    z1 = norminv(1-alpha);        % get upper tail under H0
    z2 = norminv(1-desiredpower); % match to lower tail under H1
end
mu1 = mu0 + sig .* (z1-z2); % explicit formula for 1-sided result

if tail==0
    % For 2-sided test, refine by taking the other tail into account
    todo = 1:numel(alpha);
    desiredbeta = 1-desiredpower;
    betahi = desiredbeta;              % beta considering only the upper critical value
    betalo = zeros(size(desiredbeta)); % non-beta amount below lower critical value
    while(true)
        % Compute probability of being below the lower critical value under H1
        betalo(todo) = normcdf(-z1(todo) + (mu0-mu1(todo))./sig(todo));
        
        % See if the upper and lower probabilities are close enough
        todo = todo(abs((betahi(todo)-betalo(todo)) - desiredbeta(todo)) > 1e-6*desiredbeta(todo));
        if isempty(todo)
            break
        end
        
        % Find a new mu1 by adjusting beta to take lower tail into account
        betahi(todo) = desiredbeta(todo) + betalo(todo);
        mu1(todo) = mu0 + sig(todo) .* (z1(todo)-norminv(betahi(todo)));
    end
end

% -------------------------
function mu1=findP1t(mu0,sig,desiredpower,N,alpha,tail)
%FINDP1Z Find alternative hypothesis parameter value P1 for Z test

if tail==0
    a2 = alpha/2;
else
    a2 = alpha;
end

% Get quantiles of the normal or t distribution
if tail==-1       % lower tailed test
    z1 = norminv(alpha);           % get lower tail under H0
    z2 = norminv(desiredpower);    % match to upper tail under H1
else              % upper or two-tailed test
    z1 = norminv(1-a2);            % get upper tail under H0
    z2 = norminv(1-desiredpower);  % match to lower tail under H1

end
mu1 = mu0 + sig .* (z1-z2)./sqrt(N); % explicit formula for 1-sided normal result

% Refine using fzero
for j=1:numel(mu1)
    if mu1(j)>mu0
        F0 = @(mu1arg) powerfunT(mu0,max(mu0,mu1arg),sig,alpha(j),tail,N(j)) - desiredpower(j);
    else
        F0 = @(mu1arg) powerfunT(mu0,min(mu0,mu1arg),sig,alpha(j),tail,N(j)) - desiredpower(j);
    end
    mu1(j) = fzero(F0,mu1(j));
end

% -------------------------
function p1=findP1v(p0,desiredpower,N,alpha,tail)
%FINDP1V Find alternative hypothesis parameter value P1 for variance test

% F and Finv are the cdf and inverse cdf, define here to make the code
% simpler below
F = @(x,n,p1) chi2cdf(x.*(n-1)./p1, n-1);    % cdf for s^2
Finv = @(p,n,p1) p1.*chi2inv(p,n-1)./(n-1);  % inverse

if tail==0
    alpha = alpha/2;
end
desiredbeta = 1-desiredpower;

% Calculate critical values and p1 for one-sided test
if tail>=0
    critU = Finv(1-alpha,N,p0);                 % upper critical value for H0
    p1 = 1 ./ Finv(desiredbeta,N,1./critU);     % p1 giving this power
end
if tail<=0
    critL = Finv(alpha,N,p0);                   % lower tail critical value H0
end
if tail<0
    p1 = 1 ./ Finv(desiredpower,N,1./critL);    % p1 giving this power
end

if tail==0
    % For 2-sided test, we have the upper tail probability under H1.
    % Refine by taking the other tail into account.
    todo = 1:numel(alpha);
    betahi = desiredbeta;               % beta considering only the upper critical value
    betalo = zeros(size(desiredbeta));  % non-beta amount below lower critical value
    while(true)
        % Compute probability of being in the lower tail under H1
        betalo(todo) = F(critL(todo),N(todo),p1(todo));
        
        % See if the upper and lower probabilities are close enough
        obsbeta = betahi(todo) - betalo(todo);
        todo = todo(abs(obsbeta - desiredbeta(todo)) > 1e-6*desiredbeta(todo));
        if isempty(todo)
            break
        end
        
        % Find a new mu1 by adjusting beta to take lower tail into account
        betahi(todo) = desiredbeta(todo) + betalo(todo);
        p1(todo) = 1 ./ Finv(betahi(todo),N(todo),1./critU(todo));
    end
end

% -------------------------
function p1=findP1p(p0,desiredpower,N,alpha,tail)
%FINDP1P Find alternative hypothesis parameter value P1 for p test

% Get critical values
[critL,critU] = getcritP(p0,N,alpha,tail);

% Use a normal approximation to find P1 values
sigma = sqrt(p0.*(1-p0)./N);
p1 = findP1z(p0,sigma,desiredpower,N,alpha,tail);

% Problem if we have no critical region left
if tail==0
    t = (critL==0 & critU==N);
elseif tail==1
    t = (critU==N);
else % tail == -1
    t = (critL==0);
end
if any(t)
    warning('stats:sampsizepwr:NoValidParameter',...
            'Parameters set to NaN when no parameters can produce the required power.')
    p1(t) = NaN;
end

% Force in bounds
t = p1<=0;
if any(t(:))
    p1(t) = p0/2;
end
t = p1>=1;
if any(t(:))
    p1(t) = 1 - p0/2;
end
    
% Refine using fzero
for j=1:numel(p1)
    if ~isnan(p1(j));
        if p1(j)>p0
            F0 = @(p1arg) powerfunP(p0,max(p0,min(1,p1arg)),alpha(j),tail,N(j),critL(j),critU(j)) - desiredpower(j);
        else
            F0 = @(p1arg) powerfunP(p0,max(0,min(p0,p1arg)),alpha(j),tail,N(j),critL(j),critU(j)) - desiredpower(j);
        end
        p1(j) = fzero(F0,p1(j));
    end
end

% -------------------------
function [critL,critU]=getcritP(p0,N,alpha,tail)
%getcritP Get upper and lower critical values for binomial (p) test.
%   For two-sided tests, this function tries to compute critical values
%   favorable for p0<.5.  It does this by allocating alpha/2 to the lower
%   tail where the probabilities come in larger chunks, then using any
%   left-over alpha, probably more than alpha/2, for the upper tail.
%
%   These critical values are defined so that critL<=s<=critU are the
%   values that are not rejected.

% Get part of alpha available for lower tail
if tail==0
    Alo = alpha/2;
elseif tail<0
    Alo = alpha;
else
    Alo = 0;
end

% Calculate critical values, allocating any leftover part of alpha to the
% upper tail
critU = N;
critL = zeros(size(N));
if tail<=0
    critL = binoinv(Alo,N,p0);   % position of required lower tail
    Alo = binocdf(critL,N,p0);   % discontinuous, compute real lower prob
    t = (critL<N) & (Alo <= alpha/2);
    critL(t) = critL(t) + 1;
    Alo(~t) = Alo(~t) - binopdf(critL(~t),N(~t),p0);
end
if tail>=0
    Aup = max(0,alpha-Alo);
    critU = binoinv(1-Aup,N,p0); % position of upper tail
end


% -------------------------
function N=searchupN(N,F,mu0,mu1,args,desiredpower,alpha,tail)
%searchup Sample size calculation searching upward

% Count upward until we get the value we need
todo = 1:numel(alpha);
while(~isempty(todo))
    actualpower = F(mu0,mu1(todo),args{:},alpha(todo),tail,N(todo));
    todo = todo(actualpower < desiredpower(todo));
    N(todo) = N(todo)+1;
end

% -------------------------
function N=searchbinaryN(F,lohi,p0,p1,desiredpower,alpha,tail)
%searchbinaryN Sample size calculation via binary search

nlo = repmat(lohi(1),size(alpha));  % guaranteed lower bound
nhi = repmat(lohi(2),size(alpha));  % trial upper bound
obspower = F(p0,p1,alpha,tail,nhi);

% Iterate on n until we achieve the desired power
todo = 1:numel(alpha);
while(~isempty(todo))
    % Find an upper bound for the required sample size
    todo = todo(obspower(todo)<desiredpower(todo));
    nhi(todo) = nhi(todo) * 2;
    obspower(todo) = F(p0,p1(todo),alpha(todo),tail,nhi(todo));
end
% Now nhi is a guaranteed upper bound

% Binary search between these bounds for required sample size
todo = find(nhi > nlo+1);
while(~isempty(todo))
    n = floor((nhi(todo)+nlo(todo))/2);
    obspower = F(p0,p1(todo),alpha(todo),tail,n);
    toohigh = (obspower>desiredpower(todo));
    nhi(todo(toohigh)) = n(toohigh);
    nlo(todo(~toohigh)) = n(~toohigh);
    todo = todo(nhi(todo)>nlo(todo)+1);
end
N = nhi;

% ------------------
function N = adjdiscreteN(N,powerfun,p0,p1,alpha,tail,power)
%ADJDISCRETEN Adjust sample size to take discreteness into account
%   On input N is a sample size that meets the requirements and N-1
%   does not meet them.  We still have to examine other lower N values,
%   though, because the power function is not monotone.

    for j=1:numel(N)
        allN = 1:N(j);
        obspower = powerfun(p0,p1(j),alpha(j),tail,allN);
        N(j) = allN(find(obspower>=power(j),1,'first'));
    end

% ----------- Power functions
function power=powerfunN(mu0,mu1,sig,alpha,tail,n)
%POWERFUNN Normal power calculation
    S = sig ./ sqrt(n);
    if tail==0
        critL = norminv(alpha/2,mu0,S);
        critU = mu0 + (mu0-critL);  % reflect around mu0
        power = normcdf(critL,mu1,S) + normcdf(-critU,-mu1,S); % P(z < critL) + P(z > critU)
    elseif tail==1
        crit = mu0 + (mu0-norminv(alpha,mu0,S));
        power = normcdf(-crit,-mu1,S); % P(z > crit)
    else % tail==-1
        crit = norminv(alpha,mu0,S);
        power = normcdf(crit,mu1,S);   % P(z < crit)
    end       

function power=powerfunT(mu0,mu1,sig,alpha,tail,n)
%POWERFUNT T power calculation
    S = sig ./ sqrt(n);       % std dev of mean
    ncp = (mu1-mu0) ./ S;     % noncentrality parameter

    if tail==0
        critL = tinv(alpha/2,n-1);   % note tinv() is negative
        critU = -critL;
        power = nctcdf(critL,n-1,ncp) + nctcdf(-critU,n-1,-ncp); % P(t < critL) + P(t > critU)
    elseif tail==1
        crit = tinv(1-alpha,n-1);
        power = nctcdf(-crit,n-1,-ncp); % 1-nctcdf(crit,n-1,ncp), P(t > crit)
    else % tail==-1
        crit = tinv(alpha,n-1);
        power = nctcdf(crit,n-1,ncp); % P(t < crit)
    end        

function power=powerfunV(v0,v1,alpha,tail,n)
%POWERFUNV Chi-square power calculation
    if tail==0
       critU = v0 .* chi2inv(1-alpha/2,n-1);   % upper critical value
       critL = v0 .* chi2inv(alpha/2,n-1);     % lower critical value
       power = chi2cdf(critL./v1,n-1) + ...
               chi2pval(critU./v1,n-1); % P(x < critL) + P(x > critH)
    elseif tail==1
        crit = v0 .* chi2inv(1-alpha,n-1);
        power = chi2pval(crit./v1,n-1); % P(x > crit)
    else % tail==-1
        crit = v0 .* chi2inv(alpha,n-1);
        power = chi2cdf(crit./v1,n-1);  % P(x < crit)
    end       

function [power,critL,critU]=powerfunP(p0,p1,alpha,tail,n,critL,critU)
%POWERFUNP Binomial power calculation
    if nargin<6
        [critL,critU] = getcritP(p0,n,alpha,tail);
    end
    if tail==0
        power = binocdf(critL-1,n,p1) + 1-binocdf(critU,n,p1);
    elseif tail==1
        power = 1-binocdf(critU,n,p1);
    else % tail = -1
        power = binocdf(critL-1,n,p1);
    end

% ---------------------
function [TestType,p0,p1,power,n,powerfun,outclass,args,tail,alpha] = ...
                         errorcheck(TestType,params,p1,power,n,varargin)
% Common error checking
if isempty(TestType) || ~ischar(TestType) || size(TestType,1)~=1
    error('stats:sampsizepwr:BadTestType','Invalid TESTTYPE argument.');
end

testtypes = {'Z'   't'    'Variance' 'P'};
nparams   = [2     2      1          1];
Lbound    = [-Inf  -Inf   0          0];
Ubound    = [Inf   Inf    Inf        1];
ttindex = find(strncmpi(TestType,testtypes,length(TestType)));
if ~isscalar(ttindex) 
    error('stats:sampsizepwr:BadTestType','Invalid TESTTYPE argument.');
end
TestType = testtypes{ttindex};
nparams = nparams(ttindex);
Lbound = Lbound(ttindex);
Ubound = Ubound(ttindex);
if ~isnumeric(params) || numel(params)~=nparams
    error('stats:sampsizepwr:BadParams',...
          'PARAMS must be numeric and contain %d elements.',nparams);
end

p0 = params(1);                    % null value for parameter being tested
args = num2cell(params(2:end));    % any other parameters

% Error checking specific to test type
switch(TestType)
  case 'Z'
    if args{1}<=0
        error('stats:sampsizepwr:BadParams',...
              'The variance (second element of PARAMS) must be positive.');
    end
    powerfun = @powerfunN;

  case 't'
    if args{1}<=0
        error('stats:sampsizepwr:BadParams',...
              'The variance (second element of PARAMS) must be positive.');
    end
    powerfun = @powerfunT;

  case 'Variance'
    if p0<=0 
        error('stats:sampsizepwr:BadParams',...
              'PARAMS must be positive for a variance test.');
    end
    powerfun = @powerfunV;

  case 'P'
    if p0<=0 || p0>=1
        error('stats:sampsizepwr:BadProbability',...
              'PARAMS must be between 0 and 1 for a binomial test.');
    end
    powerfun = @powerfunP;
end

% Get optional parameters
paramNames = {'alpha'  'tail'};
paramDflts = {0.05     'both'};
[errid,errmsg,alpha,tail] = internal.stats.getargs(paramNames, paramDflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:sampsizepwr:%s',errid),errmsg);
end

% Self-explanatory tests
if isempty(alpha)
    alpha = 0.05;
elseif ~isnumeric(alpha) || any(alpha(:)<=0) || any(alpha(:)>=1)
    error('stats:sampsizepwr:BadAlpha',...
          'ALPHA must be between 0 and 1.');
end

if isempty(tail)
    tail = 0;
elseif ischar(tail) && (size(tail,1)==1)
    tail = find(strncmpi(tail,{'left','both','right'},length(tail))) - 2;
end
if ~isscalar(tail) || ~ismember(tail,-1:1)
    error('stats:sampsizepwr:BadTail', ...
          'TAIL must be one of the strings ''both'', ''right'', or ''left''.');
end

if isempty(p1)+isempty(power)+isempty(n) ~=1
    error('stats:sampsizepwr:BadInput',...
          'Exactly one of P1, POWER, and N must be empty.');
end

% Expand non-empty power/n/p1 so they are all the same size
if isempty(p1)
    [err,power,n,alpha] = distchck(3,power,n,alpha);
    outclass = superiorfloat(power,n,alpha);
elseif isempty(power)
    [err,p1,n,alpha] = distchck(3,p1,n,alpha);
    outclass = superiorfloat(p1,n,alpha);
else % n is empty
    [err,p1,power,alpha] = distchck(3,p1,power,alpha);
    outclass = superiorfloat(power,p1,alpha);
end
if err > 0
    error('stats:sampsizepwr:InputSizeMismatch',...
          'Size information is inconsistent among P1, POWER, N, and ALPHA.');
end

if ~isempty(power) && (~isnumeric(power) || any(power(:)<=0) || any(power(:)>=1))
    error('stats:sampsizepwr:BadPower',...
          'POWER must be between 0 and 1.');
end
if ~isempty(p1)
    if ~isnumeric(p1)
        error('stats:sampsizepwr:BadAlternative','P1 must be a number.');
    elseif (tail<=0 && any(p1(:)<=Lbound)) || ...
           (tail>=0 && any(p1(:)>=Ubound))
        error('stats:sampsizepwr:BadAlternative',...
              'P1 has a parameter value outside allowable range.');
    end
end

if ~isempty(power) && any(power(:)<=alpha(:))
    % Cannot compute N or P1 unless power>alpha
    error('stats:sampsizepwr:BadPower',...
          'The POWER value must be greater than the ALPHA value.');
end
if isempty(n)
    if tail<0 && any(p1(:)>=p0)
        error('stats:sampsizepwr:BadP1',...
              'For a left-tail test, P1 must be less than P0.');
    elseif tail>0 && any(p1(:)<=p0)
        error('stats:sampsizepwr:BadP1',...
              'For a right-tail test, P1 must be greater than P0.');
    end
end
     
