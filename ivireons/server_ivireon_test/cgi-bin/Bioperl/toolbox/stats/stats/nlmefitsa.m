function [betas,Gamma,stats,b_hat] = nlmefitsa(X,y,group,v,modelfun,beta0,varargin)
%NLMEFITSA Fit nonlinear mixed effects model with stochastic EM algorithm.
%   [BETA,PSI,STATS,B] = NLMEFITSA(X,Y,GROUP,V,MODELFUN,BETA0) fits a
%   nonlinear mixed-effects regression model and returns estimates of the
%   fixed effects in BETA. By default, NLMEFITSA fits a model where each
%   model parameter is the sum of a corresponding fixed and random effect,
%   and the covariance matrix of the random effects is diagonal, i.e.,
%   uncorrelated random effects.
%
%   The BETA, PSI, and other values returned by this function are the
%   result of a random (Monte Carlo) simulation designed to converge to the
%   maximum likelihood estimates of the parameters. Because the results are
%   random, it is advisable to examine the plot of simulation to results to
%   be sure that the simulation has converged. It may also be helpful to
%   run the function multiple times, use multiple starting values, or use
%   the 'Replicates' parameter to perform multiple simulations.
%
%   X is an N-by-H matrix of N observations on H predictor variables. Y is
%   an N-by-1 vector of responses. GROUP is a grouping variable indicating
%   which of M groups each observation belongs to. Valid GROUP values
%   include a categorical vector, a numeric vector, or a cell array of
%   strings. See "help groupingvariable" for more information.
%
%   V is an M-by-G matrix of G group-specific predictor variables for each of
%   the M groups in the data. These are predictor values that take on the same
%   value for all observations in a group. Rows of V are ordered according to
%   GRP2IDX(GROUP). Use an M-by-G cell array for V if any of the group-
%   specific predictor values vary in size across groups. Specify [] for V if
%   there are no group predictors.
%
%   MODELFUN is a handle to a function that accepts predictor values and
%   model parameters, and returns fitted values. MODELFUN has the form
%
%      YFIT = MODELFUN(PHI,XFUN,VFUN)
%
%   with input arguments:
%
%      PHI    A 1-by-P vector of model parameters.
%      XFUN   An L-by-H array of predictor variables where L is 1 if XFUN is a
%             single row of X, NI if XFUN contains the rows of X for a single
%             group of size NI, or N if XFUN contains all rows of X.
%      VFUN   Either a 1-by-G vector of group-specific predictors for a single
%             group, corresponding to a single row of V; or an N-by-G matrix,
%             where the K-th row of VFUN is V(I,:) if the K-th observation is
%             in group I. If V is empty, NLMEFITSA calls MODELFUN with only
%             two inputs.
%
%   and with the result YFIT equal to an L-by-1 vector of fitted values. When
%   either PHI or VFUN contains a single row, that one row corresponds to all
%   rows in the other two input arguments. Note: for improved performance, use
%   the 'Vectorization' parameter name/value pair (described below) if MODELFUN
%   can compute YFIT for more than one vector of model parameters in one call.
%
%   BETA0 is an F-by-1 vector with initial estimates for the F fixed
%   effects. By default, F is equal to the number of model parameters P.
%   BETA0 can also be an F-by-REPS matrix, and the estimation is repeated
%   REPS times using each column of BETA0 as a set of starting values.
%
%   NLMEFITSA fits the model by a stochastic algorithm that converges to the
%   parameter values that maximize the marginal likelihood, i.e., with the
%   random effects integrated out, and assumes that:
%      a) the random effects are multivariate normally distributed, and
%         independent between groups, and
%      b) the observation errors are independent, identically normally
%         distributed, and independent of the random effects.
%
%   [BETA,PSI] = NLMEFITSA(...) returns PSI, an R-by-R estimated covariance
%   matrix for the random effects. By default, R is equal to the number of
%   model parameters P.
%
%   [BETA,PSI,STATS] = NLMEFITSA(...) returns STATS, a structure with the
%   following fields:
%       logl   The maximized log-likelihood for the fitted model; empty if
%              the LogLikMethod parameter has its default value of 'none'
%       rmse   The root mean squared residual (computed on the log scale
%              for the 'exponential' error model)
%       errorparam  The estimated parameters of the error variance model
%       aic    The Akaike information criterion (empty if logl is empty)
%       bic    The Bayesian information criterion (empty if logl is empty)
%       sebeta The standard errors for BETA (empty if the ComputeStdErrors
%              parameter has its default value of false)
%       covb   The estimated covariance of the parameter estimates (empty
%              if ComputeStdErrors is false)
%       dfe    The error degrees of freedom
%
%   [BETA,PSI,STATS,B] = NLMEFITSA(...) returns B, an R-by-M matrix of estimated
%   random effects for the M groups. By default, R is equal to the number of
%   model parameters P.
%
%   If there are REPS columns of starting values in BETA0, then BETA is
%   F-by-REPS, PSI is R-by-R-by-REPS, STATS is a structure array with REPS
%   elements, and B is R-by-M-by-REPS.
%
%   [...] = NLMEFITSA(X,Y,GROUP,V,FUN,BETA0,'param1',val1,...) specifies
%   additional parameter name/value pairs that allow you to define the model
%   and control the estimation algorithm, as described below.
%
%   By default, NLMEFITSA fits a model where each model parameter is the sum of
%   a corresponding fixed and random effect. Use the following parameter
%   name/value pairs to fit a model with a different number of or dependence
%   on fixed or random effects. Use at most one parameter name with an 'FE'
%   prefix and one parameter name with an 'RE' prefix. Note that some choices
%   change the way NLMEFITSA calls MODELFUN, as described further below.
%
%       'FEParamsSelect' A vector specifying which elements of the model
%                        parameter vector PHI include a fixed effect, as a
%                        numeric vector with elements in 1:P, or as a 1-by-P
%                        logical vector.  The model will include F fixed
%                        effects, where F is the specified number of elements.
%       'FEConstDesign'  A P-by-F design matrix ADESIGN, where ADESIGN*BETA
%                        are the fixed components of the P elements of PHI.
%       'FEGroupDesign'  A P-by-F-by-M array specifying a different P-by-F
%                        fixed effects design matrix for each of the M groups.
%
%       'REParamsSelect' A vector specifying which elements of the model
%                        parameter vector PHI include a random effect, as a
%                        numeric vector with elements in 1:P, or as a 1-by-P
%                        logical vector.  The model will include R random
%                        effects, where R is the specified number of elements.
%       'REConstDesign'  A P-by-R design matrix BDESIGN, where BDESIGN*B are
%                        the random components of the P elements of PHI.
%                        This matrix must consist of 0s and 1s, with at
%                        most one 1 per row.
%
%   The default model is equivalent to setting both 'FEConstDesign' and
%   'REConstDesign' to EYE(P), or to setting both 'FEParamsSelect' and
%   'REParamsSelect' to 1:P.
%
%   Additional optional parameter name/value pairs control the iterative
%   algorithm used to maximize the likelihood:
%       'CovPattern' Specifies an R-by-R logical or numeric matrix PAT that
%                    defines the pattern of the random effects covariance
%                    matrix PSI. NLMEFITSA computes estimates for the
%                    variances along the diagonal of PSI as well as
%                    covariances that correspond to non-zeroes in the
%                    off-diagonal of PAT.  NLMEFITSA constrains the remaining
%                    covariances, i.e., those corresponding to off-diagonal
%                    zeroes in PAT, to be zero. PAT must be a row-column
%                    permutation of a block diagonal matrix, and NLMEFITSA
%                    adds non-zero elements to PAT as needed to produce
%                    such a pattern. The default value of PAT is EYE(R),
%                    corresponding to uncorrelated random effects.
%
%                    Alternatively, specify PAT as a 1-by-R vector
%                    containing values in 1:R. In this case, elements of
%                    PAT with equal values define groups of random effects,
%                    NLMEFITSA estimates covariances only within groups, and
%                    constrains covariances across groups to be zero.
%
%       'Cov0'       Initial value for the covariance matrix PSI. Must be
%                    an R-by-R positive definite matrix. If empty, the
%                    default value depends on the values of BETA0.
%
%       'ComputeStdErrors' true to compute standard errors for the
%                    coefficient estimates and store them in the output
%                    STATS structure, or false (default) to omit this
%                    computation.
%
%       'ErrorModel' A string specifying the form of the error term.
%                    Default is 'constant'. Each model defines the error
%                    using a standard normal (Gaussian) variable e, the
%                    function value f, and one or two parameters a and b.
%                    Choices are: 
%                       'constant'         y = f + a*e
%                       'proportional'     y = f + b*f*e
%                       'combined'         y = f + (a+b*abs(f))*e
%                       'exponential'      y = f*exp(a*e), or equivalently
%                                          log(y) = log(f) + a*e
%                    If this parameter is given, the output STATS.errorparam
%                    field has the value
%                        a       for 'constant' and 'exponential'
%                        b       for 'proportional'
%                        [a b]   for 'combined'
%
%       'ErrorParameters' A scalar or two-element vector specifying
%                    starting values for parameters of the error model.
%                    This specifies the a, b, or [a b] values depending on
%                    the ErrorModel parameter.
%
%       'LogLikMethod' Specifies the method for approximating the log
%                    likelihood. Choices are:
%                       'is'   Importance sampling
%                       'gq'   Gaussian quadrature
%                       'lin'  Linearization
%                       'none' Omit the log likelihood approximation
%                              (default)
%
%       'NBurnIn'    Number of initial burn-in iterations during which the
%                    parameter estimates are not recomputed. Default is 5.
%
%       'NChains'    Number N of "chains" simulated. Setting N>1 causes N
%                    simulated coefficient vectors to be computed for each
%                    group during each iteration. Default depends on the
%                    data, and is chosen to provide about 100 groups across
%                    all chains.
%
%       'NIterations' Number of iterations. This can be a scalar or a
%                    three-element vector. Controls how many iterations are
%                    performed for each of three phases of the algorithm:
%                            1. simulated annealing
%                            2. full step size
%                            3. reduced step size
%                    Default is [150 150 100]. A scalar is distributed
%                    across the three phases in the same proportions as the
%                    default.
%
%       'NMCMCIterations' Number of MCMC iterations. This can be a scalar
%                    or a three-element vector. Controls how many of three
%                    different types of MCMC updates are performed during
%                    each phase of the main iteration:  
%                            1. full multivariate update
%                            2. single coordinate update
%                            3. multiple coordinate update
%                    Default is [2 2 2]. A scalar value is treated as a
%                    3-element vector with all elements equal to the scalar.
%
%       'OptimFun'   Either 'fminsearch' or 'fminunc', specifying the
%                    optimization function to be used during the estimation
%                    process.  Default is 'fminsearch'.  Use of 'fminunc'
%                    requires Optimization Toolbox.
%
%       'Options'    A structure created by a call to STATSET. NLMEFITSA uses
%                    the following STATSET parameters:
%            'Display'      Level of display during estimation. 'off' (the
%                           default) displays no information, 'final'
%                           displays information after the final iteration
%                           of the estimation algorithm, 'iter' displays
%                           information at each iteration.
%            'FunValCheck'  'on' (the default) to check for invalid values
%                           (such as NaN or Inf) from MODELFUN, or 'off' to
%                           skip this check.
%            'OutputFcn'    Function handle specified using @, a cell array
%                           with function handles or an empty array
%                           (default). NLMEFITSA calls all output functions
%                           after each iteration. See NLMEFITOUTPUTFCN for
%                           an example of an output function.
%
%       'ParamTransform' A vector of P values specifying a transformation
%                    function f() for each of the P parameters:
%                         XB = ADESIGN*BETA + BDESIGN*B
%                         f(PHI) = XB
%                    Each element of the vector must be one of the
%                    following integer codes specifying the
%                    transformation for the corresponding value of PHI:
%                             0: PHI = XB  (default for all parameters)
%                             1: log(PHI) = XB
%                             2: probit(PHI) = XB
%                             3: logit(PHI) = XB
%
%       'Replicates' Number REPS of estimations to perform starting from
%                    the starting values in the vector BETA0. If BETA0 is a
%                    matrix, REPS must match the number of columns in
%                    BETA0. Default is the number of columns in BETA0.
%
%       'Vectorization'  Determines the possible sizes of the PHI, XFUN,
%                    and VFUN input arguments to MODELFUN.  Possible
%                    values are:
%             'SinglePhi'    MODELFUN is a function (such as an ODE solver)
%                            that can only compute YFIT for a single set of
%                            model parameters at a time, i.e., PHI must be
%                            a single row vector in each call. NLMEFITSA
%                            calls MODELFUN in a loop if necessary using a
%                            single PHI vector and with XFUN containing
%                            rows for a single observation or group at a
%                            time. VFUN may be a single row that applies to
%                            all rows of XFUN, or a matrix with rows
%                            corresponding to rows in XFUN.
%            'SingleGroup'   MODELFUN can only accept inputs corresponding
%                            to a single group in the data, i.e., XFUN must
%                            contain rows of X from a single group in each
%                            call. Depending on the model, PHI is a single
%                            row that applies to the entire group, or a
%                            matrix with one row for each observation. VFUN
%                            is a single row.
%            'Full'          MODELFUN can accept inputs for multiple
%                            parameter vectors and multiple groups in the
%                            data. Either PHI or VFUN may be a single row
%                            that applies to all rows of XFUN, or a matrix
%                            with rows corresponding to rows in XFUN. Using
%                            this option can improve performance by
%                            reducing the number of calls to MODELFUN, but
%                            may require MODELFUN to perform singleton
%                            expansion on PHI or V.
%                        The default for 'Vectorization' is 'SinglePhi'. In
%                        all cases, if V is empty, NLMEFITSA calls MODELFUN
%                        with only two inputs.
%
%   Example:
%      % Fit a model to data on concentrations of the drug indomethacin in
%      % the bloodstream of six subjects over eight hours
%      load indomethacin
%      model = @(phi,t)(phi(:,1).*exp(-phi(:,2).*t) + phi(:,3).*exp(-phi(:,4).*t));      
%      phi0 = [1 1 1 1];
%      xform = [0 1 0 1]; % log transform for 2nd and 4th parameters
%      [beta,PSI,stats,br] = nlmefitsa(time,concentration,subject,[],...
%                                      model,phi0, 'ParamTransform',xform);
% 
%      % Plot the data along with an overall "population" fit
%      clf
%      phi = [beta(1), exp(beta(2)), beta(3), exp(beta(4))];
%      h = gscatter(time,concentration,subject);
%      xlabel('Time (hours)')
%      ylabel('Concentration (mcg/ml)')
%      title('{\bf Indomethacin Elimination}')
%      xx = linspace(0,8);
%      line(xx,model(phi,xx),'linewidth',2,'color','k')
% 
%      % Plot individual curves based on random effect estimates
%      for j=1:6
%          phir = [beta(1)+br(1,j), exp(beta(2)+br(2,j)), ...
%                  beta(3)+br(3,j), exp(beta(4)+br(4,j))];
%          line(xx,model(phir,xx),'color',get(h(j),'color'))
%      end
%
%   See also NLINFIT, NLMEFIT, NLMEFITOUTPUTFCN, GROUPINGVARIABLE.

