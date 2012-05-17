function r = random(name,varargin)
%RANDOM Generate random arrays from a specified distribution.
%   R = RANDOM(NAME,A) returns an array of random numbers chosen from the
%   one-parameter probability distribution specified by NAME with parameter
%   values A.
%
%   R = RANDOM(NAME,A,B) or R = RANDOM(NAME,A,B,C) returns an array of random
%   numbers chosen from a two- or three-parameter probability distribution
%   with parameter values A, B (and C).
%
%   The size of R is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   R = RANDOM(NAME,A,M,N,...) or R = RANDOM(NAME,A,[M,N,...]) returns an
%   M-by-N-by-... array of random numbers for a one-parameter distribution.
%   Similarly, R = RANDOM(NAME,A,B,M,N,...) or R = RANDOM(NAME,A,B,[M,N,...]),
%   and R = RANDOM(NAME,A,B,C,M,N,...) or R = RANDOM(NAME,A,B,C,[M,N,...]),
%   return an M-by-N-by-... array of random numbers for a two- or
%   three-parameter distribution.
%
%
%   NAME can be:
%
%      'beta'  or 'Beta',
%      'bino'  or 'Binomial',
%      'chi2'  or 'Chisquare',
%      'exp'   or 'Exponential',
%      'ev'    or 'Extreme Value',
%      'f'     or 'F',
%      'gam'   or 'Gamma',
%      'gev'   or 'Generalized Extreme Value',
%      'gp'    or 'Generalized Pareto',
%      'geo'   or 'Geometric',
%      'hyge'  or 'Hypergeometric',
%      'logn'  or 'Lognormal',
%      'nbin'  or 'Negative Binomial',
%      'ncf'   or 'Noncentral F',
%      'nct'   or 'Noncentral t',
%      'ncx2'  or 'Noncentral Chi-square',
%      'norm'  or 'Normal',
%      'poiss' or 'Poisson',
%      'rayl'  or 'Rayleigh',
%      't'     or 'T',
%      'unif'  or 'Uniform',
%      'unid'  or 'Discrete Uniform',
%      'wbl'   or 'Weibull'.
%
%   Partial matches are allowed and case is ignored.
%
%   RANDOM calls many specialized routines that do the calculations.
%
%   See also CDF, ICDF, MLE, PDF.

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:17:03 $

if ischar(name)
    distNames = {'beta', 'binomial', 'chi-square', 'extreme value', ...
                 'exponential', 'f', 'gamma', 'generalized extreme value', ...
                 'generalized pareto', 'geometric', 'hypergeometric', ...
                 'lognormal', 'negative binomial', 'noncentral f', ...
                 'noncentral t', 'noncentral chi-square', 'normal', 'poisson', ...
                 'rayleigh', 't', 'discrete uniform', 'uniform', 'weibull'};

    i = strmatch(lower(name), distNames);
    if numel(i) > 1
        error('stats:random:BadDistribution', 'Ambiguous distribution name: ''%s''.',name);
    elseif numel(i) == 1
        name = distNames{i};
    else % it may be an abbreviation that doesn't partially match the name
        name = lower(name);
    end
else
    error('stats:random:BadDistribution', 'The NAME argument must be a distribution name.');
end

% Determine, and call, the appropriate subroutine
switch name
case 'beta'
    r = betarnd(varargin{:});
case 'binomial'
    r = binornd(varargin{:});
case {'chi2', 'chi-square', 'chisquare'}
    r = chi2rnd(varargin{:});
case {'ev', 'extreme value'}
    r = evrnd(varargin{:});
case 'exponential'
    r = exprnd(varargin{:});
case 'f'
    r = frnd(varargin{:});
case 'gamma'
    r = gamrnd(varargin{:});
case {'gev', 'generalized extreme value'}
    r = gevrnd(varargin{:});
case {'gp', 'generalized pareto'}
    r = gprnd(varargin{:});
case 'geometric'
    r = geornd(varargin{:});
case {'hyge', 'hypergeometric'}
    r = hygernd(varargin{:});
case 'lognormal'
    r = lognrnd(varargin{:});
case {'nbin', 'negative binomial'}
    r = nbinrnd(varargin{:});
case {'ncf', 'noncentral f'}
    r = ncfrnd(varargin{:});
case {'nct', 'noncentral t'}
    r = nctrnd(varargin{:});
case {'ncx2', 'noncentral chi-square'}
    r = ncx2rnd(varargin{:});
case 'normal'
    r = normrnd(varargin{:});
case 'poisson'
    r = poissrnd(varargin{:});
case 'rayleigh'
    r = raylrnd(varargin{:});
case 't'
    r = trnd(varargin{:});
case {'unid', 'discrete uniform'}
    r = unidrnd(varargin{:});
case 'uniform'
    r = unifrnd(varargin{:});
case {'wbl', 'weibull'}
    if ~strcmp(name,'wbl')
        warning('stats:random:ChangedParameters', ...
                'The Statistics Toolbox uses a new parametrization for the\nWEIBULL distribution beginning with release 4.1.');
    end
    r = wblrnd(varargin{:});
otherwise
    spec = dfgetdistributions(name);
    if isempty(spec)
       error('stats:random:BadDistribution',...
             'Unrecognized distribution name: ''%s''.',name);
    elseif length(spec)>1
       error('stats:random:BadDistribution',...
             'Ambiguous distribution name: ''%s''.',name);
    end
    
    if isempty(spec.randfunc)
        % Compute by inverting the cdf if necessary
        paramArgs = varargin(1:length(spec.pnames));
        sizeArgs = varargin(length(spec.pnames)+1:end);
        u = rand(sizeArgs{:});
        r = feval(spec.invfunc,u,paramArgs{:});
    else
        r = feval(spec.randfunc,varargin{:});
    end
end
