function r = copulastat(family,varargin)
%COPULASTAT Rank correlation for a copula.
%   R = COPULASTAT('Gaussian',RHO) returns the Kendall's rank correlation R
%   that corresponds to a Gaussian copula having linear correlation parameters
%   RHO.  If RHO is a scalar correlation coefficient, R is a scalar
%   correlation coefficient corresponding to a bivariate copula.  If RHO is a
%   P-by-P correlation matrix, R is a P-by-P correlation matrix.
%
%   R = COPULASTAT('t',RHO,NU) returns the Kendall's rank correlation R that
%   corresponds to a t copula having linear correlation parameters RHO and
%   degrees of freedom NU.  If RHO is a scalar correlation coefficient, R is a
%   scalar correlation coefficient corresponding to a bivariate copula.  If
%   RHO is a P-by-P correlation matrix, R is a P-by-P correlation matrix.
%   
%   R = COPULASTAT(FAMILY,ALPHA) returns the Kendall's rank correlation R that
%   corresponds to a bivariate Archimedean copula with scalar parameter ALPHA.
%   FAMILY is one of 'Clayton', 'Frank', or 'Gumbel'.
%
%   R = COPULASTAT(...,'type',TYPE) returns the specified type of rank
%   correlation.  TYPE is 'Kendall' to compute Kendall's tau, or 'Spearman' to
%   compute Spearman's rho.
%
%   COPULASTAT uses an approximation to Spearman's rank correlation for
%   some copula families when no analytic formula exists.  The approximation
%   is based on a smooth fit to values computed using Monte-Carlo simulations.
%
%   Example:
%      % Get the theoretical rank correlation coefficient for a bivariate
%      % Gaussian copula having linear correlation parameter -0.7071
%      rho = -.7071
%      tau = copulastat('gaussian',rho)
%
%      % Generate dependent beta random values using that copula
%      u = copularnd('gaussian',rho,100);
%      b = betainv(u,2,2);
%
%      % Verify that the sample has a rank correlation approximately
%      % equal to tau
%      tau_sample = corr(b,'type','k')
%
%   See also COPULACDF, COPULAPDF, COPULARND, COPULAPARAM.

%   Copyright 2005-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:07 $

if nargin < 2
    error('stats:copulastat:WrongNumberOfInputs', ...
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
        error('stats:copulastat:BadType', ...
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
        error('stats:copulastat:BadFamily', 'Ambiguous copula family: ''%s''.',family);
    elseif numel(i) == 1
        family = families{i};
    else
        error('stats:copulastat:BadFamily', 'Unrecognized copula family: ''%s''',family);
    end
else
    error('stats:copulastat:BadFamily', ...
          'The FAMILY argument must be a copula family name.');
end

% Already stripped off 'type' args, should only be parameters left.
if isequal(family,'t')
    numParamArgs = 2; % provisionally
else
    numParamArgs = 1;
end
if length(varargin) > numParamArgs
    error('stats:copulastat:UnrecognizedInput', ...
          'Unrecognized input argument or wrong number of input arguments.');
end

switch family
case {'gaussian' 't'}
    Rho = varargin{1};
    if isequal(family,'t') && (length(varargin) > 1)
        if isnumeric(varargin{2})
            % optional nu was provided for the t copula
            nu = varargin{2};
            if ~(isscalar(nu) && (0 < nu))
                error('stats:copulastat:BadDegreesOfFreedom', ...
                      'NU must be positive scalar.');
            end
        else
            error('stats:copulastat:UnrecognizedInput', ...
                  'Unrecognized input argument or wrong number of input arguments.');
        end
    end
    if isscalar(Rho)
        if ~(-1 <= Rho && Rho <= 1)
            error('stats:copulastat:BadScalarCorrelation', ...
                  'RHO must be between -1 and 1.');
        end
    else
        if any(diag(Rho) ~= 1)
            error('stats:copulastat:BadCorrelationMatrix', ...
                  'RHO must be a correlation matrix.');
        end
        [R,err] = cholcov(Rho);
        if err ~= 0
            error('stats:copulastat:BadCorrelationMatrix', ...
                  'Rho must be square, symmetric, and positive semi-definite.');
        end
    end
    switch type
    case 'kendall'
        r = 2.*asin(Rho)./pi;
    case 'spearman'
        r = 6.*asin(Rho./2)./pi;
    end
    perfectCorr = (abs(Rho) == 1);
    r(perfectCorr) = Rho(perfectCorr);
        
case {'clayton' 'frank' 'gumbel'}
    alpha = varargin{1};
    if ~isscalar(alpha)
        error('stats:copulastat:BadArchimedeanParameter', ...
              'ALPHA must be a scalar.');
    end
    switch family
    case 'clayton'
        if alpha < 0
            error('stats:copulastat:BadClaytonParameter', ...
                  'ALPHA must be nonnegative for the Clayton copula.');
        end
        switch type
        case 'kendall'
            r = alpha ./ (2 + alpha);
        case 'spearman'
            % A quintic in terms of alpha/(2+alpha), forced through y=0 and
            % y=1 at x=0 (alpha=0) and x=1 (alpha=Inf). This is a smooth fit
            % to sample rank correlations computed from MC simulations.
            a = -0.1002; b = 0.1533; c = -0.5024; d = -0.05629;
            p = [a b c d -(a+b+c+d-1) 0];
            r = polyval(p, alpha./(2+alpha));
        end
    case 'frank'
        if alpha == 0
            r = 0;
        else
            switch type
            case 'kendall'
                r = 1 + 4 .* (debye(alpha,1)-1) ./ alpha;
            case 'spearman'
                r = 1 + 12 .* (debye(alpha,2) - debye(alpha,1)) ./ alpha;
            end
        end
    case 'gumbel'
        if alpha < 1
            error('stats:copulastat:BadGumbelParameter', ...
                  'ALPHA must be greater than or equal to 1 for the Gumbel copula.');
        end
        switch type
        case 'kendall'
            r = 1 - 1./alpha;
        case 'spearman'
            % A quintic in terms of 1/alpha, forced through y=1 and y=0 at x=0
            % (alpha=1) and x=1 (alpha=Inf). This is a smooth fit to sample
            % rank correlations computed from MC simulations.
            a = -.2015; b = .4208; c = .2429; d = -1.453;
            p = [a b c d -(a+b+c+d+1) 1];
            r = polyval(p, 1./alpha);
        end
    end
end
