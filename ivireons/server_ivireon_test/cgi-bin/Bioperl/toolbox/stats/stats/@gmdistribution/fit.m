function obj = fit(X,k,varargin)
%FIT Fit a Gaussian mixture distribution to data.
%   GMFIT = GMDISTRIBUTION.FIT(X,K) fits a Gaussian mixture distribution with
%   K components to the data in X.  X is an N-by-D matrix.  Rows of X
%   correspond to observations; columns correspond to variables.
%   GMDISTRIBUTION.FIT fits the model by maximum likelihood, using the
%   Expectation-Maximization (EM) algorithm.
%
%   GMDISTRIBUTION.FIT treats NaNs as missing data.  Rows of X with NaNs are
%   excluded from the fit.
%
%   GMFIT = GMDISTRIBUTION.FIT(X,K, 'PARAM1',val1, 'PARAM2',val2, ...) allows
%   you to specify optional parameter name/value pairs to specify details of
%   the model and to control the iterative EM algorithm used to fit the model.
%   Parameters are:
%
%      'Start'       The method used to choose initial mean, covariance, and
%                    mixing proportion parameters for the Gaussian components.
%                    Specify the value for 'Start' as one of the following:
%
%                    * 'randSample', to select K observations from X at random
%                      as the initial component means.  The initial mixing
%                      proportions are uniform, and the initial covariance
%                      matrices for all components are diagonal, where the Jth
%                      element on the diagonal is the variance of X(:,J).  This
%                      is the default.
%
%                    * As a vector of length N containing component indices,
%                      chosen from 1:K, for each observation in X.  The initial
%                      values for the mean and covariance of each component are
%                      the sample mean and covariance of the observations
%                      assigned to that component, and the initial values for
%                      the mixing proportions are the proportion of each
%                      component in the specified indices.
%
%                    * As a scalar structure S containing the initial parameter
%                      values in the following fields:
%
%                        S.mu: A K-by-D matrix specifying the initial mean of
%                           each component.
%
%                        S.Sigma: An array specifying the covariance matrix of
%                           each component.  Sigma is one of the following:
%                           * A D-by-D-by-K array.  SIGMA(:,:,J) is the initial
%                             covariance matrix of component J.
%                           * A 1-by-D-by-K array.  DIAG(SIGMA(:,:,J)) is the initial
%                             covariance matrix of component J.
%                           * A D-by-D matrix SIGMA is the initial covariance
%                             matrix for all components.
%                           * A 1-by-D vector.  Diag(SIGMA) is the initial
%                             covariance matrix for all components.
%
%                        S.PComponents: A 1-by-K vector specifying the initial
%                           mixing proportions of each component.  The default
%                           is uniform.
%
%      'Replicates'  A positive integer giving the number of times to repeat the
%                    fit, each with a new set of initial parameters.  GMFIT is
%                    the fit with the largest likelihood.  The default number
%                    of replicates is 1.  A value larger than 1 requires the
%                    'randSample' start method.
%
%      'CovType'     'diagonal' if the covariance matrices are restricted to be
%                    diagonal; 'full' otherwise.  The default is 'full'
%
%      'SharedCov'   True if all the covariance matrices are restricted to be
%                    the same (pooled estimate); false otherwise.  The default
%                    is false.
%
%      'Regularize'  A non-negative regularization value to be added to the
%                    diagonal of each covariance matrix to ensure that the
%                    estimates are positive-definite.  The default is 0.
%
%
%      'Options'     Options structure for the iterative EM algorithm, as
%                    created by STATSET.  The following STATSET parameters
%                    are used:
%
%                      'Display'  Level of display output.  Choices are
%                                 'off' (the default), 'iter', and 'final'.
%                      'MaxIter'  Maximum number of iterations allowed.
%                                 Default is 100.
%                      'TolFun'   Positive number giving the termination
%                                 tolerance for the log-likelihood
%                                 function.  The default is 1e-6.
%
%   Example:   Generate data from a mixture of two bivariate Gaussian
%              distributions and fit a Gaussian mixture model:
%                 mu1 = [1 2];
%                 Sigma1 = [2 0; 0 .5];
%                 mu2 = [-3 -5];
%                 Sigma2 = [1 0; 0 1];
%                 X = [mvnrnd(mu1,Sigma1,1000);mvnrnd(mu2,Sigma2,1000)];
%                 gmfit = gmdistribution.fit(X,2);
%
%   See also GMDISTRIBUTION, GMDISTRIBUTION/GMDISTRIBUTION,
%            GMDISTRIBUTION/CLUSTER.

