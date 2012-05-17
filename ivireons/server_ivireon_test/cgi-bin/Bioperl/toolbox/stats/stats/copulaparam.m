function param = copulaparam(family,varargin)
%COPULAPARAM Copula parameters as a function of rank correlation.
%   RHO = COPULAPARAM('Gaussian',R) returns the linear correlation parameters
%   RHO corresponding to a Gaussian copula having Kendall's rank correlation
%   R.  If R is a scalar correlation coefficient, RHO is a scalar correlation
%   coefficient corresponding to a bivariate copula.  If R is a P-by-P
%   correlation matrix, RHO is a P-by-P correlation matrix.
%
%   RHO = COPULAPARAM('t',R,NU) returns the linear correlation parameters RHO
%   corresponding to a t copula having Kendall's rank correlation R and
%   degrees of freedom NU.  If R is a scalar correlation coefficient, RHO is
%   a scalar correlation coefficient corresponding to a bivariate copula.  If
%   R is a P-by-P correlation matrix, RHO is a P-by-P correlation matrix.
%   
%   ALPHA = COPULAPARAM(FAMILY,R) returns the copula parameter ALPHA
%   corresponding to a bivariate Archimedean copula having Kendall's rank
%   correlation R.  R is a scalar.  FAMILY is one of 'Clayton', 'Frank',
%   or 'Gumbel'.
%
%   [...] = COPULAPARAM(...,'type',TYPE) assumes R is the specified type of
%   rank correlation.  TYPE is 'Kendall' for Kendall's tau, or 'Spearman' for
%   Spearman's rho.
%
%   COPULAPARAM uses an approximation to Spearman's rank correlation for
%   some copula families when no analytic formula exists.  The approximation
%   is based on a smooth fit to values computed using Monte-Carlo simulations.
%
%   Example:
%      % Get the linear correlation coefficient corresponding to a bivariate
%      % Gaussian copula having a rank correlation of -0.5
%      tau = -0.5
%      rho = copulaparam('gaussian',tau)
%
%      % Generate dependent beta random values using that copula
%      u = copularnd('gaussian',rho,100);
%      b = betainv(u,2,2);
%
%      % Verify that the sample has a rank correlation approximately
%      % equal to tau
%      tau_sample = corr(b,'type','k')
%
%   See also COPULACDF, COPULAPDF, COPULARND, COPULASTAT.

%   Copyright 2005-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:04 $

if nargin < 2
    error('stats:copulaparam:WrongNumberOfInputs', ...
          'Requires at least two input arguments.');
elseif nargin > 2 && isequal(varargin{end-1},'type')
    type = varargin{end};
    types = {'kendall' 'spearman'};
    if ischar(type)
        i = strmatch(lower(type),types);
        if isscalar(i)
            type = types{i};
        end
    end
    if ~isequal(type,'kendall') && ~isequal(type,'spearman')
        error('stats:copulaparam:BadType', ...
              'The ''type'' parameter value must be ''kendall'' or ''spearman''.');
    end
    varargin = varargin(1:end-2);
else
    type = 'kendall';
end

if ischar(family)
    families = {'gaussian','t','clayton','frank','gumbel'};

    i = strmatch(lower(family), families);
    if numel(i) > 1
        error('stats:copulaparam:BadFamily', 'Ambiguous copula family: ''%s''.',family);
    elseif numel(i) == 1
        family = families{i};
    else
        error('stats:copulaparam:BadFamily', 'Unrecognized copula family: ''%s''',family);
    end
else
    error('stats:copulaparam:BadFamily', ...
          'The FAMILY argument must be a copula family name.');
end

% Already stripped off 'type' args, should only be parameters left.
if isequal(family,'t')
    numParamArgs = 2; % provisionally
else
    numParamArgs = 1;
end
if length(varargin) > numParamArgs
    error('stats:copulaparam:UnrecognizedInput', ...
          'Unrecognized input argument or wrong number of input arguments.');
end