%   The following parameters supported by NLMEFIT are not supported by
%   NLMEFITSA, except that they are accepted if the design can be converted
%   to a simpler form. For example, FEObsDesign is accepted if the design
%   provided is actually constant within each group.
%       'FEObsDesign'    A P-by-F-by-N array specifying a different P-by-F
%                        fixed effects design matrix for each of the N
%                        observations.
%       'REGroupDesign'  A P-by-R-by-M array specifying a different P-by-R
%                        random effects design matrix for each of M groups.
%       'REObsDesign'    A P-by-R-by-N array specifying a different P-by-R
%                        random effects design matrix for each of N
%                        observations.

%       'FixedCoefficients' Partially implemented but not supported.

%   Copyright 2009-2010 The MathWorks, Inc.
%   Based on: Marc Lavielle ; 04 - 15 - 2009
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:59:02 $

error(nargchk(6,inf,nargin,'struct'));

Id = grp2idx(group);
uId = unique(Id);
if isa(group,'categorical') % remove levels that do not appear in data
    Id = grp2idx(droplevels(group));
end
NGroups = length(uId);           % number of subjects
NObs = length(y);                % total number of observations
GroupSizes = hist(Id,1:NGroups); % individual numbers of observations (1xNGroups)

if ~isvector(y) || ~isnumeric(y) || ~isreal(y)
    error('stats:nlmefitsa:BadY','Y must be a real-valued numeric vector.');
elseif length(Id)~=NObs
    error('stats:nlmefitsa:BadGroupOrY','Y and GROUP must have the same length.');
elseif ndims(X)>2 || ~isnumeric(X) || ~isreal(X)
    error('stats:nlmefitsa:BadX','X must be a real-valued numeric matrix.');
elseif size(X,1)~=NObs
    error('stats:nlmefitsa:BadXOrY',...
          'Y must be a vector with one value for each row of X.');
end
[Id,sidx] = sort(Id);
X = X(sidx,:);
y = y(sidx);
y = y(:);

if isempty(v)
    v = zeros(NGroups,0);
elseif ndims(v)>2 || ~isnumeric(v) || ~isreal(v) || size(v,1) ~= max(Id)
    error('stats:nlmefitsa:BadV','V must be a real-valued numeric array with one row per group.');
elseif length(v)>NGroups
    v = v(uId); % remove unused groups
end

options = parseArguments(varargin{:});

if isempty(beta0)
    error('stats:nlmefitsa:MissingInitialValues',...
          'Initial values input argument BETA0 cannot be empty.');
elseif isvector(beta0) && ...
        (isempty(options.Replicates) || ...
         (isscalar(options.Replicates) && options.Replicates ~= numel(beta0)))
    % Force initial values to a column vector. If the intent is to provide
    % multiple initial values for a single parameter, it's necessary to use
    % the 'Replicates' option to make that clear.
    beta0 = beta0(:);
end

[options,fdesign] = process_design(options, size(beta0,1), NObs, NGroups, Id);

covariate_model      = any(options.A,3);
number_parameters    = size(options.A,1);
number_etas          = size(options.B,2);

options = fix_defaults(options,number_parameters,NGroups,beta0,number_etas);

fixedcoeffs          = (options.FixedCoefficients ~= 0);
nchains              = options.NChains;
verbose              = options.verbose;
covariance_model     = options.CovPattern~=0;

% SAEM algorithm settings.
numMCMC = options.NMCMCIterations;
numiter = options.NIterations;
total_number_iterations_saem = sum(numiter);
number_iterations_sa = numiter(1);
stepsize = ones(1,total_number_iterations_saem);
stepsize(sum(numiter(1:2))+1:total_number_iterations_saem)=1./numiter(3);
alpha1_sa = options.alpha_sa;
alpha0_sa = 10^(-3/number_iterations_sa);

% Default stream or the one passed in
[myrand,myrandn,myrandsample,mystream] = getrandfuns(options);

% Error models are described by [a b]:
%   constant            y = f + a*e
%   proportional        y = f + b*f*e
%   combined            y = f + (a+b*f)*e
%   exponential         y = f*exp(a*e)    ( <=>  log(y) = log(f) + a*e )
[errmod,y] = update_error(options.ErrorModel,y,options.ErrorParameters);

nreps = options.Replicates;
betas = repmat(beta0(:,1),1,nreps);
Gamma = zeros(number_etas,number_etas,nreps);
if nargout>=4
    b_hat = NaN(sum(diag(covariance_model)),NGroups,nreps);
end

% We will process the random effects in order of parameter, but also get a
% permutation vector in case REParamsSelect or REConstDesign permutes the
% order of the effects
idxRandParams = diag(covariance_model);
idxFixedParams = find(~idxRandParams);
idxRandOrder = (1:size(options.B,1))*options.B; % get r.e. in order specified
[~,idxRandPerm] = sort(idxRandOrder);           % permute to this order

for jrep=1:nreps
    jbeta = min(jrep,size(beta0,2));
    if nargout<3
        [stop,betas(:,jrep),Gj] = onefit(beta0(:,jbeta));
    else
        [stop,betas(:,jrep),Gj,statsj,b_hat(idxRandPerm,uId,jrep)] = onefit(beta0(:,jbeta));
    end
    if nargout>=3
        if jrep==1
            stats = repmat(statsj,nreps,1);
        else
            stats(jrep) = statsj;
        end
    end
    Gamma(:,:,jrep) = Gj(idxRandOrder,idxRandOrder); % get subset in proper order
    if stop && jrep<nreps % remove initialized but not filled-in values
        betas(:,jrep+1:end) = [];
        Gamma(:,:,jrep+1:end) = [];
        if nargout>=3
            stats(jrep+1:end) = [];
        end
        if nargout>=4
            b_hat(:,:,jrep+1:end) = [];
        end
        break
    end
end
return

% --- nested function to carry out one fit from one starting value
function [stop,betas,Gamma,stats,b_hat] = onefit(beta0)
stop = false;

% Initial values for coefficients, model parameters, and covariance
betas_ini = beta0(:);
Gamma_ini = get_prior_cov(options, idxRandParams, betas_ini);

% the covariate model
DesignEstim = covariate_model;
DesignEstim(:,fixedcoeffs) = 0;

DesignRand=DesignEstim;
DesignRand(idxFixedParams,:)=0;
ind_fix11=find(DesignRand(covariate_model));
DesignNonRand=DesignEstim;
DesignNonRand(idxRandParams,:)=0;

% Initialization
% the covariates
mean_phi = zeros(NGroups, number_parameters);
for j = 1:number_parameters
    exp_phi_j = permute(options.A(j,:,:),[3 2 1]) * betas_ini;
    if fdesign>2   % expand constant designs to all groups
        exp_phi_j = repmat(exp_phi_j,NGroups,1);
    end
    mean_phi(:,j) = exp_phi_j;
end

COV = permute(sum(options.A,1),[3 2 1]);
if fdesign>2
    COV = repmat(COV,NGroups,1);
end

COV2 = COV'*COV;
LCOV = covariate_model';
MCOV = bsxfun(@times,LCOV,betas_ini(:));

betas=betas_ini(:)';

idxFixedCoeffs = DesignEstim(covariate_model);
COV1=COV(:,idxFixedCoeffs);
dstatphi=COV(:,~idxFixedCoeffs)*MCOV(~idxFixedCoeffs,:);

ind_fix10 = any(DesignNonRand,1);
MCOV0 = MCOV(ind_fix10,idxFixedParams);
COV0 = COV(:,ind_fix10);
j0_covariate=find(LCOV(ind_fix10,idxFixedParams)==1);

