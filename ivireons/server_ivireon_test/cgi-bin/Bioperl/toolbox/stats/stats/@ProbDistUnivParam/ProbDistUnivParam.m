classdef ProbDistUnivParam < ProbDistParametric
%ProbDistUnivParam Univariate parametric probability distribution.
%   A ProbDistUnivParam object represents a univariate parametric probability
%   distribution.  You can create this object by using the constructor and
%   supplying parameter values, or by using the FITDIST function to fit the
%   distribution to data.
%
%   PD = ProbDistUnivParam(DISTNAME,PARAMS) creates an object PD defining a
%   probability distribution named DISTNAME with parameters PARAMS.
%
%   PD = FITDIST(X,DISTNAME) creates an object PD defining a probability
%   distribution named DISTNAME, with parameters estimated from the data in
%   the vector X.
%
%   ProbDistUnivParam properties:
%       DistName      - name of the distribution
%       InputData     - structure containing data used to fit the distribution
%       NLogL         - negative log likelihood for fitted data
%       NumParams     - number of parameters
%       ParamNames    - cell array of NumParams parameter names
%       Params        - array of NumParams parameter values
%       ParamIsFixed  - logical vector indicating which parameters are
%                       fixed rather than estimated
%       ParamDescription - cell array of NumParams strings describing
%                       the parameters
%       ParamCov      - covariance matrix of parameter values
%       Support       - structure describing the support of the distribution
%
%       Parameter values are also provided as properties.  For example, if
%       PD represents the normal distribution, then PD.mu and PD.sigma are
%       properties that give the values of the mu and sigma parameters.
%
%   ProbDistUnivParam methods:
%      ProbDistUnivParam - constructor
%      cdf            - Cumulative distribution function
%      icdf           - Inverse cumulative distribution function
%      iqr            - Interquartile range
%      mean           - Mean
%      median         - Median
%      paramci        - Confidence intervals for the parameters
%      pdf            - Probability density function
%      random         - Random number generation
%      std            - Standard deviation
%      var            - Variance
%
%   See also PROBDIST, PROBDISTPARAMETRIC, FITDIST.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/22 04:42:01 $

    properties(GetAccess='protected', SetAccess='protected')
        icdffunc = []; % function y=icdffunc(p,param1,param2,...)
    end
    
    methods
        x = icdf(obj,p)
        r = iqr(obj)
        m = median(obj)
    end
    
    methods
        function pd = ProbDistUnivParam(distname,params)
%ProbDistUnivParam Univariate parametric probability distribution constructor.
%   PD = ProbDistUnivParam(DISTNAME,PARAMS) creates an object PD defining a
%   probability distribution named DISTNAME with parameters specified by
%   the numeric vector PARAMS.  DISTNAME can be any of the following:
%    
%         'beta'                             Beta
%         'binomial'                         Binomial
%         'birnbaumsaunders'                 Birnbaum-Saunders
%         'exponential'                      Exponential
%         'extreme value' or 'ev'            Extreme value
%         'gamma'                            Gamma
%         'generalized extreme value' 'gev'  Generalized extreme value
%         'generalized pareto' or 'gp'       Generalized Pareto
%         'inversegaussian'                  Inverse Gaussian
%         'logistic'                         Logistic
%         'loglogistic'                      Log-logistic
%         'lognormal'                        Lognormal
%         'nakagami'                         Nakagami
%         'negative binomial' or 'nbin'      Negative binomial
%         'normal'                           Normal
%         'poisson'                          Poisson
%         'rayleigh'                         Rayleigh
%         'rician'                           Rician
%         'tlocationscale'                   t location-scale
%         'weibull' or 'wbl'                 Weibull
%
%   See also PROBDISTUNIVPARAM, FITDIST.

            if nargin<2
                error('stats:ProbDistUnivParam:TooFewInputs',...
                      'DISTNAME and PARAMS inputs are required.')
            end
 
            % Check distribution name
            [emsg,distname,spec] = checkdistname(distname);
            if ~isempty(emsg)
                error('stats:ProbDistUnivParam:BadDistName',emsg);
            end
            pd.DistName = distname;

            % Check parameters 
            emsg = checkparams(spec,params);
            if ~isempty(emsg)
                error('stats:ProbDistUnivParam:BadParams',emsg);
            end
            params = params(:)';

            % Fill in object properties from spec structure
            pd.Params = params;
            pd.ParamNames = spec.pnames;
            pd.NumParams = numel(params);
            pd.ParamCov = zeros(numel(params));
            pd.ParamIsFixed = true(size(params));
            pd.ParamDescription = spec.pdescription;
            pd.Support.iscontinuous = spec.iscontinuous;
            pd.Support.range = spec.support;
            pd.Support.closedbound = spec.closedbound;
            
            pd.cdffunc = spec.cdffunc;
            pd.icdffunc = spec.invfunc;
            pd.pdffunc = spec.pdffunc;
            if isfield(spec,'statfunc')
                pd.statfunc = spec.statfunc;
            end
            if isfield(spec,'randfunc')
                pd.randfunc = spec.randfunc;
            end
            if isfield(spec,'cifunc')
                pd.cifunc = spec.cifunc;
            end
        end %constructor
 
        function b = properties(pd)
%PROPERTIES Properties of a ProbDistUnivParam opject
%   P = PROPERTIES(PD) returns a cell array P of the names of the
%   properties of the probability distribution object PD.
            b = [properties('ProbDistUnivParam'); pd.ParamNames(:)];
        end 
    end

    methods(Static = true, Hidden = true)
        pd = fit(distname,x,varargin)
    end

end % classdef