switch family
case {'gaussian' 't'}
    R = varargin{1};
    if isequal(family,'t') && (length(varargin) > 1)
        if isnumeric(varargin{2})
            % optional nu was provided for the t copula
            nu = varargin{2};
            if ~(isscalar(nu) && (0 < nu))
                error('stats:copulaparam:BadDegreesOfFreedom', ...
                      'NU must be positive scalar.');
            end
        else
            error('stats:copulaparam:UnrecognizedInput', ...
                  'Unrecognized input argument or wrong number of input arguments.');
        end
    end
    if isscalar(R)
        if ~(-1 < R && R < 1)
            error('stats:copulaparam:BadScalarCorrelation', ...
                  'R must be between -1 and 1.');
        end
    else
        if any(diag(R) ~= 1)
            error('stats:copulaparam:BadCorrelationMatrix', ...
                  'R must be a correlation matrix.');
        end
        [T,err] = cholcov(R);
        if err ~= 0
            error('stats:copulaparam:BadCorrelationMatrix', ...
                  'R must be square, symmetric, and positive semi-definite.');
        end
    end
    switch type
    case 'kendall'
        param = sin(R.*pi./2);
    case 'spearman'
        param = 2.*sin(R.*pi./6);
    end
    perfectCorr = (abs(R) == 1);
    param(perfectCorr) = R(perfectCorr);
    
case {'clayton' 'frank' 'gumbel'}
    r = varargin{1};
    if ~isscalar(r) || ~(-1 <= r && r <= 1)
        error('stats:copulaparam:BadCorrelation', ...
              'R must be a correlation coefficient between -1 and 1.');
    end
    switch family
    case 'clayton'
        if r < 0
            error('stats:copulaparam:BadCorrelation', ...
                  'R must be nonnegative for the Clayton copula.');
        end
        switch type
        case 'kendall'
            param = 2*r ./ (1-r);
        case 'spearman'
            % A quintic in terms of alpha/(2+alpha), forced through y=0 and
            % y=1 at x=0 (alpha=0) and x=1 (alpha=Inf). This is a smooth fit
            % to sample rank correlations computed from MC simulations.
            a = -0.1002; b = 0.1533; c = -0.5024; d = -0.05629;
            p = [a b c d -(a+b+c+d-1) 0];
            t = fzero(@(t) polyval(p,t)-r, [0 1]);
            param = 2*t ./ (1-t);
        end
    case 'frank'
        if r == 0
            param = 0;
        elseif abs(r) < 1
            % There's no closed form for alpha in terms of tau, so alpha has
            % to be determined numerically.
            switch type
            case 'kendall'
                param = fzero(@frankRootFunKendall,sign(r),[],r);
            case 'spearman'
                param = fzero(@frankRootFunSpearman,sign(r),[],r);
            end
        else
            param = sign(r).*Inf;
        end
    case 'gumbel'
        if r < 0
            error('stats:copulaparam:BadCorrelation', ...
                  'R must be nonnegative for the Gumbel copula.');
        end
        switch type
        case 'kendall'
            param = 1 ./ (1-r);
        case 'spearman'
            % A quintic in terms of 1/alpha, forced through y=1 and y=0 at x=0
            % (alpha=1) and x=1 (alpha=Inf). This is a smooth fit to sample
            % rank correlations computed from MC simulations.
            a = -.2015; b = .4208; c = .2429; d = -1.453;
            p = [a b c d -(a+b+c+d+1) 1];
            t = fzero(@(t) polyval(p,t)-r, [0 1]);
            param = 1 ./ t;
        end
    end
end


function err = frankRootFunKendall(alpha,target)
if abs(alpha) < sqrt(realmin)
    r = 0;
else
    r = 1 + 4 .* (debye(alpha,1)-1) ./ alpha;
end
err = r - target;


function err = frankRootFunSpearman(alpha,target)
if abs(alpha) < sqrt(realmin)
    r = 0;
else
    r = 1 + 12 .* (debye(alpha,2)-debye(alpha,1)) ./ alpha;
end
err = r - target;