flag_fmin = any(double(DesignNonRand)*double(~fixedcoeffs'));

% using several Markov chains
IdM0 = repmat(Id,nchains,1);
IdM = kron((0:nchains-1)',NGroups*ones(NObs,1)) + IdM0;
yM  = repmat(y, nchains, 1);
XM  = repmat(X, nchains, 1);
VM  = repmat(v, nchains, 1);

io  = zeros(NGroups,max(GroupSizes));
for i=1:NGroups,
    io(i,1:GroupSizes(i))=1;
end
ioM     = repmat(io, nchains, 1);
ind_ioM = find(ioM');
DYF     = zeros(size(ioM))';

% Initialisation of phiM
i0_temp= sum(DesignEstim(:,idxFixedParams),1)==0;
ind0_eta=idxFixedParams(i0_temp);
ind_eta=setdiff(1:number_parameters,ind0_eta);
number_etas=length(ind_eta);

Gamma        = Gamma_ini;
chol_Gamma   = chol(Gamma(ind_eta, ind_eta));

% Function to transform parameters
transphi = make_transphi(number_parameters,options.ParamTransform);

% Set up to call the model function according to the requested
% vectorization type
ok = {'singlephi','singlegroup','full'};
vect = find(strcmpi(options.Vectorization, ok));
if ~isscalar(vect)
    okstring = [sprintf('''%s'', ', ok{1:end-1}) 'and ''' ok{end} ''''];
    error('stats:nlmefitsa:BadVectorization',...
          'Bad Vectorization parameter. Valid options are %s.',okstring)
end
fvc = strcmpi(options.FunValCheck,'on');
if ~isa(modelfun,'function_handle')
    error('stats:nlmefitsa:InvalidModelFun','MODELFUN must be a function handle.')
end
structural_model = @(p,x,v,e) modelcaller(fvc,vect,modelfun,IdM,transphi(p),x,v,e);

% Find a valid set of parameters wrt to the structural_model.
% Any parameter set that does not generate NaN, inf or imaginary numbers
% will satisfy this criterion.
phiM = starting_set(nchains,chol_Gamma,mean_phi,XM,VM,IdM,...
                    structural_model,myrandn,errmod,ind_eta);

% initialization of the sufficient statistics
suffstat = update_suffstat;

phi        = zeros(NGroups,number_parameters, nchains);
Gamma_eta  = Gamma(ind_eta,ind_eta);
dGamma2    = repmat(sqrt(diag(Gamma_eta))*options.rw_ini,1,number_etas);
VK         = repmat(1:number_etas,1,2);

Uargs=struct('idxFixedParams',idxFixedParams,'MCOV0',MCOV0,'COV0',COV0,...
    'j0_covariate',j0_covariate,'nmc',nchains,...
    'IdM',IdM,'XM',XM,'structural_model',structural_model,...
    'ind_ioM',ind_ioM,'yM',yM);

% Initialize output function and display
outputFcn = options.OutputFcn;
if ~isempty(outputFcn)
    stop = callOutputFcns('init',outputFcn,NaN*betas,0, ...
                          NaN*Gamma(idxRandOrder,idxRandOrder), ...
                          NaN,jrep,nreps);
    if stop
        total_number_iterations_saem = 0; % skip iterations
    end
end
if verbose>2
    dispiter(0,errmod);
end

%  The Algorithm
for kiter=1-options.NBurnIn:total_number_iterations_saem;
    
    if flag_fmin && kiter==number_iterations_sa
        COV1=COV(:,ind_fix11);
        ind0_eta=idxFixedParams;
        ind_eta=setdiff(1:number_parameters,ind0_eta);
        number_etas=length(ind_eta);
        dGamma2 = dGamma2(ind_eta,ind_eta);
        VK = repmat(1:number_etas,1,2);
        suffstat.phi1 = 0;
        suffstat.phi2 = 0;
        suffstat.phi3 = 0;
    end
    
    Gamma_eta  = Gamma(ind_eta,ind_eta);
    diag_Gamma_eta = diag(Gamma_eta);
    epsmax = eps(max(diag_Gamma_eta)) ^ (3/4);
    if any(diag_Gamma_eta < epsmax)
        Gamma_eta(1:number_etas+1:end) = max(epsmax, diag_Gamma_eta);
        Gamma(ind_eta,ind_eta) = Gamma_eta;
    end
    [chol_Gamma,p] = chol(Gamma_eta);
    if p>0
        disp('Current estimate of parameter correlation:');
        disp(corrcov(Gamma_eta));
        error('stats:nlmefitsa:SingularCovariance',...
              'Estimated covariance is singular.')
    end
    
    % Simulation (MCMC)
    mean_phiM = repmat(mean_phi,nchains,1);
    [f,g] = structural_model(phiM,XM,VM,errmod);
    DYF(ind_ioM) = 0.5*((yM-f)./g).^2+log(g);
    U_y = sum(DYF,1)';
    
    etaM = bsxfun(@minus, phiM(:,ind_eta), mean_phiM(:,ind_eta));
    
    for u = 1:numMCMC(1)
        vk2 = 1:number_etas;
        eta0 = zeros(size(etaM));
        [f,g,etaMc] = saem_randstep(ind_eta,eta0,vk2,myrandn,chol_Gamma,...
            mean_phiM,XM,VM,errmod,structural_model,phiM);
        [U_y,etaM,DYF] = saem_acceptreject(f,g,etaMc,vk2,etaM,myrand,yM,...
            ind_ioM,chol_Gamma,DYF,U_y,[]);
    end
    U_eta=0.5*sum(etaM.*(etaM/chol_Gamma/chol_Gamma'),2);
    
    if numMCMC(2)>0
        nt2=zeros(number_etas,1);
        nbc2=zeros(number_etas,1);
        nrs2=1;
        for u=1:numMCMC(2)
            for vk2=1:number_etas
                eta0 = etaM;
                cholfact = diag(dGamma2(vk2,nrs2));
                [f,g,etaMc] = saem_randstep(ind_eta,eta0,vk2,myrandn,cholfact,...
                    mean_phiM,XM,VM,errmod,structural_model,phiM);
                [U_y,etaM,DYF,U_eta,nbc2,nt2] = saem_acceptreject(f,g,etaMc,vk2,etaM,myrand,yM,...
                    ind_ioM,chol_Gamma,DYF,U_y,U_eta,nbc2,nt2);
            end
        end
        dGamma2(:,nrs2)=dGamma2(:,nrs2).*(1+options.stepsize_rw*(nbc2(:)./nt2(:)-options.proba_mcmc));
    end
    
    if numMCMC(3)>0 && number_etas>1
        nt2=zeros(number_etas,1);
        nbc2=zeros(number_etas,1);
        nrs2=mod(kiter,number_etas-1)+2;
        for u=1:numMCMC(3)
            if nrs2<number_etas
                vk=[0 myrandsample(number_etas-1,nrs2-1)'];
                number_iter2=number_etas;
            else
                vk=0:number_etas-1;
                number_iter2=1;
            end
            for k2=1:number_iter2
                vk2=VK(k2+vk);
                eta0 = etaM;
                cholfact = diag(dGamma2(vk2,nrs2));
                [f,g,etaMc] = saem_randstep(ind_eta,eta0,vk2,myrandn,cholfact,...
                    mean_phiM,XM,VM,errmod,structural_model,phiM);
                [U_y,etaM,DYF,U_eta,nbc2,nt2] = saem_acceptreject(f,g,etaMc,vk2,etaM,myrand,yM,...
                    ind_ioM,chol_Gamma,DYF,U_y,U_eta,nbc2,nt2);
            end
        end
        dGamma2(:,nrs2)=dGamma2(:,nrs2).*(1+options.stepsize_rw*(nbc2(:)./nt2(:) - options.proba_mcmc));
    end

    phiM(:,ind_eta) = bsxfun(@plus, mean_phiM(:,ind_eta), etaM);
    
    if kiter>=1
        % Stochastic Approximation
        f = structural_model(phiM,XM,VM,errmod);
        [suffstat,phi] = update_suffstat(y,f,errmod,phi,phiM,ind_eta,...
                                         stepsize(kiter),suffstat);
        
        % Maximization
        phase1 = (kiter <= number_iterations_sa);
        transition = (kiter == number_iterations_sa);
        [betas,Gamma,MCOV,mean_phi] = update_estimates(betas,Gamma,ind_eta,phiM,XM,VM,errmod,structural_model,...
            MCOV,LCOV,COV,COV1,COV2,flag_fmin,phase1,transition,idxFixedCoeffs,ind_fix11,ind_fix10,suffstat,dstatphi,...
            alpha0_sa,alpha1_sa,idxRandParams,covariance_model,Uargs,stepsize(kiter));
        
        % Residual error
        sig2 = suffstat.rese/NObs;
        errmod = update_error(errmod,yM,sig2,f,alpha1_sa,stepsize(kiter),~phase1);
    end
    
    % SAEM convergence plots and iteration display
    if ~isempty(outputFcn)
        stop = callOutputFcns('iter',outputFcn,betas,kiter-1, ...
                          Gamma(idxRandOrder,idxRandOrder), ...
                          errmod.p,jrep,nreps);
        if stop
            break
        end
    end
    if verbose>2 && kiter>=1
       dispiter(kiter-1,errmod,betas);
    end
end

Gamma(~idxRandParams,:)=0;
Gamma(:,~idxRandParams)=0;

phi(:,~idxRandParams,:) = repmat(mean_phi(:,~idxRandParams),[1 1 nchains]);
phi=mean(phi,3); %last values of phi used as initial values for computing the MAP

if nargout>=4 % needed for both stats and b_hat
    %  compute the individual parameters (MAP, maximum a posteriori)
    optfunc = options.OptimFun;
    b_hat = saemmode(optfunc,Id,X,mean_phi,phi,y,v,idxRandParams,...
        structural_model,errmod,Gamma);
end

betas = betas';
nb_param_est = sum(DesignEstim(:)) + sum(sum(triu(covariance_model))) ...
                    +1 + strcmp(errmod.type,'combined');

stats.logl = [];
stats.aic = [];
stats.bic = [];
stats.sebeta = [];
stats.dfe = max(0, NObs - nb_param_est);
stats.covb = [];

if (strcmp(errmod.type,'constant') || strcmp(errmod.type,'exponential'))
    stats.errorparam = errmod.a;
elseif strcmp(errmod.type,'proportional')
    stats.errorparam = errmod.b;
else  %%  errmod.type = 'combined'
    stats.errorparam = errmod.p;
end

if nchains>1
    % Done with multiple chains; re-create model function for just one chain
    structural_model = @(p,x,v,e) modelcaller(fvc,vect,modelfun,Id,transphi(p),x,v,e);
end

if nargout>=4
    Yhat = computeyhat(structural_model,X,v,errmod,mean_phi,b_hat,idxRandParams);
    res = y-Yhat;
    stats.rmse = sqrt(sum(abs(res).^2) / stats.dfe);
end

if options.ComputeStdErrors || ~strcmpi(options.LogLikMethod,'none')
    % conditional means and variances used for the estimation of the log-likelihood via Importance Sampling
    cond_mean_phi=phi;
    sphi1=phi;
    sphi1(:,ind_eta)=suffstat.phi1;
    cond_mean_phi(:,idxRandParams)=sphi1(:,idxRandParams);
    cond_var_phi=zeros(size(phi));
    cond_var_phi(:,idxRandParams)=max(0,suffstat.phi3(:,idxRandParams)-cond_mean_phi(:,idxRandParams).^2);
    
    options.i0_omega2=idxFixedParams;
    options.i1_omega2=idxRandParams;
    options.covariate_model=covariate_model;
    options.covariance_model=covariance_model;
    options.DesignEstim=DesignEstim;
    st.options=options;
    
    st.betas=betas;
    st.Omega=Gamma;
    st.cond_mean_phi=cond_mean_phi;
    st.cond_var_phi=cond_var_phi;
    st.mean_phi=mean_phi;
    st.phi=phi;
end

if options.ComputeStdErrors || strcmpi(options.LogLikMethod,'lin')
    % Compute the Fisher Information Matrix or linear log lik
    st = saemfim(st,GroupSizes,structural_model,y,X,v,errmod,options.A);
    if strcmpi(options.LogLikMethod,'lin')
        logl = st.ll_lin;
    end
    if options.ComputeStdErrors
        stats.covb = -inv(st.fim(1:length(betas),1:length(betas)));
        stats.sebeta = sqrt(diag(stats.covb));
    end
end

if strcmpi(options.LogLikMethod,'is') 
    % Estimate the log-likelihood via importance Sampling
    % This function generates t random variables from the default stream,
    % so temporarily change that stream here
    if ~isempty(mystream)
        oldstr = RandStream.setDefaultStream(mystream);
    end
    try
        st = saem_ll_is(st,GroupSizes,Id,y,X,v,errmod,fvc,vect,modelfun,transphi);
    catch me
        RandStream.setDefaultStream(oldstr);
        rethrow(me);
    end
    if ~isempty(mystream)
        RandStream.setDefaultStream(oldstr);
    end
    logl = st.ll_is;
end

if strcmpi(options.LogLikMethod,'gq')
    % Estimate the log-likelihood via Gaussian quadrature
    st = saem_ll_gq(st,GroupSizes,Id,y,X,v,errmod,fvc,vect,modelfun,transphi);
    logl = st.ll_gq;
end

if ~strcmpi(options.LogLikMethod,'none')
    stats.logl = logl;
    stats.aic = -2*logl + 2*nb_param_est;
    stats.bic = -2*logl + log(NGroups)*nb_param_est;
end

if ~isempty(outputFcn)
    if stop
        if nreps==1
            warning('stats:nlmefitsa:AlgorithmTerminatedByOutputFcn',...
                'Algorithm was terminated by the output function.');
        else
            warning('stats:nlmefitsa:ReplicateTerminatedByOutputFcn',...
                'Algorithm was terminated by the output function during replicate %d of %d.',jrep,nreps);
        end
    end
    stop = callOutputFcns('done',outputFcn,betas,kiter-1, ...
                          Gamma(idxRandOrder,idxRandOrder), ...
                          errmod.p,jrep,nreps);
end
if verbose
    fprintf('\nCompleted %d iterations.\n',total_number_iterations_saem);
    fprintf('  Root mean square error = %s\n',errmod2text(errmod));
    fprintf('  Estimated coefficients =\n');
    fprintf('   %g',betas);
    fprintf('\n');
end
end
end % of main function

% ------------------------------------
function yhat = computeyhat(structural_model,X,v,errmod,mean_phi,b_hat,idxRandParams)
phi = mean_phi;
phi(:,idxRandParams) = phi(:,idxRandParams) + b_hat';
yhat = structural_model(phi,X,v,errmod);
end

% ------------------------------------
function stop = callOutputFcns(state,outputFcn,Beta,iter,Psi,mse,jrep,nreps)

% Package up most information into a structure
ofopt = struct('iteration',iter, 'Psi',Psi, 'mse',mse,'caller','nlmefitsa',...
               'replicate',jrep,'nreplicates',nreps);

% Call each output function
stop = false;
for i = 1:numel(outputFcn)
    stop = stop | outputFcn{i}(Beta,ofopt,state);
end
end

function dispiter(iter,errmod,beta)
% display iteration summary
if isequal(errmod.type,'combined')
    if nargin<3
        fprintf('%6s %26s %13s\n','Iter','RMSE','Beta');
    else
        fprintf('%6d %26s',iter,errmod2text(errmod));
        fprintf(' %13.5g',beta);
        fprintf('\n');
    end
else
    if nargin<3
        fprintf('%6s %13s %13s\n','Iter','RMSE','Beta');
    else
        fprintf('%6d %13s',iter,errmod2text(errmod));
        fprintf(' %13.5g',beta);
        fprintf('\n');
    end
end
end

% -----------------------
function U=conditional_distribution(phi1,phii,Xi,yi,vi,expected_phi1,idxRandParams,...
    structural_model,errmod,chol_Gamma)

phii(idxRandParams)=phi1;
[fi,gi] = structural_model(phii,Xi,vi,errmod);
Uy=sum(0.5*((yi-fi)./gi).^2+log(gi));
dphi=phi1-expected_phi1;
U_phi=0.5*sum(dphi.*(dphi/chol_Gamma/chol_Gamma'),2);
U=Uy+U_phi;
end

% -----------------------
function options = fix_defaults(options,number_parameters,NGroups,beta0,number_etas)
% Process options structure to compute defaults as needed

[nbetas,nstarts] = size(beta0);
idxRandParams = any(options.B,2);
v = options.CovPattern;
if isempty(v)
    v = eye(number_etas);
elseif isvector(v) && (isnumeric(v)||islogical(v)) && numel(v)==number_etas
    g = grp2idx(v);
    v = false(number_etas);
    for j=1:max(g)
        v(g==j,g==j) = true;
    end
elseif (isnumeric(v)||islogical(v)) && isequal(size(v),[number_etas,number_etas])
    v = v~=0;
else
    error('stats:nlmefitsa:BadCovPattern',...
          'CovPattern parameter must be a vector or square matrix with one row for each random effect.')
end
v0 = false(number_parameters);
v0(idxRandParams,idxRandParams) = v;
options.CovPattern = v0;

if isempty(options.ParamTransform)
    options.ParamTransform = zeros(1,number_parameters);
end

if isempty(options.FixedCoefficients)
    options.FixedCoefficients = zeros(1,nbetas); % all the fixed effects are estimated
end

if isempty(options.covariate_model)
    options.covariate_model = ones(1,number_parameters); % no covariates in the model (only the intercepts)
end

if isempty(options.covariance_model)
    options.covariance_model = eye(number_parameters); % diagonal covariance matrix of the random effects
end

if isempty(options.OptimFun) || strcmpi(options.OptimFun,'fminsearch')
    options.OptimFun = @fminsearch;
elseif strcmpi(options.OptimFun,'fminunc')
    if ~license('test', 'Optimization_Toolbox') || ~exist('fminunc', 'file')
        error('stats:nlmefitsa:RequiresOptimToolbox',...
              'Using ''fminunc'' as the OptimFun parameter requires the Optimization Toolbox.');
    end
    [canCheckout, checkoutMsg] = license('checkout', 'Optimization_Toolbox');
    if ~canCheckout
        error('stats:nlmefitsa:RequiresOptimLicense',...
              'Cannot check out Optimization Toolbox license. Using ''fminunc'' as the OptimFun parameter requires this license.');
    end        

    opt = optimset('Display','off','LargeScale','off');
    options.OptimFun = @(f,x) fminunc(f,x,opt);
else
    error('stats:nlmefitsa:BadOptimFun',...
          'OptimFun parameter must be ''fminsearch'' or ''fminunc''.');
end

val = options.NBurnIn;
if ~(isnumeric(val) && isscalar(val) && val>=0 && val==round(val))
    error('stats:nlmefitsa:BadNBurnIn',...
          'NBurnIn parameter must be a non-negative scalar integer value.');
end

val = options.NChains;
if isempty(val)
    % Rule of thumb is to aim for about 100 total groups
    options.NChains = max(1, round(100/NGroups));
elseif ~(isnumeric(val) && isscalar(val) && val>=1 && val==round(val))
    error('stats:nlmefitsa:BadNChains',...
          'NChains parameter must be a positive scalar integer value.');
end

val = options.NIterations;
if isnumeric(val) && isscalar(val) && val>0 && val==round(val)
    % Total number of iterations was specified. Distribute this over the
    % various phases using the default proportions.
    v = round(val * [150 150 100]/400);
    v(3) = val - sum(v(1:2));
    options.NIterations = v;
elseif ~ (isnumeric(val) && isvector(val) && numel(val)==3 && ...
          sum(val)>0     && all(val>=0)   && all(val==round(val)))
    error('stats:nlmefitsa:BadNIterations',...
          'NIterations parameter must be a scalar or three-element vector of positive integer values.');
end

val = options.NMCMCIterations;
if isnumeric(val) && isscalar(val) && val>0 && val==round(val)
    % Total number of iterations was specified. Repeat this value for all
    % three phases
    options.NMCMCIterations = [val val val];
elseif ~ (isnumeric(val) && isvector(val) && numel(val)==3 && sum(val)>0 ...
                         && all(val>=0)   && all(val==round(val)))
    error('stats:nlmefitsa:BadNMCMCIterations',...
          'NMCMCIterations parameter must be a scalar or three-element vector of non-negative integer values with at least one positive value.');
end

val = options.ComputeStdErrors;
if ~(isscalar(val) && (val==0 || val==1))
    error('stats:nlmefitsa:BadComputeStdErrors',...
          'ComputeStdErrors parameter must be true or false.')
end

val = options.LogLikMethod;
ok = {'is' 'gq' 'lin' 'none'};
j = strcmpi(val,ok);
if ~any(j)
    okstring = [sprintf('''%s'', ', ok{1:end-1}) 'and ''' ok{end} ''''];
    error('stats:nlmefitsa:BadLogLikMethod',...
          'Bad LogLikMethod parameter. Valid values are %s.', okstring);
end
options.LogLikMethod = ok{j};

val = options.Replicates;
if isempty(val)
    options.Replicates = nstarts;
elseif ~(isnumeric(val) && isscalar(val) && val>=1 && val==round(val))
    error('stats:nlmefitsa:BadReplicates',...
          'Replicates parameter must be a positive scalar integer value.');
elseif nstarts>1 && options.Replicates~=nstarts
    error('stats:nlmefitsa:ReplicatesConflict',...
          'Replicates parameter does not match the number of coefficient starting values.');
end
end

% -----------------------
function Gamma_out = get_prior_cov(options,idxRandParams,betas_ini)
% Get initial value for the covariance matrix
Gamma_ini = options.Cov0;
nparams = numel(idxRandParams);
nrandparams = sum(idxRandParams);

if ~isempty(Gamma_ini) && ~(isnumeric(Gamma_ini) && ...
         isequal(size(Gamma_ini),[nrandparams,nrandparams]))
    error('stats:nlmefitsa:BadCovariance',...
          'Cov0 parameter must be a %d-by-%d matrix',...
          nrandparams,nrandparams);
end

% Create default covariance and set this as the output value Gamma_out
fixed_psi_ini = (mean(options.A,3)*betas_ini)'; % use avg design matrix
diag_Gamma_ini = zeros(1,nparams);
d = ones(1,nparams);
j1 = (options.ParamTransform == 0);
d(j1) = max(1, fixed_psi_ini(j1).^2);
Gamma_out = diag(d);

if ~isempty(Gamma_ini)
    % Check that this subset of the full covariance matrix is okay
    [~,p] = chol(Gamma_ini);
    if p~=0
       error('stats:nlmefitsa:SingularCovariance',...
             'Cov0 parameter must be positive definite.');
    end
    
    % Insert this into the output, leaving fixed effect entries alone
    Gamma_out(idxRandParams,idxRandParams) = Gamma_ini;
end
end

% ---------------------------
function [myrand,myrandn,myrandsample,mystream] = getrandfuns(options)
% Get functions for computing random numbers. These function will use a
% seed if one is specified, but by default will call the built-in functions
% directly to avoid dispatching overhead.
if isempty(options.Streams)
    myrand  = @rand;
    myrandn = @randn;
    myrandsample = @randsample;
    mystream = [];
else
    if ~iscell(options.Streams)
        randStream = options.Streams;
    elseif isscalar(options.Streams)
        randStream = options.Streams{1};
    else
        error('stats:nlmefitsa:BadStream','Stream parameter must be a random stream.')
    end
    myrand  = @randStream.rand;
    myrandn = @randStream.randn;
    myrandsample = @(varargin) randsample(randStream,varargin{:});
    mystream = randStream;
end
end

% -------------------------------
function transphi = make_transphi(number_parameters,paramtransform,deriv)
%MAKE_TRANSPHI Make a function for transforming the parameters
%   This function is intended to save time by resolving the parameter
%   transformation just one time if all transforms are of the same type.

if ~isvector(paramtransform) || numel(paramtransform)~=number_parameters ...
                             || ~all(ismember(paramtransform,0:3))
    error('stats:nlmefitsa:BadParamTransform',...
          'ParamTransform value must be a vector of %d elements containing transformation codes.',...
          number_parameters);
end
if nargin<3 || ~deriv
    % Create a function handle to compute the transformed parameters
    if all(paramtransform==0)
        transphi = @(x) x;
    elseif all(paramtransform==1)
        transphi = @(x) exp(x);
    elseif all(paramtransform==2)
        transphi = @(x) normcdf(x);
    elseif all(paramtransform==3)
        transphi = @(x) 1./(1+exp(-x));
    else
        transphi = @(x) transphiselector(x,paramtransform);
    end
else
    % Create a function handle to compute the derivative of the transform
    if all(paramtransform==0)
        transphi = @(x) ones(size(x));
    elseif all(paramtransform==1)
        transphi = @(x) exp(x);
    elseif all(paramtransform==2)
        transphi = @(x) normpdf(x);
    elseif all(paramtransform==3)
        transphi = @(x) 1./(2 + exp(-x) + exp(x));
    else
        transphi = @(x) dtransphiselector(x,paramtransform);
    end
end
end

% Utility for transforming parameters when there is a mix of types
function psi = transphiselector(phi,tr)
psi=phi;
i1=(tr==1);           % lognormal
if any(i1)
   psi(:,i1)=exp(phi(:,i1));
end
i2=(tr==2);           % probit
if any(i2)
    psi(:,i2)=normcdf(phi(:,i2));
end
i3=(tr==3);           % logit
if any(i3)
    psi(:,i3)=1./(1+exp(-phi(:,i3)));
end
end

% Utility for computing the deriviative of the transform when there is a mix of types
function d_psi = dtransphiselector(phi,tr)
d_psi=ones(size(phi));
i1=(tr==1);           % lognormal
if any(i1)
    d_psi(:,i1)=exp(phi(:,i1));
end
i2=find(tr==2);       % probit
if any(i2)
    d_psi(:,i2)=normpdf(phi(:,i2));
end
i3=find(tr==3);       % logit
if any(i3)
    d_psi(:,i3)=1./(2 + exp(-phi(:,i3)) + exp(phi(:,i3)));
end
end

% --------------------------------
function [f,g] = modelcaller(funvalcheck,vect,fun,grp,phi,X,V,errmod)
% Utility to call the model function the way it is prepared to handle
% inputs:
%  vect=1 means the function can handle just a single phi value at a time
%  vect=2 means the function can handle just a single group at a time;
%         for example a function that had to solve an ODE could do that
%         for all time points at once, but only for one individual
%  vect=3 means the function can take any inputs as full arrays

f = calcf(vect,fun,grp,phi,X,V);

if funvalcheck && any(~isfinite(f))
    error('stats:nlmefitsa:CheckFunVals',...
          'Model function has returned Inf or NaN values.');
end

if nargin>=8 && strcmp(errmod.type,'exponential')
    f=log(max(f,realmin));
end

if nargout>1
    g = max(realmin,errmod.a+errmod.b*(abs(f)));
end

end

% utility for modelcaller
function f=calcf(vect,fun,grp,phi,X,V)
nphi = size(phi,1);
nX = size(X,1);
nGroups = size(V,1); % V may be empty but will have this 1st dimension

if nX<length(grp)
    nGroups = 1; % was called with just one group
end

switch(vect)
    case 1  % SinglePhi: call model with just one Phi vector
            % We assume V may be a single vector.
        if nphi==1
            if isempty(V)
                f = fun(phi,X);
            else
                f = fun(phi,X,V);
            end
        elseif nphi==nGroups
            f = zeros(length(grp),1);
            for j=1:nphi
                t = (grp==j);
                if isempty(V)
                    f(t) = fun(phi(j,:),X(t,:));
                else
                    f(t) = fun(phi(j,:),X(t,:),V(j,:));
                end
            end
        else % nphi==nX
            f = zeros(nX,1);
            for j=1:nX
                t = (grp==j);
                if isempty(V)
                    f(t) = fun(phi(j,:),X(j,:));
                else
                    f(t) = fun(phi(j,:),X(j,:),V(grp(j),:));
                end
            end
        end


    case 2  % SingleGroup: call model with just one group
            % We assume phi may have one or more rows,
            % and V may be a single vector.
        f = zeros(nX,1);
        for j=1:nGroups
            if nGroups>1
                t = (grp==j);
            else
                t = true(size(X,1),1);
            end
            if nphi==1
                phiarg = phi; %phi(ones(sum(t),1),:);
            elseif nphi<nX
                phiarg = phi(j,:); % repmat(phi(j,:),sum(t),1);
            else
                phiarg = phi(t,:);
            end
            
            if isempty(V)
                f(t) = fun(phiarg,X(t,:));
            else
                f(t) = fun(phiarg,X(t,:),V(j,:));
            end
        end
     
    case 3  % Full: model function can vectorize
            % We assume the function wants everything expanded
        if nphi==1
            phiarg = phi(ones(size(X,1),1),:);
        elseif nphi<nX
            phiarg = phi(grp,:);
        else
            phiarg = phi;
        end
        
        if isempty(V)
            f = fun(phiarg,X);
        elseif size(V,1)==1
            f = fun(phiarg,X,V(ones(size(X,1),1),:));
        else
            f = fun(phiarg,X,V(grp,:));
        end
            
end
end

% --------------------------------
function options = parseArguments(varargin)

% Options defined here and not changeable at the command line
options.proba_mcmc                = 0.4;
options.stepsize_rw               = 0.4;
options.rw_ini                    = 0.5;
options.alpha_sa                  = 0.97;
options.nmc_is                    = 5000;
options.nu_is                     = 4;

% Options accepted as command-line arguments
options.FixedCoefficients    = []; % all the fixed effects are estimated
options.covariate_model      = []; % no covariates in the model (only the intercepts)
options.covariance_model     = []; % diagonal covariance matrix of the random effects

options.NBurnIn              = 5;  % number of burn-in iterations
options.NChains              = []; % number of chains
options.NIterations          = [150 150 100]; % number of iterations to perform
                                              % in each of three phases:
                                              % [with simulated annealing,
                                              %  with full step size,
                                              %  with reduced step size]
options.NMCMCIterations      = [2 2 2]; % number of MCMC iterations to perform
                                        % during each main iteration:
                                        % [full multivariate update,
                                        %  single coordinate update,
                                        %  multiple coordinate update]
options.Replicates         = [];      % number of replicate estimations

options.ComputeStdErrors     = false; % compute std errors & Fisher info
options.LogLikMethod         = 'none'; % omit log likelihood
options.ParamTransform       = [];    % vector of codes for transformations
options.CovPattern           = [];    % the covariance matrix pattern
options.Cov0                 = [];    % initial covariance matrix of the random effects
options.OutputFcn            = {@nlmefitoutputfcn};  % output function or functions
options.Vectorization        = 'SinglePhi'; % call model fn with a single phi vector
options.ErrorModel           = 'constant';  % constant error model, y = f(x) + error
options.ErrorParameters      = []; % default depends on error model

options.FEParamsSelect = [];
options.FEConstDesign =  [];
options.FEGroupDesign =  [];
options.FEObsDesign =    [];

options.REParamsSelect = [];
options.REConstDesign =  [];
options.REGroupDesign =  [];
options.REObsDesign =    [];

% Options set through statset
options.OptimFun = 'fminsearch';
options.FunValCheck = 'off';
options.Streams = [];
options.verbose = 0;

numvaragin = numel(varargin);
if numvaragin > 0
    if rem(numvaragin, 2)
        error('stats:nlmefitsa:IncorrectNumberOfArguments', ...
              'Incorrect number of arguments to nlmefitsa.');
    end
    valid_args = {'Options', 'FixedCoefficients', 'covariance_model',...
        'ParamTransform', 'CovPattern' 'Vectorization', 'OptimFun',...
        'FEParamsSelect' 'FEConstDesign' 'FEGroupDesign' 'FEObsDesign', ...
        'REParamsSelect' 'REConstDesign' 'REGroupDesign' 'REObsDesign', ...
        'NBurnIn','NChains','NIterations','NMCMCIterations','Cov0',...
        'ComputeStdErrors', 'LogLikMethod' 'Replicates', ...
        'ErrorModel', 'ErrorParameters'};
    
    for j = 1:2:numvaragin
        property_name  = varargin{j};
        if isempty(property_name) || ~ischar(property_name) || size(property_name,1)>1
            error('stats:nlmefitsa:BadParameterName',...
                  'Parameter names must be non-empty character strings');
        end
        property_value = varargin{j+1};
        property_index = find(strncmpi(property_name, valid_args, length(property_name)));
        if isempty(property_index)
            error('stats:nlmefitsa:UnknownParameterName', 'Unknown parameter name: %s.', property_name);
        elseif length(property_index) > 1
            error('stats:nlmefitsa:AmbiguousParameterName', 'Ambiguous parameter name: %s.', property_name);
        elseif property_index>1
            % No checking on the property value for now so pass in the
            % right thing.
            options.(valid_args{property_index}) = property_value;
        else % statset options structure -- extract desired values from this
            if ~isstruct(property_value)
                error('stats:nlmefitsa:BadOptions','Options parameter must be a structure.');
            end
            
            try
                newopt = statset(statset('nlmefitsa'),property_value);
            catch ME
                newME = MException('stats:nlmefitsa:BadOptionsSetting',...
                                   'Options parameter contains invalid settings.');
                newME = addCause(newME,ME);
                throw(newME);
            end
            
            options.FunValCheck = setifnotempty(newopt.FunValCheck,options.FunValCheck);
            options.Streams = setifnotempty(newopt.Streams,options.Streams);
            
            if isfield(property_value,'OutputFcn')
                val = property_value.OutputFcn; % an empty value overrides the default
                if ~iscell(val) && isscalar(val) && isa(val,'function_handle')
                    val = {val};
                end
                options.OutputFcn = val;
            end
            
            if ~isempty(newopt.Display)
                switch newopt.Display
                    case {'none','off'},  options.verbose = 0;
                    case 'final',         options.verbose = 2;
                    case {'iter','on'},   options.verbose = 3;
                    otherwise,            options.verbose = 0;
                end
            end
        end
    end
end


end

function a=setifnotempty(b,a)
if ~isempty(b)
    a = b;
end
end

% -------------------------------
function [options,fdesign,rdesign] = process_design(options,nb,nobs,ngrps,grp)
% Process the options that define the fixed and random designs

% Only one of each
if 1 < ~isempty(options.FEParamsSelect) + ~isempty(options.FEConstDesign) + ...
       ~isempty(options.FEGroupDesign) + ~isempty(options.FEObsDesign)
    error('stats:nlmefitsa:MultipleFixedDesigns',...
          'Cannot specify more than one of FEParamsSelect, FEConstDesign, FEGroupDesign, and FEObsDesign.')
end
if 1 < ~isempty(options.REParamsSelect) + ~isempty(options.REConstDesign) + ...
       ~isempty(options.REGroupDesign) + ~isempty(options.REObsDesign)
    error('stats:nlmefitsa:MultipleRandomDesigns',...
          'Cannot specify more than one of REParamsSelect, REConstDesign, REGroupDesign, and REObsDesign.')
end

% Convert to standard form, the A and B matrices that define
%   phi = A*b + B*beta
[fdesign,A,PageA] = dodesign(nobs,nb,ngrps,grp,'fixed',...
    options.FEObsDesign, options.FEGroupDesign, options.FEConstDesign, options.FEParamsSelect);

nparams = size(A,1);
[rdesign,B] = dodesign(nobs,nparams,ngrps,grp,'random',...
    options.REObsDesign, options.REGroupDesign, options.REConstDesign, options.REParamsSelect);

% Make sure these designs are within the limitations of saem.
checkvalid(B);
numparams = sum(any(A,3),1);
if any(numparams>1)
    error('stats:nlmefitsa:RepeatedCoefficients',...
          'FE design must not use the same coefficient for multiple parameters.');
end

% Store in structure
options.A = A;
options.PageA = PageA;
options.B = B;
end


% utility for processing fixed or random design
function [designtype,A,PageA] = dodesign(nobs,nb,ngrps,grp,fixedorrand,...
                           ObsDesign,GroupDesign,ConstDesign,ParamsSelect)

if isempty(ObsDesign) && isempty(GroupDesign) && ...
   isempty(ConstDesign) && isempty(ParamsSelect)
    A = eye(nb);
    PageA = ones(nobs,1);
    designtype = 4;
    return
end    

israndom = strcmpi(fixedorrand,'random');

if ~isempty(ObsDesign)
    A = ObsDesign;
    if ndims(A)~=3 || size(A,3)~=nobs
        error('stats:nlmefitsa:BadDesign','Bad %s design. Must be a 3-D array with %d pages.',fixedorrand,nobs);
    elseif (size(A,2)~=nb && ~israndom)
        error('stats:nlmefitsa:BadFixedDesign','Bad fixed design. Must have %d columns.',nb);
    end
    
    % SAEM doesn't support observation designs, so reject this unless it
    % can be converted to a group design
    for j=2:length(grp)
        if grp(j)==grp(j-1) && ~isequal(A(:,:,j),A(:,:,j-1))
            error('stats:nlmefitsa:NoObs','Obs design not supported.')
        end
    end
    k = [1, 1+find(diff(grp))'];
    GroupDesign = A(:,:,k);
end

if ~isempty(GroupDesign)
    A = GroupDesign;
    PageA = grp;
    if ndims(A)~=3 || size(A,3)~=ngrps
        error('stats:nlmefitsa:BadDesign','Bad %s design. Must be a 3-D array with %d pages.',fixedorrand,ngrps);
    elseif (size(A,2)~=nb && ~israndom)
        error('stats:nlmefitsa:BadFixedDesign','Bad fixed design. Must have %d columns.',nb);
    end
    designtype = 2;
    
    if israndom
        % SAEM doesn't support group designs for random effects, so reject
        % this unless it can be converted to a constant design.
        if ~isequal(A,repmat(A(:,:,1),[1,1,ngrps]))
            if isempty(ObsDesign)
                error('stats:nlmefitsa:NoGroup','Group design not supported for random effect.');
            else
                error('stats:nlmefitsa:NoObs','Obs design not supported.')
            end
        end
        ConstDesign = A(:,:,1);
    end
end

if ~isempty(ConstDesign)
    A = ConstDesign;
    PageA = ones(nobs,1);
    if ndims(A)~=2 ...
            || (size(A,2)~=nb && ~israndom) ... % one column per coefficient
            || (size(A,1)~=nb && israndom)      % one row per parameter
        error('stats:nlmefitsa:BadDesign','Bad %s design.',fixedorrand);
    end
    designtype = 3;
    
elseif ~isempty(ParamsSelect)
    v = ParamsSelect;
    if islogical(v)
        if israndom && length(v)~=nb
            error('stats:nlmefitsa:BadREParamsSelect',...
                  'Logical REParamsSelect parameter must have length %d.',nb);
        end
        v = find(v);
    end
    if ~isvector(v) || (israndom && ~all(ismember(v,1:nb))) ...
                    || (~israndom && ~all(v>0 & v==round(v)))
        error('stats:nlmefitsa:BadDesign','Bad %s design.',fixedorrand);
    end
    if israndom && isempty(v)
        error('stats:nlmefitsa:NoRandomEffects',...
              'This model has no random effects.');
    elseif any(diff(sort(v))==0)
        error('stats:nlmefitsa:RepeatedParamsSelect',...
              'The FEParamsSelect and REParamsSelect arguments cannot have repeated values.');
    end
    A = accumarray([v(:), (1:length(v))'], 1);
    if israndom && size(A,1)<nb
        A(nb,1) = 0;
    elseif ~israndom && size(A,2)~=nb
        error('stats:nlmefitsa:BadFEParamsSelect',...
              'The FEParamsSelect value does not match the size of BETA0.');
    end
    PageA = ones(nobs,1);
    designtype = 4;
end
end

% utility for checking for valid design
function checkvalid(B)
% --- 1. Designs must be constant. Already taken care of.

% --- 2. Random effects must not multiply a covariate.
if ~all(B(:)==0 | B(:)==1)
    error('stats:nlmefitsa:RandomSlope',...
          'Random effects design must consist of 0s and 1s.');
end

% --- 3. At most one random effect per parameter
numrandom = sum(B,2);
if any(numrandom>1)
    error('stats:nlmefitsa:MultipleRandom',...
          'No parameter can have more than one random effect.');
end

% --- 4. At most one parameter per random effect
numparams = sum(B,1);
if any(numparams>1)
    error('stats:nlmefitsa:MultipleParameters',...
          'No random effect can apply to more than one parameter.');
end
      
% --- 5. Cannot have random effects that are not assigned to parameters
if any(numparams==0)
    error('stats:nlmefitsa:UnusedRandomEffects',...
          'At least one random effect is not defined for any parameter.');
end
end

% ----------------------------------
function [U_y,etaM,DYF,U_eta,nbc2,nt2] = saem_acceptreject(f,g,etaMc,vk2,...
    etaM,myrand,yM,ind_ioM,chol_Gamma,DYF,U_y,U_eta,nbc2,nt2)
% Accept or reject a proposed parameter update for SAEM

DYF(ind_ioM) = 0.5*((yM - f)./g).^2 + log(g);
Uc_y = sum(DYF,1)';
deltu = Uc_y-U_y;
if ~isempty(U_eta)
    Uc_eta = 0.5*sum(etaMc.*(etaMc/chol_Gamma/chol_Gamma'),2);
    deltu = deltu+Uc_eta-U_eta;
end

NM = length(deltu);
ind = find( deltu<-log(myrand(NM,1)) );
etaM(ind,:) = etaMc(ind,:);
U_y(ind,:)=Uc_y(ind,:);

if ~isempty(U_eta)
    U_eta(ind,:)=Uc_eta(ind,:);
    nbc2(vk2)=nbc2(vk2)+length(ind);
    nt2(vk2)=nt2(vk2)+NM;
end
end

% ---------------------------
function res=saemfim(res,number_indiv_observations,structural_model,y,X,v,errmod,A)
%Estimate the Fisher Information Matrix and the s.e. of the estimated parameters  

ntot_obs=length(y);
NGroups = length(number_indiv_observations);

options = res.options;

covariate_model=options.covariate_model;
covariance_model=options.covariance_model;
DesignEstim=options.DesignEstim;
i1_omega2=options.i1_omega2;

Omega=res.Omega;
cond_mean_phi=res.cond_mean_phi;
betas=res.betas;

covariance_model=diag(diag(covariance_model));
Omega=diag(diag(Omega));
hat_phi=cond_mean_phi;
nphi=size(hat_phi,2);

dphi=max(1e-10,repmat(1e-4,1,nphi).*abs(mean(hat_phi,1)));
coefphi=[0 -1  1];
F=zeros(ntot_obs,nphi,length(coefphi));
for l=1:length(coefphi)
    for j=1:nphi
        phi=hat_phi;
        phi(:,j)=phi(:,j)+coefphi(l)*dphi(j);
        F(:,j,l) = structural_model(phi,X,v,errmod);
    end
end

ind_covariates = (covariate_model>0);

f0 = F(:,1,1);
g0 = max(realmin,errmod.a+errmod.b*(abs(f0)));
DF=(F(:,:,3)-F(:,:,2))./repmat(dphi,ntot_obs,1)/2; % gradient of f
z=zeros(ntot_obs,1);
j2=0;
for i=1:NGroups
    j1=j2+1;
    j2=j2+number_indiv_observations(i);
    z(j1:j2)=y(j1:j2) - f0(j1:j2) + DF( j1:j2,:)*hat_phi(i,:)';
end;

ind_fixed_est=(DesignEstim(ind_covariates)>0);

ll_lin=-0.5*ntot_obs*log(2*pi);
Fmu=0;
FO=0;
j2=0;
if ndims(A)==2
    Aidx = ones(1,NGroups);
else
    Aidx = 1:NGroups;
end
for i=1:NGroups
    ni=number_indiv_observations(i);
    j1=j2+1;
    j2=j2+ni;
    DFi=DF(j1:j2,:);
    f0i=f0(j1:j2);
    g0i=g0(j1:j2);
    zi=z(j1:j2);
%     Ai=kron(eye(nphi),Mcovariates(i,:));
%     Ai=Ai(:,ind_covariates);
    Ai = A(:,:,Aidx(i));
    DFAi= DFi*Ai;
    Gi=DFi*Omega*DFi' + diag(g0i.^2);  %variance of zi
    %
    Gi=round(Gi*1e10)/1e10;
    [V,D]=eig(Gi);
    V=real(V);
    D=real(D);
    IGi=V*diag(1./diag(D))*V';
    Dzi=zi-DFAi*betas;
    
    if (~isempty(ind_fixed_est))
        DFAiest=DFAi(:,ind_fixed_est);
        Fmu=Fmu-DFAiest'*IGi*DFAiest;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    OP=[];
    for k=1:nphi
        for l=1:nphi
            if covariance_model(k,l)==1
                OPkl= DFi(:,k)*DFi(:,l)';
                OP=[OP OPkl(:)];
            end;
        end;
    end;
    if any(errmod.indices == 1)
        SIi=2*g0i;
        dSIi=diag(SIi);
        OP=[OP  dSIi(:)];
    end;
    if any(errmod.indices == 2)
        SIi=2*f0i.*g0i;
        dSIi=diag(SIi);
        OP=[OP  dSIi(:)];
    end;
    kl=0;
    FG=zeros(size(OP,2),ni*ni);
    for k=1:ni
        for l=1:ni
            FGkl=-IGi(:,k)*IGi(l,:)/2;
            kl=kl+1;
            FG(:,kl)=OP'*FGkl(:);
        end;
    end;
    FO=FO+FG*OP;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ll_lin = ll_lin - 0.5*log(det(Gi)) - 0.5*Dzi'*IGi*Dzi ;
end

if strcmp(errmod.type,'exponential')
    ll_lin=ll_lin-sum(y);
end;

if (~isempty(ind_fixed_est))
    Cth=inv(-Fmu);
else
    Cth=[];
end;

fim=[Fmu zeros(size(Fmu,1),size(FO,2)) ; zeros(size(FO,1),size(Fmu,2)) FO]; 

sTHest=sqrt(diag(Cth));
sTH=zeros(1,length(betas));
sTH(ind_fixed_est)=sTHest;
se_fixed=sTH(:);

CO=inv(-FO);
sO=sqrt(diag(CO));
nb_omega2=sum(i1_omega2);
se_omega2=zeros(nphi,1);
se_omega2(i1_omega2)=sO(1:nb_omega2);
se_res=zeros(2,1);
se_res(errmod.indices)=sO(nb_omega2+1:end);

res.se_fixed=se_fixed;
res.se_omega2=se_omega2;
res.se_res=se_res;
res.ll_lin=ll_lin;
res.fim=fim;
end

% ---------------------------------
function res=saem_ll_is(res,number_indiv_observations,Id,y,X,v,errmod,fvc,vect,modelfun,transphi)
%Estimate the log-likelihood using Importance Sampling 

NGroups = length(number_indiv_observations);

options = res.options;

i1_omega2=options.i1_omega2;
nu_is=options.nu_is;
nmc_is=options.nmc_is;

Omega=res.Omega;
mean_phi=res.mean_phi;
cond_var_phi=res.cond_var_phi;
cond_mean_phi=res.cond_mean_phi;

nphi1=sum(i1_omega2);
IOmega_phi1=inv(Omega(i1_omega2,i1_omega2));

mean_phi1=mean_phi(:,i1_omega2);

MM=100;
KM=round(nmc_is/MM);

log_const=0;
if strcmp(errmod.type,'exponential')
    log_const=-sum(y);
end
number_total_observations = length(y);
IdM = kron((0:MM-1)',NGroups*ones(number_total_observations,1)) + repmat(Id,MM,1);
yM  = repmat(y, MM, 1);
XM  = repmat(X, MM, 1);
VM  = repmat(v, MM, 1);
io  = zeros(NGroups,max(number_indiv_observations));
for i=1:NGroups
    io(i,1:number_indiv_observations(i))=1;
end
ioM     = repmat(io, MM, 1);
ind_ioM = ioM'>0;
DYF     = zeros(size(ioM))';

mean_phiM1=repmat(mean_phi1,MM,1);
mtild_phiM1=repmat(cond_mean_phi(:,i1_omega2),MM,1);

cond_var_phi1=max(realmin,cond_var_phi(:,i1_omega2));
stild_phiM1=repmat(sqrt(cond_var_phi1),MM,1);
phiM=repmat(cond_mean_phi,MM,1);
meana=0;
LL=zeros(KM,1);

c2 = log(det(Omega(i1_omega2,i1_omega2))) + nphi1*log(2*pi);
c1=log(2*pi);

structural_model = @(p,x,v,e) modelcaller(fvc,vect,modelfun,IdM,transphi(p),x,v,e);

for kM=1:KM
    r = trnd(nu_is,nphi1,NGroups*MM)';
    phiM1=mtild_phiM1+stild_phiM1.*r;
    dphiM= phiM1-mean_phiM1;
    
    d2 = -0.5*(sum(dphiM.*(dphiM*IOmega_phi1) ,2) + c2);
    e2 = reshape(d2,NGroups,MM)  ;
    pitild_phi1 = sum(log(tpdf(r,nu_is)),2) ;
    e3 = reshape(pitild_phi1,NGroups,MM)-repmat(0.5*sum(log(cond_var_phi1),2),1,MM);
    
    phiM(:,i1_omega2)=phiM1;
    
    [f,g] = structural_model(phiM,XM,VM,errmod);

    DYF(ind_ioM) = -0.5*((yM-f)./g).^2 - log(g) - 0.5*c1;
    e1=reshape(sum(DYF,1),NGroups,MM);
    sume=e1+e2-e3;
    newa=mean(exp(sume),2);
    meana=meana+1/kM*(newa-meana);
    LL(kM)=sum(log(max(realmin,meana)))+ log_const;
end

res.ll_is=LL(kM);
end

%----------------------------------
function res=saem_ll_gq(res,number_indiv_observations,Id,y,X,v,errmod,fvc,vect,modelfun,transphi)
%RES = LL_GQ(RES) Estimate the log-likelihood using Gaussian Quadrature (multidimensional grid) 

s=res.options;

nnodes_gq = 12;  % number of nodes on each 1-D grid
nsd_gq = 4;  % the integral is computed on the interval [E(eta|y) +- nsd_gq*SD(eta|y)]

i1_omega2=s.i1_omega2;
mean_phi=res.mean_phi;
NGroups = length(number_indiv_observations);
Omega=res.Omega;
IOmega_phi1=inv(Omega(i1_omega2,i1_omega2));
cond_var_phi=res.cond_var_phi;
cond_mean_phi=res.cond_mean_phi;

number_total_observations=length(y);
io  = zeros(NGroups,max(number_indiv_observations));
for i=1:NGroups,
    io(i,1:number_indiv_observations(i))=1;
end
ind_io = find(io');
DYF=zeros(size(io))';

phi=mean_phi;
nphi1=length(i1_omega2);

[x w] = gqg_mlx(nphi1, nnodes_gq);  %nodes on the multidimensional grid
x=(x-0.5)*2;
w=w*2^nphi1;
nx=length(x);

condsd_eta=sqrt(cond_var_phi(:,i1_omega2));
xmin=cond_mean_phi(:,i1_omega2)-nsd_gq*condsd_eta;
xmax=cond_mean_phi(:,i1_omega2)+nsd_gq*condsd_eta;
a=(xmin+xmax)/2;
b=(xmax-xmin)/2;

log_const=0;
if strcmp(errmod.type,'exponential')
    log_const=-sum(y);
end

structural_model = @(p,x,v,e) modelcaller(fvc,vect,modelfun,Id,transphi(p),x,v,e);

Q=0;
for j=1:nx
    phi(:,i1_omega2)=a+b.*repmat(x(j,:),NGroups,1);
    [f,g] = structural_model(phi,X,v,errmod);
    DYF(ind_io) = -0.5*((y-f)./g).^2 - log(g);
    ly=sum(DYF,1)';
    dphi1=phi(:,i1_omega2)-mean_phi(:,i1_omega2);
    lphi1=-0.5*sum((dphi1*IOmega_phi1).*dphi1,2);
    ltot=ly+lphi1;
    inan=isnan(ltot);
    ltot(inan)=-Inf;
    Q=Q+w(j)*exp(ltot);
end

S=NGroups*log(det(Omega(i1_omega2,i1_omega2)))+NGroups*nphi1*log(2*pi)+number_total_observations*log(2*pi);
ll=-S/2 + sum(log(Q)+sum(log(b),2))+ log_const;

res.ll_gq=ll;
end

function [nodes, weights] = gqg_mlx(dim,nnodes_gq)
%
%GQG_MLX Nodes and weights for numerical integration on grids
%(multidimensional Gaussian Quadrature)
%    [x w] = GQG_MLX(dim,nnodes_gq)
%    dim  : dimension of the integration problem
%    nnodes_gq   : number of points on any 1-D grid
%
%    x    = matrix of nodes with dim columns
%    w    = row vector of corresponding weights
%
switch nnodes_gq
    case 1
        n = 5.0000000000000000e-001;
        w = 1.0000000000000000e+000;
    case 2
        n = 7.8867513459481287e-001;
        w = 5.0000000000000000e-001;
    case 3
        n = [5.0000000000000000e-001; 8.8729833462074170e-001];
        w = [4.4444444444444570e-001; 2.7777777777777712e-001];
    case 4
        n = [6.6999052179242813e-001; 9.3056815579702623e-001];
        w = [3.2607257743127516e-001; 1.7392742256872484e-001];
    case 5
        n = [5.0000000000000000e-001; 7.6923465505284150e-001; 9.5308992296933193e-001];
        w = [2.8444444444444655e-001; 2.3931433524968501e-001; 1.1846344252809174e-001];
    case 6
        n = [6.1930959304159849e-001; 8.3060469323313235e-001; 9.6623475710157603e-001];
        w = [2.3395696728634746e-001; 1.8038078652407072e-001; 8.5662246189581834e-002];
    case 7
        n = [5.0000000000000000e-001; 7.0292257568869854e-001; 8.7076559279969723e-001; 9.7455395617137919e-001];
        w = [2.0897959183673620e-001; 1.9091502525256090e-001; 1.3985269574463935e-001; 6.4742483084431701e-002];
    case 8
        n = [5.9171732124782495e-001; 7.6276620495816450e-001; 8.9833323870681348e-001; 9.8014492824876809e-001];
        w = [1.8134189168918213e-001; 1.5685332293894469e-001; 1.1119051722668793e-001; 5.0614268145185180e-002];
    case 9
        n = [5.0000000000000000e-001; 6.6212671170190451e-001; 8.0668571635029518e-001; 9.1801555366331788e-001; 9.8408011975381304e-001];
        w = [1.6511967750063075e-001; 1.5617353852000226e-001; 1.3030534820146844e-001; 9.0324080347429253e-002; 4.0637194180784583e-002];
    case 10
        n = [5.7443716949081558e-001; 7.1669769706462361e-001; 8.3970478414951222e-001; 9.3253168334449232e-001; 9.8695326425858587e-001];
        w = [1.4776211235737713e-001; 1.3463335965499873e-001; 1.0954318125799158e-001; 7.4725674575290599e-002; 3.3335672154342001e-002];
    case 11
        n = [5.0000000000000000e-001; 6.3477157797617245e-001; 7.5954806460340585e-001; 8.6507600278702468e-001; 9.4353129988404771e-001; 9.8911432907302843e-001];
        w = [1.3646254338895086e-001; 1.3140227225512388e-001; 1.1659688229599563e-001; 9.3145105463867520e-002; 6.2790184732452625e-002; 2.7834283558084916e-002];
    case 12
        n = [5.6261670425573451e-001; 6.8391574949909006e-001; 7.9365897714330869e-001; 8.8495133709715235e-001; 9.5205862818523745e-001; 9.9078031712335957e-001];
        w = [1.2457352290670189e-001; 1.1674626826917781e-001; 1.0158371336153328e-001; 8.0039164271673444e-002; 5.3469662997659276e-002; 2.3587668193254314e-002];
    case 13
        n = [5.0000000000000000e-001; 6.1522915797756739e-001; 7.2424637551822335e-001; 8.2117466972017006e-001; 9.0078904536665494e-001; 9.5879919961148907e-001; 9.9209152735929407e-001];
        w = [1.1627577661543741e-001; 1.1314159013144903e-001; 1.0390802376844462e-001; 8.9072990380973202e-002; 6.9436755109893875e-002; 4.6060749918864378e-002; 2.0242002382656228e-002];
    case 14
        n = [5.5402747435367183e-001; 6.5955618446394482e-001; 7.5762431817907705e-001; 8.4364645240584268e-001; 9.1360065753488251e-001; 9.6421744183178681e-001; 9.9314190434840621e-001];
        w = [1.0763192673157916e-001; 1.0259923186064811e-001; 9.2769198738969161e-002; 7.8601583579096995e-002; 6.0759285343951711e-002; 4.0079043579880291e-002; 1.7559730165874574e-002];
    case 15
        n = [5.0000000000000000e-001; 6.0059704699871730e-001; 6.9707567353878175e-001; 7.8548608630426942e-001; 8.6220886568008503e-001; 9.2410329170521366e-001; 9.6863669620035298e-001; 9.9399625901024269e-001];
        w = [1.0128912096278091e-001; 9.9215742663556039e-002; 9.3080500007781286e-002; 8.3134602908497196e-002; 6.9785338963077315e-002; 5.3579610233586157e-002; 3.5183023744054159e-002; 1.5376620998057434e-002];
    case 16
        n = [5.4750625491881877e-001; 6.4080177538962946e-001; 7.2900838882861363e-001; 8.0893812220132189e-001; 8.7770220417750155e-001; 9.3281560119391593e-001; 9.7228751153661630e-001; 9.9470046749582497e-001];
        w = [9.4725305227534431e-002; 9.1301707522462000e-002; 8.4578259697501462e-002; 7.4797994408288562e-002; 6.2314485627767105e-002; 4.7579255841246545e-002; 3.1126761969323954e-002; 1.3576229705875955e-002];
    case 17
        n = [5.0000000000000000e-001; 5.8924209074792389e-001; 6.7561588172693821e-001; 7.5634526854323847e-001; 8.2883557960834531e-001; 8.9075700194840068e-001; 9.4011957686349290e-001; 9.7533776088438384e-001; 9.9528773765720868e-001];
        w = [8.9723235178103419e-002; 8.8281352683496447e-002; 8.4002051078225143e-002; 7.7022880538405308e-002; 6.7568184234262890e-002; 5.5941923596702053e-002; 4.2518074158589644e-002; 2.7729764686993612e-002; 1.2074151434273140e-002];
    case 18
        n = [5.4238750652086765e-001; 6.2594311284575277e-001; 7.0587558073142131e-001; 7.7988541553697377e-001; 8.4584352153017661e-001; 9.0185247948626157e-001; 9.4630123324877791e-001; 9.7791197478569880e-001; 9.9578258421046550e-001];
        w = [8.4571191481571939e-002; 8.2138241872916504e-002; 7.7342337563132801e-002; 7.0321457335325452e-002; 6.1277603355739306e-002; 5.0471022053143716e-002; 3.8212865127444665e-002; 2.4857274447484968e-002; 1.0808006763240719e-002];
    case 19
        n = [5.0000000000000000e-001; 5.8017932282011264e-001; 6.5828204998181494e-001; 7.3228537068798050e-001; 8.0027265233084055e-001; 8.6048308866761469e-001; 9.1135732826857141e-001; 9.5157795180740901e-001; 9.8010407606741501e-001; 9.9620342192179212e-001];
        w = [8.0527224924391946e-002; 7.9484421696977337e-002; 7.6383021032929960e-002; 7.1303351086803413e-002; 6.4376981269668232e-002; 5.5783322773667113e-002; 4.5745010811225124e-002; 3.4522271368820669e-002; 2.2407113382849821e-002; 9.7308941148624341e-003];
    case 20
        n = [5.3826326056674867e-001; 6.1389292557082253e-001; 6.8685304435770977e-001; 7.5543350097541362e-001; 8.1802684036325757e-001; 8.7316595323007540e-001; 9.1955848591110945e-001; 9.5611721412566297e-001; 9.8198596363895696e-001; 9.9656429959254744e-001];
        w = [7.6376693565363113e-002; 7.4586493236301996e-002; 7.1048054659191187e-002; 6.5844319224588346e-002; 5.9097265980759248e-002; 5.0965059908620318e-002; 4.1638370788352433e-002; 3.1336024167054569e-002; 2.0300714900193556e-002; 8.8070035695753026e-003];
    case 21
        n = [5.0000000000000000e-001; 5.7278092708044759e-001; 6.4401065840120053e-001; 7.1217106010371944e-001; 7.7580941794360991e-001; 8.3356940209870611e-001; 8.8421998173783889e-001; 9.2668168229165859e-001; 9.6004966707520034e-001; 9.8361341928315316e-001; 9.9687608531019478e-001];
        w = [7.3040566824845346e-002; 7.2262201994985134e-002; 6.9943697395536658e-002; 6.6134469316668845e-002; 6.0915708026864350e-002; 5.4398649583574356e-002; 4.6722211728016994e-002; 3.8050056814189707e-002; 2.8567212713428641e-002; 1.8476894885426285e-002; 8.0086141288864491e-003];
    case 22
        n = [5.3486963665986109e-001; 6.0393021334411068e-001; 6.7096791044604209e-001; 7.3467791899337853e-001; 7.9382020175345580e-001; 8.4724363159334137e-001; 8.9390840298960406e-001; 9.3290628886015003e-001; 9.6347838609358694e-001; 9.8503024891771429e-001; 9.9714729274119962e-001];
        w = [6.9625936427816129e-002; 6.8270749173007697e-002; 6.5586752393531317e-002; 6.1626188405256251e-002; 5.6466148040269712e-002; 5.0207072221440600e-002; 4.2970803108533975e-002; 3.4898234212260300e-002; 2.6146667576341692e-002; 1.6887450792407110e-002; 7.3139976491353280e-003];
    case 23
        n = [5.0000000000000000e-001; 5.6662841214923310e-001; 6.3206784048517251e-001; 6.9515051901514546e-001; 7.5475073892300371e-001; 8.0980493788182306e-001; 8.5933068156597514e-001; 9.0244420080942001e-001; 9.3837617913522076e-001; 9.6648554341300807e-001; 9.8627123560905761e-001; 9.9738466749877608e-001];
        w = [6.6827286093053176e-002; 6.6231019702348404e-002; 6.4452861094041150e-002; 6.1524542153364815e-002; 5.7498320111205814e-002; 5.2446045732270824e-002; 4.6457883030017563e-002; 3.9640705888359551e-002; 3.2116210704262994e-002; 2.4018835865542369e-002; 1.5494002928489686e-002; 6.7059297435702412e-003];
    case 24
        n = [5.3202844643130276e-001; 5.9555943373680820e-001; 6.5752133984808170e-001; 7.1689675381302254e-001; 7.7271073569441984e-001; 8.2404682596848777e-001; 8.7006209578927718e-001; 9.1000099298695147e-001; 9.4320776350220048e-001; 9.6913727600136634e-001; 9.8736427798565474e-001; 9.9759360999851066e-001];
        w = [6.3969097673376246e-002; 6.2918728173414318e-002; 6.0835236463901793e-002; 5.7752834026862883e-002; 5.3722135057982914e-002; 4.8809326052057039e-002; 4.3095080765976693e-002; 3.6673240705540205e-002; 2.9649292457718385e-002; 2.2138719408709880e-002; 1.4265694314466934e-002; 6.1706148999928351e-003];
    case 25
        n = [5.0000000000000000e-001; 5.6143234630535521e-001; 6.2193344186049426e-001; 6.8058615290469393e-001; 7.3650136572285752e-001; 7.8883146512061142e-001; 8.3678318423673415e-001; 8.7962963151867890e-001; 9.1672131438041693e-001; 9.4749599893913761e-001; 9.7148728561448716e-001; 9.8833196072975871e-001; 9.9777848489524912e-001];
        w = [6.1588026863357799e-002; 6.1121221495155122e-002; 5.9727881767892461e-002; 5.7429129572855862e-002; 5.4259812237131867e-002; 5.0267974533525363e-002; 4.5514130991481903e-002; 4.0070350167500532e-002; 3.4019166906178545e-002; 2.7452347987917691e-002; 2.0469578350653148e-002; 1.3177493307516108e-002; 5.6968992505125535e-003];
    otherwise
        disp('The number of points should not be greater than 25...')
        nodes=[];
        weights=[];
        return
end

n1=1-n;
if rem(nnodes_gq,2)==0
    x=[n1(end:-1:1);n];
    w=[w(end:-1:1);w];
else
    x=[n1(end:-1:2);n];
    w=[w(end:-1:2);w];
end
nodes=zeros(nnodes_gq^dim,dim);
mw=zeros(nnodes_gq^dim,dim);
for j=1:dim
    nodes(:,j)=repmat(kron(x,ones(nnodes_gq^(dim-j),1)),nnodes_gq^(j-1),1);
    mw(:,j)=repmat(kron(w,ones(nnodes_gq^(dim-j),1)),nnodes_gq^(j-1),1);
end
weights=prod(mw,2);
end

% ---------------------------------
function b_hat = saemmode(optfunc,Id,X,expected_phi,phi,y,v,idxRandParams,...
                          structural_model,errmod,Gamma)
% Find random effect estimates at mode of distribution for SAEM                      

Id_list=unique(Id); %not necessarily 1,2...N

% Find coefficients that are virtually constant
idxRandParams = find(idxRandParams);
stdevs = sqrt(diag(Gamma(idxRandParams,idxRandParams)))';
const = stdevs < eps(max(abs(expected_phi(:,idxRandParams)),[],1)).^(3/8);
rows = find(~const);

% Initialize these to zero
NGroups = size(expected_phi,1);
b_hat = zeros(length(const),NGroups);

% Compute estimates for the remainder
idxRandParams = idxRandParams(~const);
chol_Gamma = chol(Gamma(idxRandParams,idxRandParams));

if ~isempty(rows)
    for i=1:NGroups
        k=find(Id==Id_list(i));
        Xi=X(k,:);
        yi=y(k,:);
        vi=v(i,:);
        expected_phi1=expected_phi(i,idxRandParams);
        phii=phi(i,:);
        phi1=phii(idxRandParams);
        f = @(phi1) conditional_distribution(phi1,phii,Xi,yi,vi,expected_phi1,...
            idxRandParams,structural_model,errmod,chol_Gamma);
        phi1_opti=optfunc(f,phi1);
        b_hat(rows,i) = phi1_opti(:) - expected_phi1';
    end
end
end


% ---------------------------------
function [f,g,etaMc] = saem_randstep(ind_eta,etaMc,cols,myrandn,cholfact,...
    mean_phi,XM,VM,errmod,structural_model,phiM)
% Compute a proposed random parameter update for SAEM

ncols = length(cols);
NM = size(etaMc,1);

etaMc(:,cols)=etaMc(:,cols) + myrandn(NM,ncols)*cholfact;

phiMc = phiM;
phiMc(:,ind_eta) = bsxfun(@plus, mean_phi(:,ind_eta), etaMc);

[f,g] = structural_model(phiMc,XM,VM,errmod);
end

% ----------------------------------
function phiM = starting_set(nchains,chol_Gamma,mean_phi,XM,VM,IdM,...
                             structural_model,myrandn,errmod,ind_eta)
% Compute acceptable set of starting parameters for SAEM

number_etas = size(chol_Gamma,1);

phiM = repmat(mean_phi,nchains,1);
itest_phi=1:size(phiM,1);

kt = 0;
while ~isempty(itest_phi)
    kt = kt + 1;
    if kt == 100 % TODOpax add a parameter for this constant.        
        error('stats:nlmefitsa:FailedInitialParameterGuess',...
              'Failed to find a valid initial parameter guess.');
    end
    
    n = length(itest_phi);
    etaMc = 0.5*myrandn(n,number_etas)*chol_Gamma;
    phiM(itest_phi,ind_eta) = bsxfun(@plus, phiM(itest_phi,ind_eta), etaMc);
    f = structural_model(phiM,XM,VM,errmod);
    
    inan = isnan(f) | isinf(f) | (imag(f)~=0);
    itest_phi = unique(IdM(inan));
end
end

% ----------------------------------
function [errmod,y] = update_error(errmod,y,sig2,f,alpha1_sa,stepsize,dampflag)
%UPDATE_ERROR Update error parameters for nonlinear mixed effects fit.
%   Error models are a + bf described by [a b]:
%      constant            y = f + a*e
%      proportional        y = f + b*f*e
%      combined            y = f + (a+b*f)*e
%      exponential         y = f*exp(a*e)    ( <=>  log(y) = log(f) + a*e )

if nargin==3 % initialize, sig2 = error parameters
    [errmod,y] = init_error_model(errmod,y,sig2);
    return
end

a = errmod.a;
b = errmod.b;

if (strcmp(errmod.type,'constant') || strcmp(errmod.type,'exponential'))
    a = sqrt(sig2);
elseif strcmp(errmod.type,'proportional')
    b = sqrt(sig2);
else  %%  errmod.type = 'combined'
    ab = fminsearch(@(x) error_ab(x,y,f),[a b]);
    if  ~dampflag
        a = max(a*alpha1_sa,ab(1));
        b = max(b*alpha1_sa,ab(2));
    else
        a = a+stepsize*(ab(1)-a);
        b = b+stepsize*(ab(2)-b);
    end
end

errmod.a = a;
errmod.b = b;
errmod.p = [a b];
end

% utility to compute likelihood terms for fminsearch
function e=error_ab(ab,y,f)
g=ab(1)+ab(2)*abs(f);
e=sum( 0.5*((y-f)./g).^2 + log(g) );
end

% utility to initialize error structure and transform the response
function [errmod,y] = init_error_model(error_model,y,params0)

% Check error model type
ok = {'constant','proportional','combined','exponential'};
i = find(strncmpi(error_model,ok,length(error_model)));
if ~isscalar(i)
    okstring = [sprintf('''%s'', ', ok{1:end-1}) 'and ''' ok{end} ''''];
    if isempty(i)
        error('stats:nlmefitsa:BadErrorModel',...
            'Bad ErrorModel parameter value. Valid values are %s.',okstring);
    else
        error('stats:nlmefitsa:AmbiguousErrorModel',...
            'Ambiguous ErrorModel parameter value. Valid values are %s.',okstring);
    end
end
error_model = ok{i};

% Check error model parameters
if ~isempty(params0)
    if ~isvector(params0) || all(params0<=0) || length(params0)>2
        error('stats:nlmefitsa:BadErrorParam',...
              'The ErrorParameters parameter must be a vector of length 1 or 2 containing a positive value.')
    end
    if i==3      % combined error model
        if length(params0)~=2
            error('stats:nlmefitsa:BadCombinedParam',...
                  'The ErrorParameters parameter for a ''%s'' error model must be a two-element vector.',...
                  error_model)
        end
    elseif i==2  % proportional error model
        if length(params0)==2 && params0(1)~=0
            error('stats:nlmefitsa:BadErrorParam1',...
                  'The ErrorParameters parameter for a ''%s'' error model must have a zero as its first element.',...
                  error_model)
        end
    else         % constant or exponential error model
        if length(params0)==2 && params0(2)~=0
            error('stats:nlmefitsa:BadErrorParam2',...
                  'The ErrorParameters parameter for a ''%s'' error model must have a zero as its second element.',...
                  error_model)
        end
    end
end

% Store error model parameters
if i==1     % constant,     y = f + a*e
    if isempty(params0)
        a = 1;
    else
        a = params0(1);
    end
    b = 0;
    p = a;
    indices = 1;
elseif i==2 % proportional, y = f + b*f*e
    if isempty(params0)
        b = .1;
    else
        b = params0(end);
    end
    a = 0;
    p = b;
    indices = 2;
elseif i==3 % combined,     y = f + (a+b*f)*e
    if isempty(params0)
        a = .1;
        b = .1;
    else
        a = params0(1);
        b = params0(2);
    end
    p = [a b];
    indices = 1:2;
else        % exponential,  y = f*exp(a*e), or log(y) = log(f) + a*e
    if isempty(params0)
        a = 1;
    else
        a = params0(1);
    end
    b = 0;
    p = a;
    y = log(max(y,realmin));
    indices = 1;
end

errmod.a = a;
errmod.b = b;
errmod.p = p;
errmod.type = error_model;
errmod.indices = indices;
end

% utility to create text to represent the error model parameters
function errtxt = errmod2text(errmod)

switch(errmod.type)
    case {'constant', 'exponential'}
        errtxt = sprintf('%13.5g',errmod.a);
    case 'proportional'
        errtxt = sprintf('%13.5g',errmod.b);
    case 'combined'
        errtxt = sprintf('(%.5g,%.5g)',errmod.a, errmod.b);
end
end

% ------------------------------------------
function [betas,Gamma,MCOV,mean_phi] = update_estimates(betas,Gamma,ind_eta,phiM,XM,VM,errmod,structural_model,...
    MCOV,LCOV,COV,COV1,COV2,flag_fmin,phase1,transition,idxFixedCoeffs,ind_fix11,ind_fix10,suffstat,...
    dstatphi,alpha0_sa,alpha1_sa,idxRandParams,indest_Gamma,Uargs,stepsize)
% Update parameter estimates during SAEM

statphi1 = suffstat.phi1;
statphi2 = suffstat.phi2;
diag_Gamma = diag(Gamma);
D1Gamma    = LCOV(:,ind_eta) / Gamma(ind_eta,ind_eta);
D2Gamma    = D1Gamma*LCOV(:,ind_eta)';
CGamma     = COV2.*D2Gamma;

% fixed effects
%         temp  = D1Gamma.*(COV'*suffstat.phi1);
%         betas = (CGamma \ sum(temp, 2))';
%         MCOV(j_covariate) = betas;
%         mean_phi = COV*MCOV;

if flag_fmin && (transition || ~phase1)
    temp  = D1Gamma(ind_fix11,:).*(COV1'*(statphi1-dstatphi(:,ind_eta)));
    betas(ind_fix11) = (CGamma(ind_fix11,ind_fix11) \ sum(temp, 2))';
    options_fmin = optimset('MaxIter',10,'Display','off');
    beta0=fminsearch(@(x) compute_Uy(x,phiM,XM,VM,errmod,structural_model,Uargs),betas(ind_fix10),options_fmin);
    betas(ind_fix10)=betas(ind_fix10)+stepsize*(beta0-betas(ind_fix10));
else
    temp  = D1Gamma(idxFixedCoeffs,:).*(COV1'*(statphi1-dstatphi(:,ind_eta)));
    betas(idxFixedCoeffs) = (CGamma(idxFixedCoeffs,idxFixedCoeffs) \ sum(temp, 2))';
end

MCOV = bsxfun(@times,LCOV,betas(:));
mean_phi = COV*MCOV;
e1_phi = mean_phi(:,ind_eta);

%  Covariance of the random effects
[NGroups,number_parameters] = size(mean_phi);
Gamma_full = zeros(number_parameters);
Gamma_full(ind_eta,ind_eta) = (1/NGroups) * ...
        (statphi2 + e1_phi'*e1_phi - statphi1'*e1_phi - e1_phi'*statphi1);
Gamma(indest_Gamma)=Gamma_full(indest_Gamma);

% Simulated annealing (applied to the diagonal elements of Gamma)
if phase1
    diag_Gamma_full=diag(Gamma_full);
    diag_Gamma(idxRandParams)=max(diag_Gamma_full(idxRandParams),diag_Gamma(idxRandParams)*alpha1_sa);
    diag_Gamma(~idxRandParams)=diag_Gamma(~idxRandParams)*alpha0_sa;
else
    diag_Gamma=diag(Gamma);
end

n = size(Gamma,1);
Gamma(1:n+1:end) = diag_Gamma;
end

% utility used in updating parameter estimates
function U=compute_Uy(beta0,phiM,XM,VM,errmod,structural_model,args)
args.MCOV0(args.j0_covariate) = beta0;
phi0 = args.COV0*args.MCOV0;
phiM(:,args.idxFixedParams) = repmat(phi0,args.nmc,1);
[f,g] = structural_model(phiM,XM,VM,errmod);
DYF(args.ind_ioM) = 0.5*((args.yM - f)./g).^2 + log(g);
U = sum(DYF(:));
end

% ----------------------------------------
function [suffstat,phi] = update_suffstat(y,f,errmod,phi,phiM,ind_eta,...
    stepsize,suffstat)
% Update sufficient statistics during SAEM

if nargin==0
    % Initialize structure
    suffstat.phi1 = 0;
    suffstat.phi2 = 0;
    suffstat.phi3 = 0;
    suffstat.rese = 0;
    return
end

[NGroups,~,nchains] = size(phi);
number_total_observations = length(y);
ff = reshape(f,number_total_observations, nchains);

for k=1:nchains
    phi(:,:,k)=phiM((k-1)*NGroups+1:k*NGroups,:);
end

Statphi1 = sum(phi(:,ind_eta,:),3);

Statphi2 = 0; % zeros(number_etas,number_etas);
for k=1:nchains
    phik=phi(:,ind_eta,k);
    Statphi2=Statphi2+phik'*phik;
end

Statphi3=sum(phi.^2,3);

Statrese=0;
if strcmp(errmod.type,'constant') || strcmp(errmod.type,'exponential')
    for k=1:nchains
        fk=ff(:,k);
        Statrese = Statrese + sum((y - fk).^2);
    end
elseif strcmp(errmod.type,'proportional')
    for k=1:nchains
        fk=ff(:,k);
        Statrese = Statrese + sum( ((y - fk).^2) ./ max(eps,(fk).^2) );
    end
end

% update the sufficient statistics
suffstat.phi1 = suffstat.phi1 + stepsize*(Statphi1/nchains-suffstat.phi1);
suffstat.phi2 = suffstat.phi2 + stepsize*(Statphi2/nchains-suffstat.phi2);
suffstat.phi3 = suffstat.phi3 + stepsize*(Statphi3/nchains-suffstat.phi3);
suffstat.rese = suffstat.rese + stepsize*(Statrese/nchains-suffstat.rese);
end
