classdef ProbDistParametric < ProbDist
%ProbDistParametric Parametric probability distribution.
%   ProbDistParametric is an abstract class defining the properties and
%   methods for a parametric distribution.  It is derived from the abstract
%   ProbDist class.  You cannot create instances of this class directly.
%   You must create a derived class such as ProbDistUnivParam.
%
%   ProbDistParametric properties:
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
%   ProbDistParametric methods:
%       cdf         - cumulative distribution function
%       pdf         - probabability density or probability function
%       random      - random number generation
%
%   See also PROBDIST, PROBDISTUNIVPARAM, FITDIST.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:05 $

    properties(GetAccess='public', SetAccess='protected')
%NUMPARAMS - Number of parameters.
%   The NumParams property specifies the number of parameters of the
%   distribution, including both specified parameters and those that are
%   fit to data.
%
%   See also PROBDIST.
        NumParams = 0;

%PARAMNAMES - Parameter names.
%   The ParamNames property is a cell array of length NumParams, containing
%   the names of the parameters.
%
%   See also PROBDIST.
        ParamNames = {};

%PARAMS - Parameter values.
%   The Params property is an array of length NumParams, containing
%   the values of the parameters.
%
%   See also PROBDIST.
        Params = [];

%PARAMISFIXED - Logical array indicating fixed parameters.
%   The ParamIsFixed property is a logical array of length NumParams,
%   containing the value true for each fixed parameter and false for each
%   parameter that is estimated from data.
%
%   See also PROBDIST.
        ParamIsFixed = false(1,0);

%PARAMDESCRIPTION - Parameter descriptions.
%   The ParamDescription property is a cell array of length NumParams,
%   containing a brief description of the meaning of each parameter.  The
%   description is the same as the parameter name in cases where no further
%   description is available.
%
%   See also PROBDIST.
        ParamDescription = {};

%PARAMCOV - Covariance matrix of parameter estimates.
%   The ParamCov property is a NumParams-by-NumParams matrix containg the
%   estimated covariance matrix for the parameter estimates.  For a
%   parameter whos value is specified (not estimated from data), the
%   variance is 0 indicating that the parameter is known exactly.
%
%   See also PROBDIST.
        ParamCov = [];

%NLOGL - Negative log likelihood.
%   The NLogL property is the negative log likelihood for the data used to
%   fit the distribution, evaluated at the estimated parameter values.
%   This property is empty for distributions created without fitting to
%   data.
%
%   See also PROBDIST.
        NLogL = []; 
    end

    properties(GetAccess='protected', SetAccess='protected')
        statfunc = []; % function [mean,var]=statfunc(param1,param2,...)
        cifunc = [];   % function ci=cifunc(params,cov,varargin)
    end
end % classdef