%   Reference:  McLachlan, G., and D. Peel, Finite Mixture Models, John
%               Wiley & Sons, New York, 2000.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:20:27 $

if nargin < 2
    error('stats:gmdistribution:TooFewInputs',...
          'At least two input arguments required.');
end

checkdata(X);

if ~isscalar(k) || ~isnumeric(k) || ~isfinite(k) ...
         || k<1 || k~=round(k)
    error('stats:gmdistribution:BadK',...
          'K must be an integer specifying the number of mixture components.');
end

%remove NaNs from X
wasnan = any(isnan(X),2);
hadNaNs = any(wasnan);
if hadNaNs
    warning('stats:gmdistribution:MissingData',...
            'Rows of X with missing data will not be used.');
    X = X(~wasnan,:);
end

[n, d] = size(X);
if n <= d
    error('stats:gmdistribution:TooFewN',...
          'X must have more rows than columns.');
end

if n <= k
    error('stats:gmdistribution:TooManyClusters', ...
          'X must have more rows than the number of components.');
end

varX = var(X);
I = find(varX < eps(max(varX))*n);
if ~isempty(I)
    error('stats:gmdistribution:ZeroVariance',...
          'The following column(s) of data are effectively constant: %s.', num2str(I));
end

% parse input and error check
pnames = {      'start' 'replicates'  'covtype' 'sharedcov'  'regularize'  'options'};
dflts =  { 'randSample'           1      'full'      false             0         [] };
[eid,errmsg,start,reps, CovType,SharedCov, RegV, options] ...
    = internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:gmdistribution:%s',eid),errmsg);
end

options = statset(statset('gmdistribution'),options);

if ~isnumeric(reps) || ~isscalar(reps) || round(reps) ~= reps || reps < 1
    error('stats:gmdistribution:InvalidReps',...
          '''Replicates'' must be a positive integer.');
end


if ~isnumeric(RegV) || ~isscalar(RegV) || RegV < 0
    error('stats:gmdistribution:InvalidReg',...
          'The ''Regularize'' must be a non-negative scalar.');
end

if ischar(CovType)
    covNames = {'diagonal','full'};
    i = strmatch(lower(CovType),covNames);
    if isempty(i)
        error('stats:gmdistribution:UnknownCovType', ...
              'Unknown ''CovType'' parameter value:  %s.', CovType);
    end
    CovType = i;
else
    error('stats:gmdistribution:InvalidCovType', ...
          'The ''CovType'' parameter value must be a string.');
end

if ~islogical(SharedCov)
    error('stats:gmdistribution:InvalidSharedCov', ...
          'The ''SharedCov'' parameter value must be logical.');
end

if ischar(start)
    % parsing input and error check done
    start = lower(start);
    startNames = {'randsample'};
    i = strmatch(start, startNames);
    if isempty(i)
        error('stats:gmdistribution:UnknownStart', ...
              'Unknown ''Start'' parameter value:  %s.', start);
    end
end

options.Display = strmatch(lower(options.Display), {'off','notify','final','iter'}) - 1;

try
    [S,NlogL,optimInfo] =...
        gmcluster(X,k,start,reps,CovType,SharedCov,RegV,options);

    % Store results in object
    obj = gmdistribution;
    obj.NDimensions = d;
    obj.NComponents = k;
    obj.PComponents = S.PComponents;
    obj.mu = S.mu;
    obj.Sigma = S.Sigma;
    obj.Converged = optimInfo.Converged;
    obj.Iters = optimInfo.Iters;
    obj.NlogL = NlogL;
    obj.SharedCov = SharedCov;
    obj.RegV = RegV;
    if CovType == 1
        obj.CovType = 'diagonal';
        if SharedCov
            nParam = obj.NDimensions;
        else
            nParam = obj.NDimensions * k;
        end
    else
        obj.CovType = 'full';
        if SharedCov
            nParam = obj.NDimensions * (obj.NDimensions+1)/2;
        else
            nParam = k*obj.NDimensions * (obj.NDimensions+1)/2;
        end

    end
    nParam = nParam + k-1 + k * obj.NDimensions;
    obj.BIC = 2*NlogL + nParam*log(n);
    obj.AIC = 2*NlogL + 2*nParam;

catch ME
    rethrow(ME) ;
end
