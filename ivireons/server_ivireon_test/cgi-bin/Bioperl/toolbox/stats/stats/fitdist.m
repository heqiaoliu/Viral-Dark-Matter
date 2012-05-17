function [pd,gn,gl] = fitdist(x,distname,varargin)
%FITDIST Fit probability distribution to data.
%   PD = FITDIST(X,DISTNAME) fits the probability distribution DISTNAME to
%   the data in the column vector X, and returns an object PD representing
%   the fitted distribution.  PD is an object in a class derived from the
%   ProbDist class.
%
%   DISTNAME can be 'kernel' to fit a nonparametric kernel-smoothing
%   distribution, or it can be any of the following parametric distribution
%   names:
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
%   [PDCA,GN,GL] = FITDIST(X,DISTNAME,'BY',G) takes a grouping variable G,
%   fits the specified distribution to the X data from each group, and
%   returns a cell array PDCA of the fitted probability distribution
%   objects.  See "help groupingvariable" for more information.  G can also
%   be a cell array of multiple grouping variables.  GN is a cell array of
%   group labels.  GL is a cell array of grouping variable levels, with one
%   column for each grouping variable.
%
%   PD = FITDIST(..., 'NAME1',VALUE1,'NAME2',VALUE2,...) specifies optional
%   argument name/value pairs chosen from the following list. Argument
%   names are case insensitive and partial matches are allowed.
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
%      'options'      A structure created by STATSET to specify control
%                     parameters for the iterative fitting algorithm
%
%   For the 'binomial' distribution only:
%      'n'            A positive integer specifying the N parameter (number
%                     of trials).  Not allowed for other distributions.
%
%   For the 'generalized pareto' distribution only:
%      'theta'        The value of the THETA (threshold) parameter for
%                     the generalized Pareto distribution.  Default is 0.
%                     Not allowed for other distributions.
%
%   For the 'kernel' distribution only:
%      'kernel'       The type of kernel smoother to use, chosen from among
%                     'normal' (default), 'box', 'triangle', and
%                     'epanechnikov'.
%      'support'      Either 'unbounded' (default) if the density can
%                     extend over the whole real line, or 'positive' to
%                     restrict it to positive values, or a two-element
%                     vector giving finite lower and upper limits for the
%                     support of the density.
%      'width'        The bandwidth of the kernel smoothing window.  The
%                     default is optimal for estimating normal densities,
%                     but you may want to choose a smaller value to reveal
%                     features such as multiple modes.
%
%   FITDIST treats NaNs as missing values, and removes them.
%
%   Examples:
%        % Fit MPG data using a kernel smooth density estimate
%        load carsmall
%        ksd = fitdist(MPG,'kernel')
%
%        % Fit separate Weibull distributions for each country of origin.
%        % Cell array is empty for countries with insufficient data.
%        wd = fitdist(MPG,'weibull', 'by',Origin)
%
%   See also PROBDIST, GROUPINGVARIABLE, MLE.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/22 04:41:22 $

% Error checking
error(nargchk(2, Inf, nargin, 'struct'))

if ~isnumeric(x) || ~isvector(x) || size(x,2)~=1
    error('stats:fitdist:BadX','X must be a numeric column vector.')
end
if ~ischar(distname) && ~isstruct(distname)
    error('stats:fitdist:BadDist','DISTNAME is not a valid distribution name.')
elseif ischar(distname) && strncmpi(distname,'kernel',max(1,length(distname)))
    distname = 'kernel';
end

% Process some args here; others are passed along
pnames = {'by' 'censoring' 'frequency'};
dflts  = {[]   []          []         };
[eid,emsg,by,cens,freq,args] = internal.stats.getargs(pnames,dflts,varargin{:});
if ~isempty(eid)
    error(sprintf('stats:fitdist:%s',eid),emsg);
end

% Fit distribution either singly or by group
if isempty(by)
    if nargout>1
       error('stats:fitdist:TooManyOutputs',...
             'The GN and GL outputs are available only with the ''by'' parameter.');
    end
    if isequal(distname,'kernel')
        pd = ProbDistUnivKernel.fit(x,'cens',cens,'freq',freq,args{:});
    else
        pd = ProbDistUnivParam.fit(x,distname,'cens',cens,'freq',freq,args{:});
    end
else
    [gidx,gn,gl] = mgrp2idx(by);
    ngroups = length(gn);

    % Remove NaN and zero-frequency data
    if isempty(freq)
        freq = ones(size(x));
    end
    if isempty(cens)
        cens = false(size(x));
    end
    freq(freq==0) = NaN;
    [badin,~,gidx,x,cens,freq] = statremovenan(gidx,x,cens,freq);
    if badin>0
        error('stats:fitdist:InputSizeMismatch',...
              'X, G, censoring, and frequency inputs must have the same length.');
    end
   
    pd = cell(1,ngroups);
    for j=1:ngroups
        t = (gidx==j);
        xj = x(t);
        cj = cens(t);
        fj = freq(t);
        try
            if isequal(distname,'kernel')
                pd{j} = ProbDistUnivKernel.fit(xj,'cens',cj,'freq',fj,args{:});
            else
                pd{j} = ProbDistUnivParam.fit(xj,distname,'cens',cj,'freq',fj,args{:});
            end
        catch myException
            switch(myException.identifier)
                % Some errors apply across all groups
                case {'stats:ProbDistUnivParam:fit:BadDistName' ...
                      'stats:ProbDistUnivParam:fit:NRequired' ...
                      'stats:ProbDistUnivParam:fit:BadThreshold' ...
                      'stats:ProbDistUnivParam:fit:BadParamName'}
                    rethrow(myException);
 
                % For other or unanticipated errors, warn and continue
                otherwise
                    warning('stats:fitdist:FitError', ...
                            'Error while fitting group ''%s'':\n%s', ...
                            gn{j}, myException.message);
            end
        end
    end
end

