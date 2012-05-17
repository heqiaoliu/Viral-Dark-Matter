function pd = fit(x,distname,varargin)
%ProbDistUnivParam/FIT Probability distribution object fit to data.
%   PD = ProbDistUnivParam.FIT(X,DISTNAME) creates an object PD defining a
%   probability distribution named DISTNAME, with parameters estimated
%   from the data in the vector X.  DISTNAME can be any of the following:
%
%         'beta'                             Beta
%         'binomial'                         Binomial
%         'birnbaumsaunders'                 Birnbaum-Saunders
%         'exponential'                      Exponential
%         'extreme value', 'ev'              Extreme value
%         'gamma'                            Gamma
%         'generalized extreme value', 'gev' Generalized extreme value
%         'generalized pareto', 'gp'         Generalized Pareto
%         'inversegaussian'                  Inverse Gaussian
%         'logistic'                         Logistic
%         'loglogistic'                      Log-logistic
%         'lognormal'                        Lognormal
%         'nakagami'                         Nakagami
%         'negative binomial', 'nbin'        Negative binomial
%         'normal'                           Normal
%         'poisson'                          Poisson
%         'rayleigh'                         Rayleigh
%         'rician'                           Rician
%         'tlocationscale'                   t location-scale
%         'weibull', 'wbl'                   Weibull
%
%   PD = ProbDistUnivParam.FIT(X,DISTNAME, 'NAME1',VALUE1,'NAME2',VALUE2,...)
%   specifies optional argument name/value pairs chosen from the following
%   list. Argument names are case insensitive and partial matches are
%   allowed.
%
%      Name           Value
%      'censoring'    A boolean vector of the same size as X, containing
%                     ones when the corresponding elements of X are
%                     right-censored observations and zeros when the
%                     corresponding elements are exact observations.
%                     Default is all observations observed exactly.
%                     Censoring is not supported for all distributions.
%      'frequency'    A vector of the same size as X, containing
%                     non-negative integer frequencies for the
%                     corresponding elements in X.  Default is one
%                     observation per element of X.
%      'n'            A positive integer specifying the N parameter
%                     (number of trials) for the binomial distribution.
%                     Not allowed for other distributions.
%      'theta'        The value of the THETA (threshold) parameter for
%                     the generalized Pareto distribution.  Default is 0.
%                     Not allowed for other distributions.
%
%   See also FITDIST, ProbDistUnivParam.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:19 $

if nargin < 2
    error('stats:ProbDistUnivParam:fit:TooFewInputs',...
          'At least two input arguments are required.');
end

if isa(x,'ProbDist')
    error('stats:ProbdistUnivParam:fit:NoObject',...
          'Cannot call the FIT method for an object.');
end

% Check for valid distribution, then create a default object
[emsg,distname,spec] = checkdistname(distname);
if ~isempty(emsg)
    error('stats:ProbDistUnivParam:fit:BadDistName',emsg);
end
pd = ProbDistUnivParam(distname,nan(1,length(spec.pnames)));
pd.Support.iscontinuous = spec.iscontinuous;

% Process other arguments.
okargs =   {'censoring' 'frequency' 'options'};
defaults = {[]          []          []};

% Fixed parameter names can be arguments as well.
if any(spec.prequired)
    nfixed = sum(spec.prequired);
    fixedargs = cell(1,nfixed);
    fixednames = lower(spec.pnames(spec.prequired==1));
    okargs = [okargs, fixednames];
    defaults = [defaults, repmat({0},1,nfixed)];
else
    fixedargs = {};
end

[eid,emsg,cens,freq,options,fixedargs{:}] = ...
    internal.stats.getargs(okargs,defaults,varargin{:});
if ~isempty(eid)
    error(sprintf('stats:ProbDistUnivParam:fit:%s',eid),emsg);
end

% Make sure the distribution and data are compatible
[eid,emsg,x,cens,freq] = checkdata(spec,x,cens,freq);
if ~isempty(eid)
    error(eid,emsg);
end

% Process fixed parameters if required 
fixedparams = dofixedparams(distname,fixedargs{:});

% Carry out the fit.
pd = fitdata(pd,spec,x,cens,freq,fixedparams,options);

% Fix the support if necessary
if ~isempty(spec.supportfunc)
    F = spec.supportfunc;
    [pd.Support.range, pd.Support.closedbound] = F(pd.Params);
end
end

% --------------------------
function fixedparams = dofixedparams(distname,varargin)
%DOFIXEDPARAMS Deal with distributions having fixed parameters

fixedparams = {};
switch(distname)
    case 'binomial'
        if ~isscalar(varargin) || ~isscalar(varargin{1}) ...
                               || ~isfinite(varargin{1}) ...
                               || varargin{1}<=0 ...
                               || varargin{1}~=round(varargin{1})
            error('stats:ProbDistUnivParam:fit:NRequired',...
                  'Must specify a valid ''N'' parameter for the binomial distribution.');
        end
        fixedparams = varargin;
    case 'generalized pareto'
        if ~isscalar(varargin) || ~isscalar(varargin{1}) ...
                               || ~isfinite(varargin{1})
            error('stats:ProbDistUnivParam:fit:BadThreshold',...
                  'Must specify a valid ''theta'' parameter for the generalized Pareto distribution.');
        end
        fixedparams = varargin;
end
end
