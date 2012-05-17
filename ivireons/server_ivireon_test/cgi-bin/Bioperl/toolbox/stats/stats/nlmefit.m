function [Beta_hat,Psi_hat,stats,b_hat] = nlmefit(X,Y,grp,V,f,Beta_0,varargin)
%NLMEFIT Nonlinear mixed-effects estimation.
%   BETA = NLMEFIT(X,Y,GROUP,V,MODELFUN,BETA0) fits a nonlinear
%   mixed-effects regression model and returns estimates of the fixed
%   effects in BETA. By default, NLMEFIT fits a model where each model
%   parameter is the sum of a corresponding fixed and random effect, and
%   the covariance matrix of the random effects is diagonal, i.e.,
%   uncorrelated random effects.
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
%   with input arguments
%
%      PHI    A 1-by-P vector of model parameters.
%      XFUN   An L-by-H array of predictor variables where L is 1 if XFUN is a
%             single row of X, NI if XFUN contains the rows of X for a single
%             group of size NI, or N if XFUN contains all rows of X.
%      VFUN   Either a 1-by-G vector of group-specific predictors for a single
%             group, corresponding to a single row of V; or an N-by-G matrix,
%             where if the K-th observation is in group I, then the K-th row
%             of VFUN is V(I,:). If V is empty, NLMEFIT calls MODELFUN with
%             only two inputs.
%
%   and returning an L-by-1 vector of fitted values YFIT. When either PHI or
%   VFUN contains a single row, that one row corresponds to all rows in the
%   other two input arguments. Note: for improved performance, use the
%   'Vectorization' parameter name/value pair (described below) if MODELFUN
%   can compute YFIT for more than one vector of model parameters in one call.
%
%   BETA0 is a F-by-1 vector with initial estimates for the F fixed effects.
%   By default, F is equal to the number of model parameters P.
%
%   NLMEFIT fits the model by maximizing an approximation to the marginal
%   likelihood, i.e., with the random effects integrated out, and assumes
%   that:
%      a) the random effects are multivariate normally distributed, and
%         independent between groups, and
%      b) the observation errors are independent, identically normally
%         distributed, and independent of the random effects. (However,
%         this assumption is changed by the ErrorModel parameter.)
%
%   [BETA,PSI] = NLMEFIT(...) returns PSI, an R-by-R estimated covariance
%   matrix for the random effects. By default, R is equal to the number of
%   model parameters P.
%
%   [BETA,PSI,STATS] = NLMEFIT(...) returns STATS, a structure with fields:
%       logl        The maximized log-likelihood for the fitted model
%       rmse        The root mean squared residual (computed on the log
%                   scale for the 'exponential' error model)
%       errorparam  The estimated parameters of the error variance model
%       aic         The Akaike information criterion
%       bic         The Bayesian information criterion
%       sebeta      The standard errors for BETA
%       dfe         The error degrees of freedom
%
%   [BETA,PSI,STATS,B] = NLMEFIT(...) returns B, an R-by-M matrix of estimated
%   random effects for the M groups. By default, R is equal to the number of
%   model parameters P.
%
%   [...] = NLMEFIT(X,Y,GROUP,V,FUN,BETA0,'param1',val1,...) specifies
%   additional parameter name/value pairs that allow you to define the model
%   and control the estimation algorithm, as described below.
%
%   By default, NLMEFIT fits a model where each model parameter is the sum of
%   a corresponding fixed and random effect. Use the following parameter
%   name/value pairs to fit a model with a different number of or dependence
%   on fixed or random effects. Use at most one parameter name with an 'FE'
%   prefix and one parameter name with an 'RE' prefix. Note that some choices
%   change the way NLMEFIT calls MODELFUN, as described further below.
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
%       'FEObsDesign'    A P-by-F-by-N array specifying a different P-by-F
%                        fixed effects design matrix for each of the N
%                        observations.
%
%       'REParamsSelect' A vector specifying which elements of the model
%                        parameter vector PHI include a random effect, as a
%                        numeric vector with elements in 1:P, or as a 1-by-P
%                        logical vector.  The model will include R random
%                        effects, where R is the specified number of elements.
%       'REConstDesign'  A P-by-R design matrix BDESIGN, where BDESIGN*B are
%                        the random components of the P elements of PHI.
%       'REGroupDesign'  A P-by-R-by-M array specifying a different P-by-R
%                        random effects design matrix for each of M groups.
%       'REObsDesign'    A P-by-R-by-N array specifying a different P-by-R
%                        random effects design matrix for each of N
%                        observations.
%
%   The default model is equivalent to setting both 'FEConstDesign' and
%   'REConstDesign' to EYE(P), or to setting both 'FEParamsSelect' and
%   'REParamsSelect' to 1:P.
%
%   Additional optional parameter name/value pairs control the iterative
%   algorithm used to maximize the likelihood:
%
%       'ApproximationType' The method used to approximate the non-linear
%                           mixed effects model likelihood:
%              'LME'    Use the likelihood for the linear mixed-effects
%                       model at the current conditional estimates of BETA
%                       and B. This is the default.
%              'RELME'  Use the restricted likelihood for the linear
%                       mixed-effects model at the current conditional
%                       estimates of BETA and B.
%              'FO'     First order (Laplacian) approximation without
%                       random effects.
%              'FOCE'   First order (Laplacian) approximation at the
%                       conditional estimates of B.
%
%       'CovParameterization'  Specifies the parameterization used
%                              internally for the scaled covariance matrix
%                              (PSI/sigma^2). 'chol' for the Cholesky
%                              factorization, or 'logm' (the default) for
%                              the Cholesky factorization of the matrix
%                              logarithm. 
%
%       'CovPattern'         Specifies an R-by-R logical or numeric matrix
%                            PAT that defines the pattern of the random
%                            effects covariance matrix PSI. NLMEFIT
%                            computes estimates for the variances along the
%                            diagonal of PSI as well as covariances that
%                            correspond to non-zeroes in the off-diagonal
%                            of PAT.  NLMEFIT constrains the remaining
%                            covariances, i.e., those corresponding to
%                            off-diagonal zeroes in PAT, to be zero. PAT
%                            must be a row-column permutation of a block
%                            diagonal matrix, and NLMEFIT adds non-zero
%                            elements to PAT as needed to produce such a
%                            pattern. The default value of PAT is EYE(R),
%                            corresponding to uncorrelated random effects.
%
%                            Alternatively, specify PAT as a 1-by-R vector
%                            containing values in 1:R. In this case,
%                            elements of PAT with equal values define
%                            groups of random effects, NLMEFIT estimates
%                            covariances only within groups, and constrains
%                            covariances across groups to be zero.
%
%       'OptimFun'  Either 'fminsearch' or 'fminunc', specifying the
%                   optimization function to be used in maximizing the
%                   likelihood.  Default is 'fminsearch'.  You may only
%                   specify 'fminunc' if Optimization Toolbox is available.
%
%       'Options'  A structure created by a call to STATSET. NLMEFIT uses the
%                  following STATSET parameters:
%            'TolX'         Termination tolerance on the estimated fixed
%                           and random effects. Default 1e-4.
%            'TolFun'       Termination tolerance on the log-likelihood
%                           function. Default 1e-4.
%            'MaxIter'      Maximum number of iterations allowed. Default 200.
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
%                           (default). NLMEFIT calls all output functions
%                           after each iteration. See NLMEFITOUTPUTFCN for
%                           an example of an output function.
%
%       'ParamTransform' A vector of P values specifying a transformation
%                        function f() for each of the P parameters:
%                            XB = ADESIGN*BETA + BDESIGN*B
%                            PHI = f(XB)
%                        Each element of the vector must be one of the
%                        following integer codes specifying the
%                        transformation for the corresponding value of PHI:
%                             0: PHI = XB  (default for all parameters)
%                             1: log(PHI) = XB
%                             2: probit(PHI) = XB
%                             3: logit(PHI) = XB
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
%       'RefineBeta0'  Determines whether NLMEFIT will make an initial
%                      refinement of BETA0 by fitting the model defined by
%                      MODELFUN without random effects. Default is 'on'.
%
%       'Vectorization'  Determines the possible sizes of the PHI, XFUN,
%                        and VFUN input arguments to MODELFUN.  Possible
%                        values are:
%             'SinglePhi'    MODELFUN is a function (such as an ODE solver)
%                            that can only compute YFIT for a single set of
%                            model parameters at a time, i.e., PHI must be
%                            a single row vector in each call. NLMEFIT
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
%                        all cases, if V is empty, NLMEFIT calls MODELFUN
%                        with only two inputs.
%
%   Example:
%      % Fit a model to data on concentrations of the drug indomethacin in
%      % the bloodstream of six subjects over eight hours
%      load indomethacin
%      model = @(phi,t)(phi(:,1).*exp(-phi(:,2).*t) + phi(:,3).*exp(-phi(:,4).*t));      
%      phi0 = [1 1 1 1];
%      xform = [0 1 0 1]; % log transform for 2nd and 4th parameters
%      [beta,PSI,stats,br] = nlmefit(time,concentration,subject,[],...
%                                    model,phi0, 'ParamTransform',xform);
% 
%      % Plot the data along with an overall "population" fit
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
%   See also NLINFIT, NLMEFITOUTPUTFCN, NLMEFITSA, GROUPINGVARIABLE.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/05/10 17:59:00 $

%   NLMEFIT calls MODELFUN with PHI, XFUN, and VFUN having the following sizes
%   under the following conditions:
%
%   1a. If 'Vectorization' is 'SinglePhi', and neither 'REObsDesign' nor
%       'FEObsDesign' is specified, NLMEFIT calls MODELFUN once for each group
%       of observations:
%           PHI is 1-by-P, XFUN is NI-by-H, VFUN is 1-by-G
%       where NI is the number of observations in the I-th group.
%
%   1b. If 'Vectorization' is 'SinglePhi', and 'REObsDesign' or 'FEObsDesign'
%       is specified, NLMEFIT calls MODELFUN separately for each observation:
%           PHI is 1-by-P, XFUN is 1-by-H, VFUN is 1-by-G
%
%   2.  If 'Vectorization' is 'SingleGroup', NMLMEFIT calls MODELFUN once for
%       each group of observations:
%           PHI is 1-by-P or NI-by-P, XFUN is NI-by-H, VFUN is 1-by-G
%       where NI is the number of observations in the I-th group, and PHI's
%       size depends on whether or not 'REObsDesign' or 'FEObsDesign' is
%       specified.
%
%   3.  If 'Vectorization' is 'Full', NLMEFIT may call MODELFUN in one of two
%       ways.  First, once for each group of observations:
%           PHI is 1-by-P or NI-by-P, XFUN is NI-by-H, VFUN is 1-by-G
%       where NI is the number of observations in the I-th group, and PHI's
%       size depends on whether or not 'REObsDesign' or 'FEObsDesign' is
%       specified.  Second, once for all observations:
%           PHI is N-by-P, XFUN is N-by-H, VFUN is N-by-G
%       where if the K-th observation is in group I, then the K-th row of PHI
%       is the vector of model parameters that contains random effects for
%       group I. Similarly, VFUN is an expanded version of V, so that if the
%       K-th observation is in group I, the K-th row of VFUN is V(I,:).
%
%   4.  If 'Vectorization' is 'SinglePhi' or 'Full', NLMEFIT also calls
%       MODELFUN under some circumstances with all observations:
%           PHI is 1-by-P, XFUN is N-by-H, VFUN is N-by-G
%       NLMEFIT calls MODELFUN this way when fitting without random effects in
%       the initial refinement of BETA0 when 'RefineBeta0' is 'on', or when
%       computing the first-order approximation of the likelihood, i.e., when
%       'ApproximationType' is 'FO'.  VFUN is an expanded version of V, so
%       that if the K-th observation is in group I, the K-th row of VFUN is
%       V(I,:).
%
%   In all cases, if V is empty, NMLEFIT calls MODELFUN with only two input
%   arguments.  MODELFUN must return YFIT with length corresponding to the
%   number of rows in XFUN.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get and validate mandatory inputs
[N,NP] = size(X);   % N -> number of observations,   NP -> number of predictors in X
if N<2 || NP==0
    error('stats:nlmefit:invalidX','X must have N rows and at least one column.')
end
X = double(X);
if (size(Y,1)~=N) || (size(Y,2)~=1)
    error('stats:nlmefit:ivalidY','Y must be a column vector with the same number of rows as X, which is the number of observations (N).')
end
Y = double(Y);
if any(isnan(Y)) || any(isnan(X(:)))
    error('stats:nlmefit:noSupportNaNs','NLMEFIT does not support inputs with NaNs.')
end
[grp,GN] = grp2idx(grp);
M = numel(GN);      % M -> number of groups
if M<2
    error('stats:nlmefit:oneGROUP','At least two groups must exist. GROUP does not have enough unique values.')
end
if (size(grp,1)~=N) || (size(grp,2)~=1)
    error('stats:nlmefit:invalidGROUP','GROUP must be a column vector with the same number of rows as X, which is the number of observations (N).')
end
if isempty(V)
    V = zeros(M,0);
elseif size(V,1)~=M
    error('stats:nlmefit:invalidV','V must have the same number of rows as the number of unique values in GROUP, which is the number of groups (M).')
end
if ~isa(f,'function_handle')
    error('stats:nlmefit:invalidFUN','FUN is not a function handle class.')
end
if ~isvector(Beta_0)
    error('stats:nlmefit:invalidBETA0','Initial values for the fixed effects BETA0 must be a column vector.')
end
Beta_0 = Beta_0(:);
q = numel(Beta_0);    % q -> fixed effects (size of Beta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse optional parameter name-value pair input arguments
[~,r,A,B,patternCov,dofCov,refineBeta0,ApproximationType,...
    modelFunVec,parType,Options,minMethod,outputFcn,...
    paramTransform,errorModel] = ...
                        parseInVarargin(q,M,N,varargin{:});
errorModelNumParam = 1 + (errorModel==3);                    
numParam = dofCov+q+errorModelNumParam;
haveOutputFcn = ~isempty(outputFcn);
stop = false;

if errorModel == 4 %Exponential , y = f*exp(a*e), or log(y) = log(f) + a*e
    if ~all(Y>0)
         error('stats:nlmefit:PositiveYRequired',...
             'The response variable Y must contain all positive values when the exponential error model is selected.')
    else
         Y = log(max(Y,realmin));
    end
end

% The first iteration of the Alternating Algorithm (or the Laplace
% approximation algorithm in case alternatingMethod==false) assumes a
% constant variance error model:
weights = ones(N,1);

% Extracting algorithm parameters from STATSET structure
tolF = max(Options.TolFun,sqrt(eps(X(1))));
tolX = max(Options.TolX,sqrt(eps(Beta_0(1))));
maxIter = Options.MaxIter;
switch Options.Display
    case 'none',   verbose = 0;
    case 'off',    verbose = 0;
    case 'final',  verbose = 2;
    case 'iter',   verbose = 3;
    case 'on',     verbose = 3;
    otherwise,     verbose = 0;
end

switch ApproximationType
    case 'LME'
        alternatingMethod = true;
        restricted = false;
        laplacianMethod = false;
        foceMethod = false;
    case 'RELME'
        alternatingMethod = true;
        restricted = true;
        laplacianMethod = false;
        foceMethod = false;
    case 'FO'
        alternatingMethod = true;
        restricted = false;
        laplacianMethod = true;
        foceMethod = false;
    case 'FOCE'
        alternatingMethod = true;
        restricted = false;
        laplacianMethod = true;
        foceMethod = true;
end

%Options not documented and not supported
DeltaInitFrac = 0.375;
funValCheckInMin = 'off';
errorModelParam = [1 1];

% Burn-in persistent data into the MODELFUN caller
if errorModel == 4 %Exponential , y = f*exp(a*e), or log(y) = log(f) + a*e
    if isempty(V)
        compute_f([],[],X,V,A,B,@(ia1,ia2) log(max(f(ia1,ia2),realmin)),grp,modelFunVec,paramTransform)
        compute_fi([],[],[],X,V,A,B,@(ia1,ia2) log(max(f(ia1,ia2),realmin)),grp,modelFunVec,paramTransform)
    else
        compute_f([],[],X,V,A,B,@(ia1,ia2,ia3) log(max(f(ia1,ia2,ia3),realmin)),grp,modelFunVec,paramTransform)
        compute_fi([],[],[],X,V,A,B,@(ia1,ia2,ia3) log(max(f(ia1,ia2,ia3),realmin)),grp,modelFunVec,paramTransform)
    end
else
    compute_f([],[],X,V,A,B,f,grp,modelFunVec,paramTransform)
    compute_fi([],[],[],X,V,A,B,f,grp,modelFunVec,paramTransform)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refine the values of Beta without random effects
Beta_hat = Beta_0;
if refineBeta0
    if verbose>2
        disp('Non-linear fitting estimate without random effects:')
        dispVal('Beta_0''',Beta_hat')
        t = cputime;
    end

    LMfitOptions = struct('TolFun',tolF,'TolX',tolX,'FunValCheck',Options.FunValCheck,'MaxIter',maxIter*q);

    Beta_hat = LMfit([],Y,@(Beta,dummy) compute_f(Beta,zeros(r,M)),Beta_hat,LMfitOptions);

    if verbose>2
        dispVal('Beta_hat''',Beta_hat')
        fprintf('     %d model evaluations in %f seconds.\n',compute_f([]),cputime-t)
    end
else
    if verbose>2
        disp('Non-linear fitting estimate without random effects: OFF')
        disp(' ')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Safe initialization of random effects, get safe initial value for Delta
% (Bates&Pinheiro 1998, page 12)
if verbose>2
    disp('Initialize random effects:')
end
t = cputime;
b_hat = zeros(r,M);
fBetab = compute_f(Beta_hat,b_hat);

delta = sqrt(eps(max(abs(Beta_hat))));
Zw = zeros(N,r);
for j = 1:r
    bpdelta = b_hat;
    bpdelta(j,:) = bpdelta(j,:)+delta;
    Zw(:,j) = (compute_f(Beta_hat,bpdelta)-fBetab)./delta;
end

% Get safe initial value for Delta (Bates&Pinheiro 1998, page 12)
Delta = diag(DeltaInitFrac*sqrt(sum(Zw.^2,1)/M));
theta_hat = Delta2theta(Delta,r,parType,patternCov);

if verbose>2
    dispVal('Delta_0',Delta)
    dispVal('theta_0''',theta_hat')
    fprintf('     %d model evaluations in %f seconds.\n',compute_f([]),cputime-t)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate by the Alternating algorithm (Pinheiro&Bates, page 313)

if alternatingMethod
    
    % take initial values from last estimation or input guesses
    Beta = Beta_hat;
    b = b_hat;
    theta = theta_hat;
    Delta = theta2Delta(theta,r,parType,patternCov);
    if verbose>2
        if restricted
            disp('Alternating algorithm estimate (Restricted):')
        else
            disp('Alternating algorithm estimate (Non-restricted):')
        end
        dispVal('Beta_0''',Beta')
        dispVal('Delta_0',Delta)
        dispVal('theta_0''',theta')
    end
    
    t = cputime;

    % Algorithm constants
    tolFac = 2;

    PNLSOpt = struct('TolFun',tolF*(10^tolFac),'TolX',tolX*(10^tolFac),...
                     'FunValCheck',Options.FunValCheck,...
                     'MaxIter',(r*M+q)*maxIter,'OutputFcn',[]);

    switch minMethod
        case 'fminsearch'
            minMethodIsFminunc = false;
            minMethodIsFminsearch = true;
            minMethodOpt = optimset(optimset('fminsearch'),...
                'TolFun',tolF*(10^tolFac),...
                'TolX',tolX*(10^tolFac),...
                'MaxFunEvals',inf,...
                'MaxIter',(dofCov+q)*maxIter,...
                'FunValCheck',funValCheckInMin,...
                'Display','none',...
                'OutputFcn',[]);
        case 'fminunc' % needs Optimization Toolbox
            minMethodIsFminunc = true;
            minMethodIsFminsearch = false;
            minMethodOpt = optimset(optimset('fminunc'),...
                'TolFun',tolF*(10^tolFac),...
                'TolX',tolX*(10^tolFac),...
                'MaxFunEvals',inf,...
                'MaxIter',(dofCov+q)*maxIter,...
                'FunValCheck',funValCheckInMin,...
                'Display','none',...
                'LargeScale','off',...
                'OutputFcn',[]);
        otherwise % use only EM
            minMethodIsFminunc = false;
            minMethodIsFminsearch = false;
    end

    % Precalculate the constant part of the loglikelihood
    if restricted
        Klike = (log(N-q)-log(2*pi)-1)*(N-q)/2; % constant part of the loglikelihood 
    else
        Klike = (log(N)-log(2*pi)-1)*N/2; % constant part of the loglikelihood
    end
    if errorModel==4
        Klike = Klike - sum(Y);
    end
    
    % Reset all persistent variables inside LMEnegloglikelihood
    LMEnegloglikelihood([],[],[],r,q,M,N,grp,restricted,parType,patternCov);

    nIter = 0;
    nlALT = inf;
    sigma2_hat = NaN;
    llike = NaN;

    if haveOutputFcn
        ofopt = struct('procedure','ALT','iteration',nIter,'inner',...
                   struct('procedure','none','state','none','iteration',NaN),...
                   'fval',llike,'Psi', Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                   'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
        stop = callOutputFcns(outputFcn,Beta,ofopt,'init');
    end
    
    if ~stop
    while nIter < maxIter % Alternating algorithm (Pinheiro&Bates, page 313)
        nIter = nIter+1;
        % PNLS step: The precision factor (Delta) is fixed, find the
        % conditional modes of the random effects (b) and the conditional
        % estimates of the fixed effects (Beta) by minimizing a penalized
        % non-linear least squares objective function:
        
        if haveOutputFcn
            ofopt = struct('procedure','ALT','iteration',nIter-1,'inner',struct,...
                           'fval',llike,'Psi',Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                           'theta',theta,'mse',sigma2_hat,'caller','nlmefit');           
            PNLSOpt.OutputFcn = @(Beta,inneriter,innerstate) pnlsOutputFcn(outputFcn,Beta,ofopt,inneriter,innerstate);
        end
        
        [BetaNew,bNew,stop] = GNfitPNLS(Delta,Y,Beta,b,weights,PNLSOpt,grp,M,N,r,q);      
               
        MaxBetabDiff = max(max(abs(BetaNew - Beta)),max(abs(bNew(:)-b(:))));
        Beta = BetaNew;
        b = bNew;
           
        % LME step: Updates the estimate of the precision factor (Delta) by
        % linearizing around the conditional modes of the random effects (b)
        % and the conditional estimates of the fixed effects (Beta):

        % LINEARIZATION: (Eq.(7.11) Pinheiro&Bates, page 313) (all groups at
        % once), new linear model is: ww_i = Xw_i Beta + Zw_i b_i + e_i
        fBetab = compute_f(Beta,b);
        delta1 = (sign(b)+(b==0)).*max(1,abs(b))*sqrt(sqrt(eps));
        Zw = zeros(N,r);
        for j = 1:r
            bpdelta = b;
            bpdelta(j,:) = bpdelta(j,:)+delta1(j,:);
            Zw(:,j) = (compute_f(Beta,bpdelta)-fBetab)./delta1(j,grp)';
        end
        delta2 = (sign(Beta)+(Beta==0)).*max(1,abs(Beta))*sqrt(sqrt(eps));
        Xw = zeros(N,q); % n_i X number of parameters
        for j = 1:q
            Betapdelta = Beta;
            Betapdelta(j) = Betapdelta(j) + delta2(j);
            Xw(:,j) = (compute_f(Betapdelta,b)-fBetab)./delta2(j);
        end
        ww = Y-fBetab+Xw*Beta+sum(Zw.*b(:,grp)',2);
        Xwww = [Xw ww];
        
        % The derivative matrices and working vector are weighted by the error
        % model:
        Xwww = bsxfun(@times,weights,Xwww);
        Zw = bsxfun(@times,weights,Zw);

        % Minimize the negative profiled loglikelihood of the LME model
        % (Eqs. (2.20 or 2.23) Pinheiro&Bates, pp 71-76):
        % Reset persistent values for Zw and Xwww inside LMEnegloglikelihood
        LMEnegloglikelihood([],Zw,Xwww);

       
        if haveOutputFcn
            if stop
                break;
            end
            ofopt = struct('procedure','ALT','iteration',nIter-1,'inner',struct,...
                           'fval',llike,'Psi',Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                           'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
            minMethodOpt.OutputFcn = @(optimX,optimStruc,optimState) lmeOutputFcn(optimX,optimStruc,optimState,outputFcn,ofopt,Beta,Klike);
        end
        
        if minMethodIsFminsearch
            [theta_hat,nlLME,exitFlag] = fminsearch(@LMEnegloglikelihood,theta,minMethodOpt);
        elseif minMethodIsFminunc
            [theta_hat,nlLME,exitFlag] = fminunc(@LMEnegloglikelihood,theta,minMethodOpt);
        end

        if haveOutputFcn && exitFlag==-1
            stop = true;
            break;
        elseif exitFlag==0 
            warning('stats:nlmefit:IterationLimitExceededLME', ...
                'Iteration limit exceeded while solving the LME model. Continuing with the results from final iteration.');
        end

        % Update weights
        switch errorModel
            case 1 % 'constant'
                % weights = ones(N,1);
            case 2 % 'proportional'
                weights = 1./abs(fBetab);
                weights(isinf(weights)) = 1;
            case 3 % 'combined'
                ab = fminsearch(@(ab) error_ab(ab,Y,fBetab),errorModelParam);
                weights = 1./abs(ab(1)+ab(2)*fBetab);
                weights(isinf(weights)) = 1;
                errorModelParam = ab;
            case 4 % 'exponential'
                % weights = ones(N,1);
        end      
        
        theta = theta_hat;
        Delta = theta2Delta(theta,r,parType,patternCov);

        nlALTDiff = abs(nlALT-nlLME);
        nlALT = nlLME;

        if haveOutputFcn % call outer level iteration outputFcn
            [nlLME,c_1]= LMEnegloglikelihood(theta);
            llike = Klike - nlLME; % constant part of the loglikelihood + lALT
            sigma2_hat = (c_1.^2)/N;
            ofopt = struct('procedure','ALT','iteration',nIter-1,'inner',...
                           struct('procedure','none','state','none','iteration',NaN),...
                           'fval',llike,'Psi', Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                           'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
            stop = callOutputFcns(outputFcn,Beta,ofopt,'iter');
            if stop, break; end
        end
        
        % Check output conditions for the Alternating algorithm
        if nlALTDiff <= tolF*(10.^tolFac) &&  MaxBetabDiff<= tolX*(10.^tolFac)
            if tolFac <= 0
                break
            else
                tolFac = tolFac - 1;
                LMEminMethodOpt.TolFun = tolF*(10.^tolFac);
                LMEminMethodOpt.TolX = tolX*(10.^tolFac);
                PNLSOpt.TolFun = tolF*(10.^tolFac);
                PNLSOpt.TolX = tolX*(10.^tolFac);
            end
        end
        
    end
    end

    if nIter>=maxIter
        warning('stats:nlmefit:IterationLimitExceeded',...
            'Iteration limit exceeded in the Alternating algorithm. Returning results from final iteration.');
    end
    
    [nlLME,c_1,R00]= LMEnegloglikelihood(theta);
    llike = Klike - nlLME; % constant part of the loglikelihood + lALT
    llike = llike + sum(log(weights));  % including error model weights into ll 

    Beta_hat = Beta;                    % use Beta computed in the PNLS step
    b_hat = b;                          % use b computed in the PNLS step
    Psi_sigma2 = Delta2Psi_sigma2(Delta,r);  % use Delta computed in the LME step

    sigma2_hat = (c_1.^2)/N;            % use sigma computed in the LME step
    Psi_hat = Psi_sigma2 * sigma2_hat;
    theta_hat = theta;
    Delta_hat = Delta;
    if (verbose>2) || (~laplacianMethod&&verbose)
        dispVal('Beta_hat''',Beta_hat')
        dispVal('theta_hat''',theta_hat')
        dispVal('logLike',llike)
        dispVal('sigma2_hat',sigma2_hat)
        dispVal('Psi_hat',Psi_hat,'%9.6f')
        dispVal('Delta_hat',Delta_hat,'%9.6f')
        dispVal('Deg.Freedom',numParam,'%d')
        dispVal('AIC',-2*llike+2*numParam)
        dispVal('BIC',-2*llike+log(M-q*restricted)*numParam)
        fprintf('     %d iterations and %d model evaluations in %f seconds.\n',nIter,compute_f([]),cputime-t)
         % Optional values that the user may want to display (when debugging)
         % dispVal('b_hat''',b_hat','%6.3f')
         % dispVal('log(sigma2_hat)',log(sigma2_hat))
         % dispVal('log(diag(L))',log(diag(chol(Psi_hat./sigma2_hat)))')
         % dispVal('triu(L,1)',nonzeros(triu(chol(Psi_hat./sigma2_hat),1))')
         % disp(' ')
    end
    
else
    nIter = 0;
    if verbose>2
        disp('Alternating algorithm estimate: OFF')
        disp(' ')
    end
end

ALTniter = nIter;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate by the Laplace approximation algorithm

if laplacianMethod && ~(haveOutputFcn && stop)

    Beta = Beta_hat;
    b = b_hat;
    theta = theta_hat;
    Delta = theta2Delta(theta,r,parType,patternCov);

    % Algorithm constants
    tolFac = 2;

    if verbose>2
        disp('Laplacian Approximation:')
        dispVal('Beta_0''',Beta')
        dispVal('Delta_0',Delta)
        dispVal('theta_0''',theta')
    end
    t = cputime;

    GPNLSOpt = struct('TolFun',tolF*(10^tolFac),'TolX',tolX*(10^tolFac),...
        'FunValCheck',Options.FunValCheck,'MaxIter',r*maxIter,...
        'OutputFcn',[]);
                 
    switch minMethod
        case 'fminsearch'
            LAminMethodIsFminunc = false;
            LAminMethodIsFminsearch = true;
            LAminMethodOpt = optimset(optimset('fminsearch'),...
                'TolFun',tolF*(10^tolFac),'TolX',tolX*(10^tolFac),...
                'MaxFunEvals',inf,'MaxIter',(dofCov+q)*maxIter,...
                'FunValCheck',funValCheckInMin,'Display','none',...
                'OutputFcn',[]);
        case 'fminunc' %needs Optimization Toolbox
            LAminMethodIsFminunc = true;
            LAminMethodIsFminsearch = false;
            LAminMethodOpt = optimset(optimset('fminunc'),...
                'TolFun',tolF*(10^tolFac),'TolX',tolX*(10^tolFac),...
                'MaxFunEvals',inf,'MaxIter',(dofCov+q)*maxIter,...
                'FunValCheck',funValCheckInMin,'Display','none',...
                'OutputFcn',[],'LargeScale','off');
    end

    % Precalculate the constant part of the loglikelihood
    Klike = -N/2 * (1+log(2*pi));
    if errorModel==4
        Klike = Klike - sum(Y);
    end
    
    % Reset all persistent variables inside LAnegloglikelihood
    LAnegloglikelihood([],[],[],Y,grp,q,r,dofCov,M,N,parType,patternCov);

    nIter = 0;
    nlLA = inf;
    sigma2_hat = NaN;
    llike = Klike - nlLA;
 
    if ~stop
    while nIter < maxIter % Laplacian approximation (Pinheiro&Bates, page 315)
        nIter = nIter+1;

        % PNLS step: The precision factor (Delta) and the conditional
        % estimates of the fixed effects (Beta) are fixed, find the conditional
        % modes of the random effects (b) by minimizing M penalized
        % non-linear least squares objective functions:
              
        bNew = zeros(r,M);
        if foceMethod

            if haveOutputFcn % call outer level iteration outputFcn
                ofopt = struct('procedure','LAP','iteration',ALTniter+nIter-1,'inner',...
                    struct('procedure','PNLS','state','init','iteration',0),...
                    'fval',llike,'Psi', Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                    'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
                stop = callOutputFcns(outputFcn,Beta,ofopt,'iter');
                if stop, break; end
            end
            
            for i = 1:M
                bNew(:,i) = GNfitGPNLS(Delta,Y(grp==i),weights(grp==i),Beta,b(:,i),GPNLSOpt,i,r);
            end
            
            if haveOutputFcn % call outer level iteration outputFcn
                ofopt = struct('procedure','LAP','iteration',ALTniter+nIter-1,'inner',...
                    struct('procedure','PNLS','state','done','iteration',M),...
                    'fval',llike,'Psi', Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                    'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
                stop = callOutputFcns(outputFcn,Beta,ofopt,'iter');
                if stop, break; end
            end
        end
        MaxbDiff = max(abs(bNew(:)-b(:)));
        b = bNew;

        % Maximize Likelihood Approximation step: The random effects (b) are
        % fixed. Find the estimates of the fixed effects (Beta) and the
        % precision factor (Delta) by minimizing the negative profiled
        % loglikelihood of the Laplacian approximation profiled on sigma2 given
        % by Eq.(7.19) in Pinheiro&Bates (page 319).
        LAnegloglikelihood([],b,weights);

        params0 = [Beta;theta];

        
        if haveOutputFcn
            ofopt = struct('procedure','LAP','iteration',ALTniter+nIter-1,'inner',struct,...
                           'fval',llike,'Psi',Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                           'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
            LAminMethodOpt.OutputFcn = @(optimX,optimStruc,optimState) plmOutputFcn(optimX,optimStruc,optimState,outputFcn,ofopt,Klike,q);
        end
        
        if LAminMethodIsFminsearch
            [params_hat,nlLAnew,exitFlag] = fminsearch(@LAnegloglikelihood,params0,LAminMethodOpt);
        elseif LAminMethodIsFminunc
            [params_hat,nlLAnew,exitFlag] = fminunc(@LAnegloglikelihood,params0,LAminMethodOpt);
        end
        
        if haveOutputFcn && exitFlag==-1 
            stop = true;
            break;
        elseif exitFlag==0 
            warning('stats:nlmefit:IterationLimitExceededLA',...
                'Iteration limit exceeded while solving the Laplacian approximation. Continuing with the results from final iteration.');
        end
        
        MaxBetaDiff = max(abs(Beta-params_hat(1:q)));
        MaxBetabDiff = max(MaxBetaDiff,MaxbDiff);
        Beta = params_hat(1:q);
        theta = params_hat(q+1:q+dofCov);
        Delta = theta2Delta(theta,r,parType,patternCov);

        nlLADiff = abs(nlLAnew-nlLA);
        nlLA = nlLAnew;
        
        % Update weights
        switch errorModel
            case 1 % 'constant'
                % weights = ones(N,1);
            case 2 % 'proportional'
                fBetab = compute_f(Beta,b);
                weights = 1./abs(fBetab);
                weights(isinf(weights)) = 1;
            case 3 % 'combined'
                fBetab = compute_f(Beta,b);
                ab = fminsearch(@(ab) error_ab(ab,Y,fBetab),errorModelParam);
                weights = 1./abs(ab(1)+ab(2)*fBetab);
                weights(isinf(weights)) = 1;
                errorModelParam = ab;
            case 4 % 'exponential'
                % weights = ones(N,1);
        end 
        
        if haveOutputFcn % call outer level iteration outputFcn
            [nlLA,sigma2_hat] = LAnegloglikelihood([Beta;theta]);
            llike = Klike - nlLA; % constant part of the loglikelihood + llLA
            ofopt = struct('procedure','LAP','iteration',ALTniter+nIter-1,'inner',...
                struct('procedure','none','state','none','iteration',NaN),...
                'fval',llike,'Psi', Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
            stop = callOutputFcns(outputFcn,Beta,ofopt,'iter');
            if stop, break; end
        end
        
        % Check output conditions for the iterative algorithm
        if nlLADiff <= tolF*(10.^tolFac) &&  MaxBetabDiff<= tolX*(10.^tolFac)
            if tolFac <= 0
                break
            else
                tolFac = tolFac - 0.2;
                LAminMethodOpt.TolFun = tolF*(10.^tolFac);
                LAminMethodOpt.TolX = tolX*(10.^tolFac);
                GPNLSOpt.TolFun = tolF*(10.^tolFac);
                GPNLSOpt.TolX = tolX*(10.^tolFac);
            end
        end
    end
    end
    
    
    if nIter>=maxIter
        warning('stats:nlmefit:IterationLimitExceeded',...
            'Iteration limit exceeded in the Laplacian algorithm. Returning results from final iteration.');
    end

    Beta_hat = Beta;
    theta_hat = theta;
    Delta_hat = Delta;
    
    for i = 1:M
        b(:,i) = GNfitGPNLS(Delta,Y(grp==i),weights(grp==i),Beta,b(:,i),GPNLSOpt,i,r);
    end
    b_hat = b;

    % Calculate remaining output values
    LAnegloglikelihood([],b,weights);
    [nlLA,sigma2_hat] = LAnegloglikelihood([Beta;theta]);
    llike = -N/2 * (1+log(2*pi)) - nlLA;
    Psi_sigma2 = Delta2Psi_sigma2(Delta,r);
    Psi_hat = Psi_sigma2 * sigma2_hat;

    if verbose
        dispVal('Beta_hat''',Beta_hat')
        dispVal('theta_hat''',theta_hat')
        dispVal('logLike',llike)
        dispVal('sigma2_hat',sigma2_hat)
        dispVal('Psi_hat',Psi_hat,'%9.6f')
        dispVal('Delta_hat',Delta_hat,'%9.6f')
        dispVal('Deg.Freedom',N-numParam,'%d')
        dispVal('AIC',-2*llike+2*numParam)
        dispVal('BIC',-2*llike+log(M)*numParam)
        fprintf('     %d iterations and %d model evaluations in %f seconds.\n',nIter,compute_f([])+compute_fi([]),cputime-t)
        %    Optional values that the user may want to display (when debugging)
        %    dispVal('b_hat''',b_hat','%6.3f')
        %    dispVal('log(sigma2_hat)',log(sigma2_hat))
        %    dispVal('log(diag(L))',log(diag(chol(Psi_hat./sigma2_hat)))')
        %    dispVal('triu(L,1)',nonzeros(triu(chol(Psi_hat./sigma2_hat),1))')
        %    disp(' ')
    end
    
elseif verbose>2
    disp('Laplacian approximation estimate: OFF')
    disp(' ')
end

if haveOutputFcn
    if stop 
        warning('stats:nlmefit:AlgorithmTerminatedByOutputFcn',...
                'Algorithm was terminated by the output function.');
    else
        if laplacianMethod
            ofopt = struct('procedure','LAP','iteration',ALTniter+nIter-1,'inner',...
                        struct('procedure','none','state','none','iteration',NaN),...
                        'fval',llike,'Psi', Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                        'theta',theta,'mse',sigma2_hat,'caller','nlmefit');            
        else
            ofopt = struct('procedure','ALT','iteration',ALTniter-1,'inner',...
                        struct('procedure','none','state','none','iteration',NaN),...
                        'fval',llike,'Psi', Delta2Psi_sigma2(Delta,r)*sigma2_hat,...
                        'theta',theta,'mse',sigma2_hat,'caller','nlmefit');
        end
        callOutputFcns(outputFcn,Beta,ofopt,'done');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare output structure for stats
%       logl   The maximized log-likelihood for the fitted model
%       mse    The estimated error variance for the fitted model
%                 Undocummented once rmse was introduced to be consistent
%                 with nlmefitsa, left in the output structure to be
%                 backwards compatible.
%       rmse   The root mean squared residual
%       errorparam  The estimated parameters of the error variance model
%       aic    The Akaike information criterion for the fitted model
%       bic    The Bayesian information criterion for the fitted model
%       sebeta The standard errors for BETA
%       dfe    The error degrees of freedom for the model

Yhat = compute_f(Beta,b);
res = Y - Yhat; % no weights here
stats.dfe = N-numParam;
stats.logl = llike;
stats.mse = sigma2_hat;
stats.rmse = sqrt(sum(abs(res).^2) / stats.dfe);
switch errorModel
    case 3 % 'combined'
        stats.errorparam = fminsearch(@(ab) error_ab(ab,Y,Yhat),errorModelParam);
    otherwise % case 1,2,4
        stats.errorparam = sqrt(sigma2_hat);
end
stats.aic = -2*llike+2*numParam;
stats.bic = -2*llike+log(M-q*restricted)*numParam;
stats.sebeta = sqrt(diag(linsolve(R00'*R00,eye(q),struct('SYM',true)))*sigma2_hat)';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [negloglike,sigma2] = LAnegloglikelihood(params,bin,weightsin,Yin,grpin,qin,rin,dofCovin,Min,Nin,parTypein,patternCovin)

persistent Y grp q r dofCov M N parType patternCov b weights diagInvLambda halfsumlogLambda

if isempty(params)
    if nargin>3
        Y = Yin;
        grp = grpin;
        r = rin;
        q = qin;
        dofCov = dofCovin;
        M = Min;
        N = Nin;
        parType = parTypein;
        patternCov = patternCovin;
    else
        weights = weightsin;
        diagInvLambda = weights.*weights; 
        halfsumlogLambda = sum(log(weights));
        b = bin;
    end
    return
end

Beta = params(1:q);
Delta = theta2Delta(params(q+1:q+dofCov),r,parType,patternCov);
if isnan(Delta)
    negloglike = 1/eps;
    return
end
DeltaTDelta = Delta'*Delta;

% Compute the approximation to the Jacobian of g (G) (Eq.(7.18) in
% Pinheiro&Bates, page 317), and in Pinheiro&Bates (page 331) for
% non-constant error models. We calculate sum(log(|G|)) and sigma2 in the
% same loop:
delta = (sign(b)+(b==0)).*max(1,abs(b))*sqrt(eps);

dfdb = zeros(N,r);
fb = compute_f(Beta,b);
bpdelta = b;
for j = 1:r
    bpdelta(j,:) = bpdelta(j,:)+delta(j,:);
    dfdb(:,j) = (compute_f(Beta,bpdelta)-fb)./delta(j,grp)';
    bpdelta(j,:) = b(j,:);
end
sigma2 = (sum(sum((Delta*b).^2)) + sum(bsxfun(@times,weights,(Y-fb)).^2))/N;
detG = zeros(M,1);
for i = 1:M
    G = dfdb(grp==i,:)' * diag(diagInvLambda(grp==i)) * dfdb(grp==i,:) + DeltaTDelta;
    detG(i) = det(G);
end

% Varying part of the negative loglikelihood Laplacian approximation
% profiled on sigma2 given by  Eq.(7.19) in Pinheiro&Bates (page 319) and
% in Pinheiro&Bates (page 331) for non-constant error models.
negloglike =  - M*log(det(Delta)) + sum(log(detG))/2 + N*log(sigma2)/2 - halfsumlogLambda;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [negloglike,c_1,R00] = LMEnegloglikelihood(theta,Zin,Xyin,rin,qin,Min,Nin,grpin,restrictedin,parTypein,patternCovin)

persistent Z Xy r q M N grp restricted R00c0 detR11 parType Delta patternCov

if isempty(theta)
    if nargin>3
        r = rin;
        q = qin;
        M = Min;
        N = Nin;
        grp = grpin;
        restricted = restrictedin;
        parType = parTypein;
        R00c0 = zeros(N,q+1);
        detR11 = zeros(M,1);
        patternCov = patternCovin;
    else
        Z = Zin;
        Xy = Xyin;
    end
    return
end

Delta = theta2Delta(theta,r,parType,patternCov);
if isnan(Delta)
    negloglike = 1/eps;
    return
end
for i = 1:M
    % QR decomposition for LME estimation (Pinheiro&Bates, page 68)
    [Q_i,Rx1_i] = qr([Z(grp==i,:);Delta]);
    if r == 1
        detR11(i) = abs(Rx1_i(1));
    else
        detR11(i) = prod(diag(Rx1_i));
    end
    % Building up Eq.(2.17) Pinheiro&Bates, page 70
    Rx0cx_i = Q_i'*[Xy(grp==i,:);zeros(r,q+1)];
    R00c0(grp==i,:) = Rx0cx_i(r+1:end,:);
end
R00cx = qr(R00c0,0);
c_1 = abs(R00cx(q+1,q+1));
if restricted  % Varying part of Eq. (2.23)
    negloglike = (N-q)*log(c_1) + log(abs(prod(diag(R00cx(1:q,1:q))))) - sum(log(abs(det(Delta)./detR11)));
else   % Varying part of Eq. (2.21)
    negloglike = N*log(c_1) - sum(log(abs(det(Delta)./detR11)));
end
if nargout>2
  R00 = triu(R00cx(1:q,1:q));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  b = GNfitGPNLS(Delta,Y,weights,Beta,b,options,i,r)
% Gauss-Newton algorithm for nonlinear regression of the random effects for
% the i-th group.

ptol = options.TolX;
rtol = options.TolFun;
funValCheck = strcmp(options.FunValCheck, 'on');
maxIter = options.MaxIter;

hD = diag(Delta) > min(diag(Delta)).*1e8;

res = (Y - compute_fi(Beta,b,i)).*weights;
sse = res'*res + sum((Delta*b).^2);

ni = numel(Y);
Zw = zeros(ni,r);

iter = 0;
while iter < maxIter
    % Taylor series approximation about the current estimates:
    %  1) compute df/db | b_current with finite differences
    fBetab = compute_fi(Beta,b,i);
    delta1 = (sign(b)+(b==0)).*max(1,abs(b))*sqrt(eps);
    for j = 1:r
        bpdelta = b;
        bpdelta(j) = bpdelta(j)+delta1(j);
        Zw(:,j) = (compute_fi(Beta,bpdelta,i)-fBetab)./delta1(j)';
    end
    %  2) Build the Delta-independent part of the augmented matrix
    ww = Y-fBetab+Zw*b;

    % The derivative matrices and working vector are weighted by the error
    % model:
    ww = bsxfun(@times,weights,ww);
    Zw = bsxfun(@times,weights,Zw);    
    
    if funValCheck, checkFunVals(ww(:)); end

    %  3) Find the least squares estimates
    R = qr([Zw ww;Delta zeros(r,1)],0);
    R11 = triu(R(1:r,1:r));
    c1 = R(1:r,r+1);
    %c0 = R(r+1,r+1);
    %b_new = R11\c1;
    
    if any(hD)
        b_new = zeros(r,1);
        b_new(~hD) = linsolve(R11(~hD,~hD),c1(~hD),struct('UT',true));
     else    
        b_new = linsolve(R11,c1,struct('UT',true));
    end
    
    % Evaluate the fitted values at the new coefficients and
    % compute the residuals and the SSE.
    res = (Y - compute_fi(Beta,b_new,i)).*weights;
    sse_new = res'*res + sum((Delta*b_new).^2);
    if funValCheck && ~isfinite(sse_new), checkFunVals(sse_new); end

    step = b_new - b;

    while sse_new > sse
        if max(abs(step))<eps % check for stall
            warning('stats:nlmefit:UnableToDecreaseSSEinPNLS',...
                'Unable to find a step that will decrease SSE in the Gauss-Newton algorithm while solving PNLS. Returning results from last iteration.');
            sse_new = sse;
            break
        end
        step = step/2;
        b_new = b +step;
        res = (Y - compute_fi(Beta,b_new,i)).*weights;
        sse_new = res'*res + sum((Delta*b_new).^2);
        if funValCheck && ~isfinite(sse_new), checkFunVals(sse_new); end
    end

    sseDiff = abs(sse_new - sse);
    maxParDiff = max(abs(step));

    b = b_new;
    sse = sse_new;

    % Check output conditions
    if sseDiff <= rtol && maxParDiff <= ptol
        break
    end
    iter = iter+1;
end
if iter>=maxIter
    warning('stats:nlmefit:IterationLimitExceededPNLS',...
        'Iteration limit exceeded in the Gauss-Newton algorithm while solving PNLS. Returning results from final iteration.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  [Beta,b,stop] = GNfitPNLS(Delta,Y,Beta,b,weights,options,grp,M,N,r,q)
% Gauss-Newton algorithm for coupled nonlinear regression of the fixed and
% random effects.

stop = false;
outputFcn = options.OutputFcn;
ptol = options.TolX;
rtol = options.TolFun;
funValCheck = strcmp(options.FunValCheck, 'on');
maxIter = options.MaxIter;

hD = diag(Delta) > min(diag(Delta)).*1e8;

res = (Y - compute_f(Beta,b)).*weights;
sse = res'*res + sum(sum((Delta*b).^2));

R11 = cell(M,1);
R00c0 = zeros(N,q+1);
R10c1 = zeros(r*M,q+1);
b_new = zeros(r,M);
Zw = zeros(N,r); % n_i X number of random effects
Xw = zeros(N,q); % n_i X number of fixed effects

iter = 0;
if ~isempty(outputFcn)
     stop = outputFcn(Beta,iter,'init');
end
if ~stop
while iter < maxIter
    % LINEARIZATION step, (Eq.(7.11) Pinheiro&Bates, page 313) (all groups at
    % once)
    fBetab = compute_f(Beta,b);
    delta1 = (sign(b)+(b==0)).*max(1,abs(b))*sqrt(eps);
    for j = 1:r
        bpdelta = b;
        bpdelta(j,:) = bpdelta(j,:)+delta1(j,:);
        Zw(:,j) = (compute_f(Beta,bpdelta)-fBetab)./delta1(j,grp)';
    end
    delta2 = (sign(Beta)+(Beta==0)).*max(1,abs(Beta))*sqrt(eps);
    for j = 1:q
        Betapdelta = Beta;
        Betapdelta(j) = Betapdelta(j) + delta2(j);
        Xw(:,j) = (compute_f(Betapdelta,b)-fBetab)./delta2(j);
    end

    % Build the Delta-independent part of the augmented matrix (ZwXwww)
    % that is required to solve LME (Pinheiro&Bates, page 69) (all groups at
    % once)
    ww = Y - fBetab + Xw*Beta + sum(Zw.*b(:,grp)',2);

    if funValCheck, checkFunVals(ww(:)); end
    Xwww = [Xw ww];
    
    % The derivative matrices and working vector are weighted by the error
    % model:
    Xwww = bsxfun(@times,weights,Xwww);
    Zw = bsxfun(@times,weights,Zw);

    for i = 1:M
        % QR decomposition for Linear Mixed Effects estimation (Pinheiro&Bates, page 69)
        [Q,R]=qr([Zw(grp==i,:);Delta]);
        R11{i} = R(1:r,1:r);
        % Building up Eq.(2.17) Pinheiro&Bates, page 70
        Rx0cx = Q'*[Xwww(grp==i,:);zeros(r,q+1)];
        R00c0(grp==i,:) = Rx0cx(r+1:end,:);
        R10c1(r*(i-1)+(1:r),:) = Rx0cx(1:r,:); % used later in the next loop
    end
    % Find the residual vector for the penalized least-squares fit:
    R00c0 = qr(R00c0,0);
    %Beta_new = triu(R00c0(1:q,1:q)) \ R00c0(1:q,q+1);
    Beta_new = linsolve(triu(R00c0(1:q,1:q)),R00c0(1:q,q+1),struct('UT',true));
    if any(hD)
        for i = 1:M  % Compute BLUPs (Eq.(2.22) Pinheiro&Bates, page 71)
            c1mR10Beta = (R10c1(r*(i-1)+(1:r),q+1)-R10c1(r*(i-1)+(1:r),1:q)*Beta_new);
            b_new(~hD,i) = linsolve(R11{i}(~hD,~hD),c1mR10Beta(~hD),struct('UT',true));
        end
    else
        for i = 1:M  % Compute BLUPs (Eq.(2.22) Pinheiro&Bates, page 71)
            %b_new(:,i) = R11{i}\(R10c1(r*(i-1)+(1:r),q+1)-R10c1(r*(i-1)+(1:r),1:q)*Beta_new);
            b_new(:,i) = linsolve(R11{i},(R10c1(r*(i-1)+(1:r),q+1)-R10c1(r*(i-1)+(1:r),1:q)*Beta_new),struct('UT',true));
        end
    end

    % Evaluate the fitted values at the new coefficients and
    % compute the residuals and the SSE.
    res = (Y - compute_f(Beta_new,b_new)).*weights;
    sse_new = res'*res + sum(sum((Delta*b_new).^2));
    if funValCheck && ~isfinite(sse_new), checkFunVals(sse_new); end

    step = [Beta_new;b_new(:)] - [Beta;b(:)];

    while sse_new > sse
        if max(abs(step))<eps % check for stall
            warning('stats:nlmefit:UnableToDecreaseSSEinPNLS',...
                'Unable to find a step that will decrease SSE in the Gauss-Newton algorithm while solving PNLS. Returning results from last iteration.');
            sse_new = sse;
            break
        end
        step = step/2; 
        Beta_new = Beta + step(1:q);
        b_new(:) = b(:) + step(q+1:end);
        res = (Y - compute_f(Beta_new,b_new)).*weights;
        sse_new = res'*res + sum(sum((Delta*b_new).^2));
        if funValCheck && ~isfinite(sse_new), checkFunVals(sse_new); end
    end

    sseDiff = abs(sse_new - sse);
    maxParDiff = max(abs(step));
    
    Beta = Beta_new;
    b = b_new;
    sse = sse_new;
    
    if ~isempty(outputFcn)
        stop = outputFcn(Beta,iter,'iter');
        if stop 
            break
        end
    end
    % Check output conditions
    if sseDiff <= rtol && maxParDiff <= ptol
        if ~isempty(outputFcn)
            stop = outputFcn(Beta,iter,'done');
        end
        break
    end
    iter = iter+1; 
end
end
if iter>=maxIter
    warning('stats:nlmefit:IterationLimitExceededPNLS',...
        'Iteration limit exceeded in the Gauss-Newton algorithm while solving PNLS. Returning results from final iteration.');
end

function fval = compute_f(Beta,b,Xin,Vin,Ain,Bin,modelin,grpin,isVecin,paramTransform)
%
% FVAL = COMPUTE_F(Beta,b) calls efficiently the user's model function with
% the proper PHI for all (N) observations at once: PHI = A * Beta + B * b.
% COMPUTE_F takes into account if the problem has constant (Am=1), group
% specific (Am=M), or observation specific (Am=N) design matrices for the
% fixed effects. Similarly, for the design matrices of the random effects
% (Bm = 1,M, or N). COMPUTE_F also considers the type of vectorization the
% model handles and if group specific covariates are required by the model.
% 
% COMPUTE_F([],[],X,V,A,B,model,grp,isVec,paramTransform) initializes
% constant data into persistent variables and resets the counter for model
% evaluations. Constant data is burned-in to reduce the number of
% parameters that pass through the optimization functions.
%
% FCOUNT = COMPUTE_F([]) returns the current state of the counter for model
% evaluations and resets it to zero.

persistent X V A B model grp isVec M N Am Bm Vexists count Vgrp

% Burn in persistent data or get the number of function evaluations
if isempty(Beta)
    if nargin>1
        X = Xin; V = Vin; A = Ain; B = Bin; grp = grpin;
        isVec = isVecin;
        M = size(V,1);
        N = size(X,1);
        Am = size(A,3);
        Bm = size(B,3);
        Vexists = ~isempty(V); Vgrp = V(grp,:);
        if any(paramTransform)
            model = @(phi,varargin) modelin(transphi(phi,paramTransform),varargin{:});
        else
            model = @(phi,varargin) modelin(phi,varargin{:});
        end
    else
        fval = count;
    end
    count = 0;
    return
end


if isVec == 3 % Fully vectorized
    count = count + 1;
    switch Am
        case 1
            switch Bm
                case 1
                    ABetaBb = bsxfun(@plus,A*Beta,B*b);
                    if Vexists,  fval = model(ABetaBb(:,grp)',X,Vgrp);
                    else         fval = model(ABetaBb(:,grp)',X);
                    end
                case M
                    Bb = zeros(size(B,1),M);
                    for i = 1:M, Bb(:,i) = (B(:,:,i)*b(:,i)); end
                    ABetaBb = bsxfun(@plus,A*Beta,Bb);
                    if Vexists,  fval = model(ABetaBb(:,grp)',X,Vgrp);
                    else         fval = model(ABetaBb(:,grp)',X);
                    end
                case N
                    Bb = zeros(size(B,1),N);
                    for i = 1:N, Bb(:,i) = (B(:,:,i)*b(:,grp(i))); end
                    ABetaBb = bsxfun(@plus,A*Beta,Bb);
                    if Vexists,  fval = model(ABetaBb',X,Vgrp);
                    else         fval = model(ABetaBb',X);
                    end
            end
        case M
            switch Bm
                case 1
                    ABeta = zeros(size(A,1),M);
                    for i = 1:M, ABeta(:,i) = (A(:,:,i)*Beta); end
                    ABetaBb = ABeta + B*b;
                    if Vexists,  fval = model(ABetaBb(:,grp)',X,Vgrp);
                    else         fval = model(ABetaBb(:,grp)',X);
                    end
                case M
                    ABetaBb = zeros(size(A,1),M);
                    for i = 1:M, ABetaBb(:,i) = (A(:,:,i)*Beta+B(:,:,i)*b(:,i)); end
                    if Vexists,  fval = model(ABetaBb(:,grp)',X,Vgrp);
                    else         fval = model(ABetaBb(:,grp)',X);
                    end
                case N
                    ABeta = zeros(size(A,1),M);
                    for i = 1:M, ABeta(:,i) = (A(:,:,i)*Beta); end
                    ABetaBb = zeros(size(B,1),N);
                    for i = 1:N, ABetaBb(:,i) = ABeta(:,grp(i))+(B(:,:,i)*b(:,grp(i))); end
                    if Vexists,  fval = model(ABetaBb',X,Vgrp);
                    else         fval = model(ABetaBb',X);
                    end
            end
        case N
            switch Bm
                case 1
                    ABeta = zeros(size(A,1),N);
                    for i = 1:N, ABeta(:,i) = (A(:,:,i)*Beta); end
                    Bb = B*b;
                    if Vexists,  fval = model((ABeta+Bb(:,grp))',X,Vgrp);
                    else         fval = model((ABeta+Bb(:,grp))',X);
                    end
                case M
                    ABeta = zeros(size(A,1),N);
                    for i = 1:N, ABeta(:,i) = (A(:,:,i)*Beta); end
                    Bb = zeros(size(B,1),M);
                    for i = 1:M, Bb(:,i) = B(:,:,i)*b(:,i); end
                    if Vexists,  fval = model((ABeta+Bb(:,grp))',X,Vgrp);
                    else         fval = model((ABeta+Bb(:,grp))',X);
                    end
                case N
                    ABetaBb = zeros(size(A,1),N);
                    for i = 1:N, ABetaBb(:,i) = (A(:,:,i)*Beta)+B(:,:,i)*b(:,grp(i)); end
                    if Vexists,  fval = model((ABetaBb)',X,Vgrp);
                    else         fval = model((ABetaBb)',X);
                    end
            end
    end
else % vectorization is either Single PHI (isVec==1) or Single Group (isVec==2)
    switch Am
        case 1
            switch Bm
                case 1
                    count = count + M;
                    ABetaBb = bsxfun(@plus,A*Beta,B*b);
                    fval = zeros(N,1);
                    if Vexists, for i=1:M, fval(grp==i) = model(ABetaBb(:,i)',X(grp==i,:), V(i,:)); end
                    else        for i=1:M, fval(grp==i) = model(ABetaBb(:,i)',X(grp==i,:)); end
                    end
                case M
                    count = count + M;
                    ABeta = A*Beta;
                    fval = zeros(N,1);
                    if Vexists, for i=1:M, fval(grp==i) = model((ABeta+B(:,:,i)*b(:,i))',X(grp==i,:), V(i,:)); end
                    else        for i=1:M, fval(grp==i) = model((ABeta+B(:,:,i)*b(:,i))',X(grp==i,:)); end
                    end
                case N
                    Bb = zeros(size(B,1),N);
                    for i = 1:N, Bb(:,i) = (B(:,:,i)*b(:,grp(i))); end
                    ABetaBb = bsxfun(@plus,A*Beta,Bb);
                    fval = zeros(N,1);
                    if isVec==1 % Single PHI
                        count = count + N;
                        if Vexists,  for i=1:N, fval(i) = model(ABetaBb(:,i)',X(i,:),V(grp(i),:)); end;
                        else         for i=1:N, fval(i) = model(ABetaBb(:,i)',X(i,:)); end;
                        end
                    else  % Single Group
                        count = count + M;
                        if Vexists,  for i=1:M, fval(grp==i) = model(ABetaBb(:,grp==i)',X(grp==i,:),V(i,:)); end;
                        else         for i=1:M, fval(grp==i) = model(ABetaBb(:,grp==i)',X(grp==i,:)); end;
                        end
                    end
            end
        case M
            switch Bm
                case 1
                    count = count + M;
                    fval = zeros(N,1);
                    if Vexists, for i=1:M, fval(grp==i) = model((A(:,:,i)*Beta+B*b(:,i))',X(grp==i,:),V(i,:)); end
                    else        for i=1:M, fval(grp==i) = model((A(:,:,i)*Beta+B*b(:,i))',X(grp==i,:)); end
                    end
                case M
                    count = count + M;
                    fval = zeros(N,1);
                    if Vexists, for i=1:M, fval(grp==i) = model((A(:,:,i)*Beta+B(:,:,i)*b(:,i))',X(grp==i,:),  V(i,:)); end
                    else        for i=1:M, fval(grp==i) = model((A(:,:,i)*Beta+B(:,:,i)*b(:,i))',X(grp==i,:)); end
                    end
                case N
                    ABeta = zeros(size(A,1),M);
                    for i = 1:M, ABeta(:,i) = (A(:,:,i)*Beta); end
                    ABetaBb = zeros(size(B,1),N);
                    for i = 1:N, ABetaBb(:,i) = ABeta(:,grp(i))+(B(:,:,i)*b(:,grp(i))); end
                    fval = zeros(N,1);
                    if isVec==1 % Single PHI
                        count = count + N;
                        if Vexists,  for i=1:N, fval(i) = model(ABetaBb(:,i)',X(i,:),V(grp(i),:)); end;
                        else         for i=1:N, fval(i) = model(ABetaBb(:,i)',X(i,:)); end;
                        end
                    else  % Single Group
                        count = count + M;
                        if Vexists,  for i=1:M, fval(grp==i) = model(ABetaBb(:,grp==i)',X(grp==i,:),V(i,:)); end;
                        else         for i=1:M, fval(grp==i) = model(ABetaBb(:,grp==i)',X(grp==i,:)); end;
                        end
                    end
            end
        case N
            switch Bm
                case 1
                    ABeta = zeros(size(A,1),N);
                    for i = 1:N, ABeta(:,i) = (A(:,:,i)*Beta); end
                    Bb = B*b;
                    ABetaBb = ABeta + Bb(:,grp);
                case M
                    ABeta = zeros(size(A,1),N);
                    for i = 1:N, ABeta(:,i) = (A(:,:,i)*Beta); end
                    Bb = zeros(size(B,1),M);
                    for i = 1:M, Bb(:,i) = B(:,:,i)*b(:,i); end
                    ABetaBb = ABeta + Bb(:,grp);
                case N
                    ABetaBb = zeros(size(A,1),N);
                    for i = 1:N, ABetaBb(:,i) = (A(:,:,i)*Beta)+B(:,:,i)*b(:,grp(i)); end
            end
            fval = zeros(N,1);
            if isVec==1 % Single PHI
                count = count + N;
                if Vexists,  for i=1:N, fval(i) = model(ABetaBb(:,i)',X(i,:),V(grp(i),:)); end;
                else         for i=1:N, fval(i) = model(ABetaBb(:,i)',X(i,:)); end;
                end
            else  % Single Group
                count = count + M;
                if Vexists,  for i=1:M, fval(grp==i) = model(ABetaBb(:,grp==i)',X(grp==i,:),V(i,:)); end;
                else         for i=1:M, fval(grp==i) = model(ABetaBb(:,grp==i)',X(grp==i,:)); end;
                end
            end
    end
end

function fval = compute_fi(Beta,b,j,Xin,Vin,Ain,Bin,modelin,grpin,isVecin,paramTransform)
%
% FVAL = COMPUTE_FI(Beta,b,i) calls efficiently the user's model function
% with the proper PHI for (ni) observations of the i-th group: 
% PHI = A * Beta + B * b. COMPUTE_FI takes into account if the problem has
% constant (Am=1), group specific (Am=M), or observation specific (Am=N)
% design matrices for the fixed effects. Similarly, for the design matrices
% of the random effects (Bm = 1,M, or N). COMPUTE_FI also considers the
% type of vectorization the model handles and if group specific covariates
% are required by the model.
% 
% COMPUTE_FI([],[],[],X,V,A,B,model,grp,isVec,paramTransform) initializes
% constant data into persistent variables and resets the counter for model
% evaluations. Constant data is burned-in to reduce the number of
% parameters that pass through the optimization functions.
%
% FCOUNT = COMPUTE_FI([]) returns the current state of the counter for
% model evaluations and resets it to zero.

persistent X V A B model grp isVec M N Am Bm Vexists count

% Burn in persistent data or get the number of function evaluations
if isempty(Beta)
    if nargin>1
        X = Xin; V = Vin; A = Ain; B = Bin; grp = grpin;
        isVec = isVecin;
        Vexists = ~isempty(V);
        M = size(V,1);
        N = size(X,1);
        Am = size(A,3);
        Bm = size(B,3);
        
        if any(paramTransform)
            model = @(phi,varargin) modelin(transphi(phi,paramTransform),varargin{:});
        else
            model = @(phi,varargin) modelin(phi,varargin{:});
        end        
    else
        fval = count;
    end
    count = 0;
    return
end

switch Am
    case 1
        switch Bm
            case 1
                count = count + 1;
                if Vexists, fval = model((A*Beta+B*b)',X(grp==j,:), V(j,:));
                else        fval = model((A*Beta+B*b)',X(grp==j,:));
                end
            case M
                count = count + 1;
                if Vexists, fval = model((A*Beta+B(:,:,j)*b)',X(grp==j,:), V(j,:));
                else        fval = model((A*Beta+B(:,:,j)*b)',X(grp==j,:));
                end
            case N
                h = find(grp==j);
                n = numel(h);
                ABetaBb = zeros(size(A,1),n);
                for i = 1:n, ABetaBb(:,i) = A*Beta + B(:,:,h(i))*b; end
                if isVec==1 % Single PHI
                    fval = zeros(n,1);
                    count = count + n;
                    if Vexists,  for i=1:n, fval(i) = model(ABetaBb(:,i)',X(h(i),:),V(j,:)); end;
                    else         for i=1:n, fval(i) = model(ABetaBb(:,i)',X(h(i),:)); end;
                    end
                else  % Single Group or FullVec
                    count = count + 1;
                    if Vexists,  fval = model(ABetaBb',X(h,:),V(j,:));
                    else         fval = model(ABetaBb',X(h,:));
                    end
                end
        end
    case M
        switch Bm
            case 1
                count = count + 1;
                if Vexists, fval = model((A(:,:,j)*Beta+B*b)',X(grp==j),  V(j,:));
                else        fval = model((A(:,:,j)*Beta+B*b)',X(grp==j));
                end
            case M
                count = count + 1;
                if Vexists, fval = model((A(:,:,j)*Beta+B(:,:,j)*b)',X(grp==j),  V(j,:));
                else        fval = model((A(:,:,j)*Beta+B(:,:,j)*b)',X(grp==j));
                end
            case N
                h = find(grp==j);
                n = numel(h);
                ABetaBb = zeros(size(A,1),n);
                for i = 1:n, ABetaBb(:,i) = A(:,:,j)*Beta + B(:,:,h(i))*b; end
                if isVec==1 % Single PHI
                    fval = zeros(n,1);
                    count = count + n;
                    if Vexists,  for i=1:n, fval(i) = model(ABetaBb(:,i)',X(h(i),:),V(j,:)); end;
                    else         for i=1:n, fval(i) = model(ABetaBb(:,i)',X(h(i),:)); end;
                    end
                else  % Single Group or FullVec
                    count = count + 1;
                    if Vexists,  fval = model(ABetaBb',X(h,:),V(j,:));
                    else         fval = model(ABetaBb',X(h,:));
                    end
                end
        end
    case N
        switch Bm
            case 1
                h = find(grp==j);
                n = numel(h);
                ABetaBb = zeros(size(A,1),n);
                for i = 1:n, ABetaBb(:,i) = (A(:,:,h(i))*Beta)+B*b; end
            case M
                h = find(grp==j);
                n = numel(h);
                ABetaBb = zeros(size(A,1),n);
                for i = 1:n, ABetaBb(:,i) = (A(:,:,h(i))*Beta)+B(:,:,j)*b; end
            case N
                h = find(grp==j);
                n = numel(h);
                ABetaBb = zeros(size(A,1),n);
                for i = 1:n, ABetaBb(:,i) = (A(:,:,h(i))*Beta)+B(:,:,h(i))*b; end
        end
        if isVec==1 % Single PHI
            fval = zeros(n,1);
            count = count + n;
            if Vexists,  for i=1:n, fval(i) = model(ABetaBb(:,i)',X(h(i),:),V(j,:)); end;
            else         for i=1:n, fval(i) = model(ABetaBb(:,i)',X(h(i),:)); end;
            end
        else  % Single Group or FullVec
            count = count + 1;
            if Vexists,  fval = model(ABetaBb',X(h,:),V(j,:));
            else         fval = model(ABetaBb',X(h,:));
            end
        end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Psi_sigma2 = Delta2Psi_sigma2(Delta,r)
% Construct Psi_sigma2 given Delta, r is the number of random effects
ws = warning('off','MATLAB:nearlySingularMatrix');
Deltainv = linsolve(Delta,eye(r));
warning(ws)
Psi_sigma2 = Deltainv*Deltainv'; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function theta = Delta2theta(Delta,r,parType,pat)
% Construct theta given Delta, sigma2 and a predefined parameterization
% method given by parType, r is the number of random effects
switch parType
    case 'logm' % Parameterizing logm of (Delta'*Delta)
        log_DeltaTDelta = logm(Delta'*Delta);
        theta = log_DeltaTDelta(pat);
    case 'logmcov'  % Parameterizing logm of the Scaled Covariance (Pinheiro&Bates, page 78)
        Deltainv = linsolve(Delta,eye(r));
        Psi_sigma2 = logm(Deltainv*Deltainv'); 
        theta = Psi_sigma2(pat);
    case 'chol' % Parameterizing the Precision Factors directly, i.e. 
                % parameterizing the Cholesky Decomposition of (Delta'*Delta)
        theta = Delta(pat);
    case 'cholcov' % Parameterizing the Cholesky Decomposition of the Scaled Covariance
        L = linsolve(Delta,eye(r));
        theta = L(pat);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Delta = theta2Delta(theta,r,parType,pat)
% Construct Delta given theta and a predefined parameterization method
% given by parType, r is the number of random effects
switch parType
    case 'chol' % Parameterizing the Precision Factors directly, i.e. 
                % parameterizing the Cholesky Decomposition of (Delta'*Delta)
        Delta = zeros(r);
        Delta(pat) = theta;
    case 'logm' % Parameterizing logm of (Delta'*Delta)
        log_DeltaTDelta = zeros(r);
        log_DeltaTDelta(pat) = theta;
        log_DeltaTDelta = log_DeltaTDelta+triu(log_DeltaTDelta,1)';
        DeltaTDelta = expm(log_DeltaTDelta);
        try
            Delta = chol(DeltaTDelta);
        catch ME
            if isequal(ME.identifier,'MATLAB:posdef')
                Delta = NaN;
            else
                rethrow(ME)
            end
        end
    case 'logmcov' % Parameterizing logm of the Scaled Covariance (Pinheiro&Bates, page 78)
        log_Psi_sigma2 = zeros(r);
        log_Psi_sigma2(pat) = theta;
        log_Psi_sigma2 = log_Psi_sigma2+triu(log_Psi_sigma2,1)';
        Psi_sigma2 = expm(log_Psi_sigma2);
        if rank(Psi_sigma2)<r
            Delta = NaN;
            return
        end
        DeltaTDelta = linsolve(Psi_sigma2,eye(r),struct('SYM',true));
        try
            Delta = chol(DeltaTDelta);
        catch ME
            if isequal(ME.identifier,'MATLAB:posdef')
                Delta = NaN;
            else
                rethrow(ME)
            end
        end
    case 'cholcov' % Parameterizing the Cholesky Decomposition of the Scaled Covariance
        L = zeros(r);
        L(pat) = theta;
        if rank(L)<r
            Delta = NaN;
        else
            Delta = linsolve(L,eye(r));
        end
end
if ~all(diag(Delta)>=0)
    Delta = NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  beta = LMfit(X,y,model,beta,options)
% Levenberg-Marquardt algorithm for nonlinear regression

lambda = 0.01; % 'lambda' is the initial weight for LM algorithm
betatol = options.TolX;
rtol = options.TolFun;
funValCheck = strcmp(options.FunValCheck, 'on');
maxiter = options.MaxIter;

% Set the iteration step
sqrteps = sqrt(eps(class(beta)));
p = numel(beta);

yfit = model(beta,X);
r = y - yfit;
sse = r'*r;

J = zeros(numel(yfit),p); % allocate space for Jacobian
step = 0; % in case Jacobian is always 0, step is never defined
zerosp = zeros(p,1,class(r));
iter = 0;
breakOut = false;

while iter < maxiter
    iter = iter + 1;
    betaold = beta;
    sseold = sse;

    % Compute a finite difference approximation to the Jacobian
    delta = (sign(beta)+(beta==0)).*max(1,abs(beta))*sqrt(eps);
    for j = 1:p
        betapdelta = beta;
        betapdelta(j) = betapdelta(j) + delta(j);
        J(:,j)  = (model(betapdelta,X)-yfit)./delta(j);
    end

    % Levenberg-Marquardt step: inv(J'*J+lambda*D)*J'*r
    diagJtJ = sum(abs(J).^2, 1);
    if funValCheck && ~all(isfinite(diagJtJ)), checkFunVals(J(:)); end
    Jplus = [J; diag(sqrt(lambda*diagJtJ))];
    rplus = [r; zerosp];
    h = any(Jplus,1);
    if any(h)
        step = Jplus(:,h) \ rplus;
        beta(h) = beta(h) + step;
    end

    % Evaluate the fitted values at the new coefficients and
    % compute the residuals and the SSE.
    yfit = model(beta,X);
    r = y - yfit;
    sse = r'*r;
    if funValCheck && ~isfinite(sse), checkFunVals(r); end
    % If the LM step decreased the SSE, decrease lambda to downweight the
    % steepest descent direction.  Prevent underflowing to zero after many
    % successful steps; smaller than eps is effectively zero anyway.
    if sse < sseold
        lambda = max(0.1*lambda,eps);

        % If the LM step increased the SSE, repeatedly increase lambda to
        % upweight the steepest descent direction and decrease the step size
        % until we get a step that does decrease SSE.
    else
        while sse >= sseold
            lambda = 10*lambda;
            if lambda > 1e16
                breakOut = true;
                break
            end
            Jplus = [J; diag(sqrt(lambda*sum(J.^2,1)))];
            h = any(Jplus,1);
            if any(h)
                step = Jplus(:,h) \ rplus;
                beta(h) = betaold(h) + step;
            end
            yfit = model(beta,X);
            r = y - yfit;
            sse = r'*r;
            if funValCheck && ~isfinite(sse), checkFunVals(r); end
        end
    end
    % Check step size and change in SSE for convergence.
    if (norm(step) < betatol*(sqrteps+norm(beta))) &&...
            (abs(sse-sseold) <= rtol*sse)
        break
    elseif breakOut
        warning('stats:nlmefit:UnableToDecreaseSSEinLMalg',...
            'Unable to find a step that decreases SSE in the Levenberg-Marquardt algorithm during the initial refinement of the fixed effects.');
        break
    end
end
if (iter >= maxiter)
    warning('stats:nlmefit:IterationLimitExceededLMalg',...
        'During the initial refinement of the fixed effects, the iteration limit for the Levenberg-Marquardt algorithm exceded.');
end
% If the Jacobian is ill-conditioned, then two parameters are probably
% aliased and the estimates will be highly correlated.  Prediction at new x
% values not in the same column space is dubious. It may also be that the
% Jacobian has one or more columns of zeros, meaning model is constant with
% respect to one or more parameters.  This may be because those parameters
% are not even in the expression in the model function, or they are
% multiplied by another param that is estimated at exactly zero (or
% something similar), or because some part of the model function is
% underflowing, making it a constant zero. In the context of NLMEFIT it is
% preferable to error (instead of warning as in NLINFIT) since it is very
% likely that the NLME model will have the same issue.
[~,R] = qr(J,0);
if condest(R) > 1/(eps(class(beta)))^(1/2)
    if any(all(abs(J)<sqrt(eps(norm(J,1))),1),2) % one or more columns of zeros
       error('stats:nlmefit:ModelConstantWRTParamLMalg', ... 
       ['After the initial refinement of the fixed effects with the Levenberg-'...
        'Marquardt algorithm some columns of the Jacobian are effectively zero '...
        'at BETA0, indicating that the model is insensitive to some of its '...
        'parameters.  That may be because those parameters are not present in '...
        'the model, or otherwise do not affect the predicted values.  It may '...
        'also be due to numerical underflow in the model function, which can '...
        'sometimes be avoided by choosing better initial parameter values, or '...
        'by rescaling or recentering.']) 
    else  % no columns of zeros
       error('stats:nlmefit:IllConditionedJacobianLMalg', ...
       ['After the initial refinement of the fixed effects with the Levenberg-'...
        'Marquardt algorithm the Jacobian at BETA0 is ill-conditioned.  Some '...
        'fixed effects may not be identifiable resulting in a poor estimation.  '...
        'Check for possible aliased parameters of your model, or try setting '...
        '''RefineBeta0'' to FALSE.'])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkFunVals(v)
% Helper function to check if the function has the finite output
if any(~isfinite(v))
    error('stats:nlmefit:checkFunVals','MYFUN has returned Inf or NaN values.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dispVal(str,x,f)
% Helper function to display values in the command window
if nargin<3, f = '%f'; end
if numel(x)==1
    disp([blanks(5) str blanks(12-numel(str)) '= ' sprintf(f,x)])
elseif size(x,1)==1
    disp([blanks(5) str blanks(12-numel(str)) '= [' sprintf([' ' f],x) ' ]'])
else
    disp([blanks(5) str blanks(12-numel(str)) '= [' sprintf([' ' f],x(1,:)) ])
    for i = 2:size(x,1)-1
        disp([blanks(20) sprintf([' ' f],x(i,:))])
    end
    disp([blanks(20) sprintf([' ' f],x(end,:)) ' ]'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p,r,A,B,patternCov,thetaLen,RefineBeta0,Approximationtype,...
          Vectorization,CovParameterization,Options,Optimfun,OutputFcn,...
          ParamTransform,ErrorModel] = parseInVarargin(q,M,N,varargin)
% Helper function for parsing and validate VARARGIN

% Set defaults
RESELECTgiven = false;
REDESIGNgiven = false;
REGROUPDESIGNgiven = false;
REOBSDESIGNgiven = false;
FESELECTgiven = false;
FEDESIGNgiven = false;
FEGROUPDESIGNgiven = false;
FEOBSDESIGNgiven = false;
COVPATTERN = NaN;
RE_p = NaN;
RE_r = NaN;
FE_p = NaN;
PSI_r = NaN;

RefineBeta0 = true;
Approximationtype = 'LME';
Vectorization = 1; %('SinglePhi')
CovParameterization = 'logm';
Optimfun = 'fminsearch';
OutputFcn = [];
ParamTransform = [];
ErrorModel = 1; %('Constant')

Options = statset('nlmefit');
% Options.TolX = 1e-4;
% Options.TolFun = 1e-4;
% Options.MaxIter = 200;
% Options.Display = 'off';
% Options.FunValCheck = 'on';
% Options.Jacobian = 'off';
% Options.OutputFcn = [];

% Process PVP
numvaragin = numel(varargin);
if numvaragin > 0
    if rem(numvaragin,2)
        error('stats:nlmefit:IncorrectNumberOfArguments',...
            'Incorrect number of arguments to %s.',mfilename);
    end
    okargs = {'covpattern','reparamsselect','redesign','regroupdesign',...
        'reobsdesign','feparamsselect','fedesign','fegroupdesign',...
        'feobsdesign','refinebeta0','approximationtype','vectorization',...
        'covparameterization','options','optimfun','reconstdesign',...
        'feconstdesign','outputfcn','paramtransform','errormodel'};
    for j=1:2:numvaragin
        pname = varargin{j};
        pval = varargin{j+1};
        k = find(strncmpi(pname, okargs, length(pname)));
        if isempty(k)
            error('stats:nlmefit:UnknownParameterName',...
                'Unknown parameter name: %s.',pname);
        elseif length(k)>1
            error('stats:nlmefit:AmbiguousParameterName',...
                'Ambiguous parameter name: %s.',pname);
        else
            switch(k)
                case 1 % COVPATTERN
                    if isvector(pval)
                        pval = grp2idx(pval);
                        COVPATTERN = false(numel(pval));
                        for i = 1:max(pval)
                            COVPATTERN(pval==i,pval==i) = true(sum(pval==i));
                        end
                    elseif isnumeric(pval) && ndims(pval)==2 && ~diff(size(pval))
                        COVPATTERN = pval ~= 0;
                    elseif ndims(pval)==2 && ~diff(size(pval))
                        COVPATTERN = pval;
                    else
                        error('stats:nlmefit:InvalidPAT',...
                            'CovPattern must be a square matrix or a numeric vector.')
                    end
                    PSI_r = size(COVPATTERN,1);
                    if ~isequal(COVPATTERN,(COVPATTERN|COVPATTERN')|eye(PSI_r))
                        warning('stats:nlmefit:SymmetricPAT',...
                            'CovPattern should be symmetric and have nonzero diagonal elements. NLMEFIT automatically sets the missing values.')
                        COVPATTERN = (COVPATTERN|COVPATTERN')|eye(PSI_r);
                    end
                    if ~isequal(COVPATTERN,(COVPATTERN).^PSI_r)
                        warning('stats:nlmefit:MissingCovInPAT',...
                            'NLMEFIT requires to estimate additional covariance elements to those specified by CovPattern. An additional element accounts for the covariance between any two random effects that have a covariance to a third random effect.')
                        COVPATTERN = COVPATTERN.^PSI_r;
                    end
                case 2 % RESELECT
                    if isvector(pval) && islogical(pval)
                        RE_p = numel(pval);
                        RE_r = sum(pval);
                        RESELECT = pval(:);
                    elseif isvector(pval) && numel(unique(pval))==numel(pval)
                        RE_p = NaN;
                        RE_r = numel(pval);
                        RESELECT = pval(:);
                    else
                        error('stats:nlmefit:InvalidREParamsSelect',...
                            'REParamsSelect must be a logical or a unique numeric vector.')
                    end
                    RESELECTgiven = true;
                case {3,16} % REDESIGN and RECONSTDESIGN
                    if isnumeric(pval) && ndims(pval)==2
                        RE_p = size(pval,1);
                        RE_r = size(pval,2);
                        REDESIGN = pval;
                    else
                        error('stats:nlmefit:InvalidREConstDesign',...
                            'REConstDesign must be a numeric matrix.')
                    end
                    REDESIGNgiven = true;
                case 4 % REGROUPDESIGN
                    if isnumeric(pval) && size(pval,3)==M
                        RE_p = size(pval,1);
                        RE_r = size(pval,2);
                        REGROUPDESIGN = pval;
                    else
                        error('stats:nlmefit:InvalidREGroupDesign',...
                            'REGroupDesign must be a 3-D array with M design matrices.')
                    end
                    REGROUPDESIGNgiven = true;
                case 5 % REOBSDESIGN
                    if isnumeric(pval) && size(pval,3)==N
                        RE_p = size(pval,1);
                        RE_r = size(pval,2);
                        REOBSDESIGN = pval;
                    else
                        error('stats:nlmefit:InvalidREObsDesign',...
                            'REObsDesign must be a 3-D array with N design matrices.')
                    end
                    REOBSDESIGNgiven = true;
                case 6 % FESELECT
                    if isvector(pval) && islogical(pval)
                        FE_p = numel(pval);
                        FESELECT = pval(:);
                    elseif isvector(pval) &&  numel(unique(pval))==numel(pval)
                        FE_p = NaN;
                        FESELECT = pval(:);
                    else
                        error('stats:nlmefit:InvalidFEParamsSelect',...
                            'FEParamsSelect must be a logical or a unique numeric vector.')
                    end
                    FESELECTgiven = true;
                case {7,17} % FEDESIGN and FECONSTDESIGN
                    if isnumeric(pval) && ndims(pval)==2
                        FE_p = size(pval,2);
                        FEDESIGN = pval;
                    else
                        error('stats:nlmefit:InvalidFEConstDesign',...
                            'FEConstDesign must be a numeric matrix.')
                    end
                    FEDESIGNgiven = true;
                case 8 % FEGROUPDESIGN
                    if isnumeric(pval) && size(pval,3)==M
                        FE_p = size(pval,2);
                        FEGROUPDESIGN = pval;
                    else
                        error('stats:nlmefit:InvalidFEGroupDesign',...
                            'FEGroupDesign must be a 3-D array with M design matrices.')
                    end
                    FEGROUPDESIGNgiven = true;
                case 9 % FEOBSDESIGN
                    if isnumeric(pval) && size(pval,3)==N
                        FE_p = size(pval,2);
                        FEOBSDESIGN = pval;
                    else
                        error('stats:nlmefit:InvalidFEObsDesign',...
                            'FEObsDesign must be a 3-D array with N design matrices.')
                    end
                    FEOBSDESIGNgiven = true;
                case 10 % RefineBeta0
                    ok = {'on','off'};
                    okv = find(strncmpi(pval,ok,numel(pval)));
                    if numel(okv)==1
                        RefineBeta0 = okv==1;
                    else
                        error('stats:nlmefit:InvalidRefineBeta0',...
                            'RefineBeta0 must be ''on'' or ''off''.')
                    end
                case 11 % Approximationtype
                    ok = {'LME','RELME','FO','FOCE'};
                    okv = find(strncmpi(pval,ok,numel(pval)));
                    if numel(okv)==1
                        Approximationtype = ok{okv};
                    elseif strncmpi(pval,'FO',2)
                        Approximationtype = 'FO';
                    else
                        error('stats:nlmefit:InvalidApproximationtype',...
                            'Approximationtype must be ''LME'', ''RELME'', ''FO'' or ''FOCE''.')
                    end
                case 12 % Vectorization
                    ok = {'singlephi','singlegroup','full'};
                    okv = find(strncmpi(pval,ok,numel(pval)));
                    if numel(okv)==1
                        Vectorization = okv;
                    else
                        error('stats:nlmefit:InvalidVectorization',...
                            'Vectorization must be ''SinglePhi'', ''SingleGroup'' or ''Full''.')
                    end
                case 13 % CovParameterization
                    ok = {'logm','logmcov','chol','cholcov'};
                    okv = find(strncmpi(pval,ok,numel(pval)),1);
                    % partial matches favor to logm and chol options which
                    % are the ones documented for 9a
                    if numel(okv)==1
                        CovParameterization = ok{okv};
                    else
                        error('stats:nlmefit:InvalidCovParameterization',...
                            'CovParameterization must be ''logm'' or ''chol''.')
                    end
                case 14 % Options
                    try
                        Options = statset(Options,pval);
                    catch ME
                        error('stats:nlmefit:InvalidOptions',...
                           'Options must be a structure created with STATSET.')
                    end
                    if isa(Options.OutputFcn,'function_handle')
                        Options.OutputFcn = {Options.OutputFcn};
                    end
                case 15 % Optimfun
                    ok = {'fminsearch','fminunc'};
                    okv = find(strncmpi(pval,ok,numel(pval)));
                    if numel(okv)==1
                        Optimfun = ok{okv};
                    else
                        error('stats:nlmefit:InvalidOptimFun',...
                            'OptimFun must be ''fminsearch'' or ''fminunc''.')
                    end
                    if strcmp(Optimfun,'fminunc') && isempty(ver('Optim'))
                        error('stats:nlmefit:NoOptim',...
                            'The Optimization Toolbox is required to use ''fminunc''. Set ''OptimFun'' to ''fminsearch''.')
                    end
                case 18 % OutputFcn
                    if iscell(pval) && all(cellfun(@(x) isa(x,'function_handle'),pval))
                        OutputFcn = pval;
                    elseif isa(pval,'function_handle')
                        OutputFcn = {pval};
                    elseif isempty(pval)
                        OutputFcn = {};
                    else
                        error('stats:nlmefit:invalidOutputFcn',...
                            'OUTPUTFCN is not a function handle class or a cell array with function handles.')
                    end
                case 19 % paramtransform
                    ParamTransform = pval;
                case 20 % ErrorModel
                    ok = {'constant','proportional','combined','exponential'};
                    okv = find(strncmpi(pval,ok,numel(pval)));
                    if numel(okv)==1
                        ErrorModel = okv;
                    else
                        error('stats:nlmefit:InvalidErrorModel',...
                            'ErrorModel must be ''Constant'',''Proportional'',''Combined'' or ''Exponential''.')
                    end
            end
        end
    end
end

% Coalece OutputFcn and Options.OutputFcn
OutputFcn = [Options.OutputFcn(:);OutputFcn(:)];

% Check input parameters
if sum([RESELECTgiven,REDESIGNgiven,REGROUPDESIGNgiven,REOBSDESIGNgiven])>1
    msg = [];
    if RESELECTgiven
        msg = [msg 'REParamsSelect, '];
    end
    if REDESIGNgiven
        msg = [msg 'REConstDesign, '];
    end
    if REGROUPDESIGNgiven
        msg = [msg 'REGroupDesign, '];
    end
    if REOBSDESIGNgiven
        msg = [msg 'REObsDesign, '];
    end
    msg = msg(1:end-2);
    msg = [msg(1:find(msg==',',1,'last')-1) ' and' msg(find(msg==',',1,'last')+1:end)];
    msg = [msg ' cannot be used together.'];
    error('stats:nlmefit:MultipleREDesign',msg)
end

if sum([FESELECTgiven,FEDESIGNgiven,FEGROUPDESIGNgiven,FEOBSDESIGNgiven])>1
    msg = [];
    if FESELECTgiven
        msg = [msg 'FEParamsSelect, '];
    end
    if FEDESIGNgiven
        msg = [msg 'FEConstDesign, '];
    end
    if FEGROUPDESIGNgiven
        msg = [msg 'FEGroupDesign, '];
    end
    if FEOBSDESIGNgiven
        msg = [msg 'FEObsDesign, '];
    end
    msg = msg(1:end-2);
    msg = [msg(1:find(msg==',',1,'last')-1) ' and' msg(find(msg==',',1,'last')+1:end)];
    msg = [msg ' cannot be used together.'];
    error('stats:nlmefit:MultipleFEDesign',msg)
end

% the number of fixed effects (q) is always inferred from Beta0, which is
% mandatory, so we just check that FE specification complies
if FESELECTgiven
    if islogical(FESELECT)
        if sum(FESELECT)~=q
            error('stats:nlmefit:conflictingFinFEParamsSelect','The logical vector FEParamsSelect must have the same number of nonzero elements as the number of elements in BETA0, which is the number of fixed effects (F).')
        end
        A = accumarray([find(FESELECT(:)),(1:q)',],1,[FE_p,q]);
    else
        if numel(FESELECT)~=q
            error('stats:nlmefit:conflictingFinFEParamsSelect','The index vector FEParamsSelect must have the same number of elements as BETA0, which is the number of fixed effects (F).')
        end
        A = accumarray([FESELECT(:),(1:q)'],1);
    end
elseif FEDESIGNgiven
    if size(FEDESIGN,2) ~=q
        error('stats:nlmefit:conflictingFinFEConstDesign','The design matrix FEConstDesign must have the same number of columns as elements in BETA0, which is the number of fixed effects (F).')
    end
    A = FEDESIGN;
elseif FEGROUPDESIGNgiven
    if size(FEGROUPDESIGN,2) ~=q
        error('stats:nlmefit:conflictingFinFEGroupDesign','The design matrices in FEGroupDesign must have the same number of columns as elements in BETA0, which is the number of fixed effects (F).')
    end
    A = FEGROUPDESIGN;
elseif FEOBSDESIGNgiven
    if size(FEOBSDESIGN,2) ~=q
        error('stats:nlmefit:conflictingFinFEObsDesign','The design matrices in FEObsDesign must have the same number of columns as elements in BETA0, which is the number of fixed effects (F).')
    end
    A = FEOBSDESIGN;
else % no FE specified, then use default
    A = eye(q);
    FE_p = q;
end

% the number of parameters (p) was inferred in all cases from A except when
% FESELECT was a vector of indices, check that B does not conflict
p = size(A,1);
if RESELECTgiven
    if islogical(RESELECT)
        if RE_p~=p
            if isnan(FE_p)
                if RE_p<p
                    msg = 'The index vector FEParamsSelect must have elements in [1:P]. P is the number of parameters of the model and was inferred from the input REParamsSelect.';
                    error('stats:nlmefit:conflictingPinFEParamsSelect',msg)
                else
                    A(end+1:RE_p,:) = 0;
                    p = size(A,1);
                end
            else
                msg = 'The logical vector REParamsSelect must have P elements. P is the number of parameters of the model';
                if FESELECTgiven
                    msg = [msg ' and was inferred from the input FEParamsSelect.'];
                elseif FEDESIGNgiven
                    msg = [msg ' and was inferred from the input FEConstDesign.'];
                elseif FEGROUPDESIGNgiven
                    msg = [msg ' and was inferred from the input FEGroupDesign.'];
                elseif FEOBSDESIGNgiven
                    msg = [msg ' and was inferred from the input FEObsDesign.'];
                else
                    msg = [msg '. When no design for the fixed effects is specified, P was inferred from the number of fixed effects (F); by default there is one fixed effect for each model parameter. F was inferred from the number of elements in BETA0.'];
                end
                error('stats:nlmefit:conflictingPinREParamsSelect',msg)
            end
        end
        B = accumarray([find(RESELECT(:)),(1:RE_r)',],1,[p,RE_r]);
    else
        if ~all(ismember(RESELECT,1:p))
            if isnan(FE_p)
                p = max(RESELECT);
            else
                msg = 'The index vector REParamsSelect must have elements in [1:P]. P is the number of parameters of the model';
                if FESELECTgiven
                    msg = [msg ' and was inferred from the input FEParamsSelect.'];
                elseif FEDESIGNgiven
                    msg = [msg ' and was inferred from the input FEConstDesign.'];
                elseif FEGROUPDESIGNgiven
                    msg = [msg ' and was inferred from the input FEGroupDesign.'];
                elseif FEOBSDESIGNgiven
                    msg = [msg ' and was inferred from the input FEObsDesign.'];
                else
                    msg = [msg '. When no design for the fixed effects is specified, P was inferred from the number of fixed effects (F); by default there is one fixed effect for each model parameter. F was inferred from the number of elements in BETA0.'];
                end
                error('stats:nlmefit:conflictingPinREParamsSelect',msg)
            end
        end
        B = accumarray([RESELECT(:),(1:numel(RESELECT))'],1,[p,RE_r]);
    end
elseif REDESIGNgiven
    if RE_p ~=p
        if isnan(FE_p)
            if RE_p<p
                msg = 'The index vector FEParamsSelect must have elements in [1:P]. P is the number of parameters of the model and was inferred from the input REConstDesign.';
                error('stats:nlmefit:conflictingPinFEParamsSelect',msg)
            else
                A(end+1:RE_p,:) = 0;
                p = size(A,1);
            end
        else
            msg = 'The design matrix REConstDesign must have P rows. P is the number of parameters of the model';
            if FESELECTgiven
                msg = [msg ' and was inferred from the input FEParamsSelect.'];
            elseif FEDESIGNgiven
                msg = [msg ' and was inferred from the input FEConstDesign.'];
            elseif FEGROUPDESIGNgiven
                msg = [msg ' and was inferred from the input FEGroupDesign.'];
            elseif FEOBSDESIGNgiven
                msg = [msg ' and was inferred from the input FEObsDesign.'];
            else
                msg = [msg '. When no design for the fixed effects is specified, P was inferred from the number of fixed effects (F); by default there is one fixed effect for each model parameter. F was inferred from the number of elements in BETA0.'];
            end
            error('stats:nlmefit:conflictingPinREConstDesign',msg)
        end
    end
    B = REDESIGN;
elseif REGROUPDESIGNgiven
    if RE_p ~=p
        if isnan(FE_p)
            if RE_p<p
                msg = 'The index vector FEParamsSelect must have elements in [1:P]. P is the number of parameters of the model and was inferred from the input REGroupDesign.';
                error('stats:nlmefit:conflictingPinFEParamsSelect',msg)
            else
                A(end+1:RE_p,:) = 0;
                p = size(A,1);
            end
        else
            msg = 'The design matrices in REGroupDesign must have P rows. P is the number of parameters of the model';
            if FESELECTgiven
                msg = [msg ' and was inferred from the input FEParamsSelect.'];
            elseif FEDESIGNgiven
                msg = [msg ' and was inferred from the input FEConstDesign.'];
            elseif FEGROUPDESIGNgiven
                msg = [msg ' and was inferred from the input FEGroupDesign.'];
            elseif FEOBSDESIGNgiven
                msg = [msg ' and was inferred from the input FEObsDesign.'];
            else
                msg = [msg '. When no design for the fixed effects is specified, P was inferred from the number of fixed effects (F); by default there is one fixed effect for each model parameter. F was inferred from the number of elements in BETA0.'];
            end
            error('stats:nlmefit:conflictingPinREGroupDesign',msg)
        end
    end
    B = REGROUPDESIGN;
elseif REOBSDESIGNgiven
    if RE_p ~=p
        if isnan(FE_p)
            if RE_p<p
                msg = 'The index vector FEParamsSelect must have elements in [1:P]. P is the number of parameters of the model and was inferred from the input REObsDesign.';
                error('stats:nlmefit:conflictingPinFEParamsSelect',msg)
            else
                A(end+1:RE_p,:) = 0;
                p = size(A,1);
            end
        else
            msg = 'The design matrices in REObsDesign must have P rows. P is the number of parameters of the model';
            if FESELECTgiven
                msg = [msg ' and was inferred from the input FEParamsSelect.'];
            elseif FEDESIGNgiven
                msg = [msg ' and was inferred from the input FEConstDesign.'];
            elseif FEGROUPDESIGNgiven
                msg = [msg ' and was inferred from the input FEGroupDesign.'];
            elseif FEOBSDESIGNgiven
                msg = [msg ' and was inferred from the input FEObsDesign.'];
            else
                msg = [msg '. When no design for the fixed effects is specified, P was inferred from the number of fixed effects (F); by default there is one fixed effect for each model parameter. F was inferred from the number of elements in BETA0.'];
            end
            error('stats:nlmefit:conflictingPinREObsDesign',msg)
        end
    end
    B = REOBSDESIGN;
else % no RE specified, then use default
    B = eye(p);
end

% the number of random effects (r) was inferred in all cases from B except
% when FESELECT was a vector of indices, check that B does not conflict
r = size(B,2);
if isnan(PSI_r) % default PSI
    COVPATTERN = eye(r);
elseif PSI_r ~= r
    msg = 'CovPattern must have size R-by-R. R is the number of random effects in the model';
    if RESELECTgiven
        msg = [msg ' and was inferred from the input REParamsSelect.'];
    elseif REDESIGNgiven
        msg = [msg ' and was inferred from the input REConstDesign.'];
    elseif REGROUPDESIGNgiven
        msg = [msg ' and was inferred from the input REGroupDesign.'];
    elseif REOBSDESIGNgiven
        msg = [msg ' and was inferred from the input REObsDesign.'];
    else
        msg = [msg '. When no design for the random effects is specified there is one random effect for each model parameter (R=P).  Therefore CovPattern must have size P-by-P and the number of model parameters (P) was inferred from '];
        if FESELECTgiven
            msg = [msg 'the input FEParamsSelect.'];
        elseif FEDESIGNgiven
            msg = [msg 'the input FEConstDesign.'];
        elseif FEGROUPDESIGNgiven
            msg = [msg 'the input FEGroupDesign.'];
        elseif FEOBSDESIGNgiven
            msg = [msg 'the input FEObsDesign.'];
        else
            msg = 'CovPattern must have size R-by-R. R is the number of random effects in the model. When no design for the random and fixed effects is specified there is one random effect for each model parameter (R=P) and there is one fixed effect for each model parameter (P=F). Therefore CovPattern must have size F-by-F and the number of fixed effects (F) was inferred from the number of elements in BETA0.';
        end
    end
    error('stats:nlmefit:conflictingRinCovPattern',msg)
end

% Change COVPATTERN to a linear index selector of the upper triangular part
patternCov = find(triu(COVPATTERN));
thetaLen = numel(patternCov);

if size(B,2)==0
    error('stats:nlmefit:norandomeffects','At least one of the elements in PHI must have a random effect.')
end
if size(A,2)==0
    error('stats:nlmefit:nofixedeffects','At least one of the elements in PHI must have a fixed effect.')
end

if isempty(ParamTransform)
    ParamTransform = zeros(1,p);
elseif ~(isnumeric(ParamTransform) && isvector(ParamTransform) && ...
         numel(ParamTransform)==p  && all(ismember(ParamTransform,0:3)))
    error('stats:nlmefit:BadParamTransform',...
          'ParamTransform value must be a vector of %d values chosen from [0 1 2 3]',...
          p);
end

function e = error_ab(ab,y,f)
g = ab(1)+ab(2)*abs(f);
e = sum( 0.5*((y-f)./g).^2 + log(g) );

function stop = pnlsOutputFcn(outputFcn,Beta,ofopt,inneriter,innerstate)
ofopt.inner = struct('procedure','PNLS','iteration',inneriter,'state',innerstate);
stop = false;
for i = 1:numel(outputFcn) % call each output function
   stop = stop | outputFcn{i}(Beta,ofopt,'iter'); 
end

function stop = lmeOutputFcn(optimX,optimStruc,optimState,outputFcn,ofopt,Beta,Klike)
stop = false;
if ~strcmp(optimState,'interrupt') % Here we only care about the states init, iter and done
   ofopt.inner = struct('procedure','LME','iteration',optimStruc.iteration,'state',optimState);
   ofopt.fval = Klike-optimStruc.fval;
   ofopt.theta = optimX;
   for i = 1:numel(outputFcn) % call each output function
      stop = stop | outputFcn{i}(Beta,ofopt,'iter'); 
   end   
end

function stop = plmOutputFcn(optimX,optimStruc,optimState,outputFcn,ofopt,Klike,q)
stop = false;
if ~strcmp(optimState,'interrupt') % Here we only care about the states init, iter and done
   ofopt.inner = struct('procedure','PLM','iteration',optimStruc.iteration,'state',optimState); 
   ofopt.fval = Klike-optimStruc.fval;
   ofopt.theta = optimX(q+1:end);
   Beta = optimX(1:q);
   for i = 1:numel(outputFcn) % call each output function
      stop = stop | outputFcn{i}(Beta,ofopt,'iter'); 
   end       
end

function stop = callOutputFcns(outputFcn,Beta,ofopt,state)
% call each output function
stop = false;
for i = 1:numel(outputFcn)
    stop = stop | outputFcn{i}(Beta,ofopt,state);
end


