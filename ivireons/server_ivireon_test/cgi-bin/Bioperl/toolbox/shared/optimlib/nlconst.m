function [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS]= ...
    nlconst(funfcn,x,lb,ub,Ain,Bin,Aeq,Beq,confcn,OPTIONS,defaultopt,...
    chckdOpts,verbosity,flags,initVals,problemInfo,varargin)
%NLCONST Helper function to find the constrained minimum of a function
%   of several variables. Called by FMINCON, FGOALATTAIN, FSEMINF, and
%   FMINIMAX.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.4.25 $  $Date: 2009/12/02 06:46:26 $

% Initialize some parameters
FVAL = []; lambda_out = []; OUTPUT = []; lambdaNLP = []; GRADIENT = [];
caller = funfcn{2};

% Handle the output
outputfcn = optimget(OPTIONS,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    % Parse OutputFcn which is needed to support cell array syntax
    outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
end

stop = false;
xOrigShape = initVals.xOrigShape;

% Handle the plot functions
plotfcns = optimget(OPTIONS,'PlotFcns',defaultopt,'fast');
if isempty(plotfcns)
    haveplotfcn = false;
else
    haveplotfcn = true;
    % Parse PlotFcns which is needed to support cell array syntax
    plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
end

isFseminf = strcmp(caller,'fseminf');
if isFseminf
    % Separate arguments needed for SEMICON from those required for
    % the user objective and output functions
    vararginOutputfcn = varargin(3:end);
else
    vararginOutputfcn = varargin;
end

% Flag indicating whether to compute gradients in parfor or for loop
% If caller is fseminf, always compute in serial
serialFinDiff = ...
    isFseminf || strcmpi(optimget(OPTIONS,'UseParallel',defaultopt,'fast'),'never');

iter = 0;
XOUT = x(:);
% numberOfVariables must be the name of this variable
numberOfVariables = length(XOUT);
SD = ones(numberOfVariables,1);
Nlconst = 'nlconst';
bestf = Inf;

if isempty(confcn{1})
    constflag = 0;
else
    constflag = 1;
end
steplength = 1;
HESS = eye(numberOfVariables,numberOfVariables); % initial Hessian approximation.
done = false;
EXITFLAG = 1;

% Get options
tolX = optimget(OPTIONS,'TolX',defaultopt,'fast');
tolFun = optimget(OPTIONS,'TolFun',defaultopt,'fast');
tolCon = optimget(OPTIONS,'TolCon',defaultopt,'fast');
finDiffOpts.DiffMinChange = optimget(OPTIONS,'DiffMinChange',defaultopt,'fast');
finDiffOpts.DiffMaxChange = optimget(OPTIONS,'DiffMaxChange',defaultopt,'fast');
if finDiffOpts.DiffMinChange >= finDiffOpts.DiffMaxChange
    error('optim:nlconst:DiffChangesInconsistent', ...
        ['DiffMinChange options parameter is %0.5g, and DiffMaxChange is %0.5g.\n' ...
        'DiffMinChange must be strictly less than DiffMaxChange.'], ...
        finDiffOpts.DiffMinChange,finDiffOpts.DiffMaxChange)
end
finDiffOpts.TypicalX = chckdOpts.TypicalX(:);
finDiffOpts.FinDiffType = optimget(OPTIONS,'FinDiffType',defaultopt,'fast');
[sizes.xRows,sizes.xCols] = size(x); % input to finitedifferences()

DerivativeCheck = strcmp(optimget(OPTIONS,'DerivativeCheck',defaultopt,'fast'),'on');
maxFunEvals = optimget(OPTIONS,'MaxFunEvals',defaultopt,'fast');
maxIter = optimget(OPTIONS,'MaxIter',defaultopt,'fast');
relLineSrchBnd = optimget(OPTIONS,'RelLineSrchBnd',defaultopt,'fast');
relLineSrchBndDuration = optimget(OPTIONS,'RelLineSrchBndDuration',defaultopt,'fast');
hasBoundOnStep = ~isempty(relLineSrchBnd) && isfinite(relLineSrchBnd) && ...
    relLineSrchBndDuration > 0;
noStopIfFlatInfeas = strcmp(optimget(OPTIONS,'NoStopIfFlatInfeas',defaultopt,'fast'),'on');
phaseOneTotalScaling = strcmp(optimget(OPTIONS,'PhaseOneTotalScaling',defaultopt,'fast'),'on');

% In case the defaults were gathered from calling: optimset('fmincon'):
if ischar(maxFunEvals)
    if isequal(lower(maxFunEvals),'100*numberofvariables')
        maxFunEvals = 100*numberOfVariables;
    else
        error('optim:nlconst:InvalidMaxFunEvals', ...
            'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end

% Handle bounds as linear constraints
arglb = ~isinf(lb);
lenlb = length(lb); % maybe less than numberOfVariables due to old code
argub = ~isinf(ub);
lenub = length(ub);
boundmatrix = eye(max(lenub,lenlb),numberOfVariables);
if nnz(arglb) > 0
    lbmatrix = -boundmatrix(arglb,1:numberOfVariables);% select non-Inf bounds
    lbrhs = -lb(arglb);
else
    lbmatrix = []; lbrhs = [];
end
if nnz(argub) > 0
    ubmatrix = boundmatrix(argub,1:numberOfVariables);
    ubrhs=ub(argub);
else
    ubmatrix = []; ubrhs=[];
end

% For fminimax and fgoalattain, an extra "slack"
% variable (gamma) is added to create the minimax/goal attain
% objective function.  Add an extra element to lb/ub so
% that gamma is unconstrained but we can avoid out of index
% errors for lb/ub (when doing finite-differencing).
if  strcmp(caller,'fminimax') || strcmp(caller,'fgoalattain')
    lb(end+1) = -Inf;
    ub(end+1) = Inf;
end

% Create structure of flags for finitedifferences
finDiffFlags.fwdFinDiff = strcmpi(finDiffOpts.FinDiffType,'forward'); % Check for forward fin-diff
finDiffFlags.scaleObjConstr = false; % No scaling in this algorithm
finDiffFlags.chkFunEval = false; % Don't validate function values
finDiffFlags.isGrad = true; % Compute objective gradient, not Jacobian of a system
finDiffFlags.hasLBs = false(numberOfVariables,1);
finDiffFlags.hasUBs = false(numberOfVariables,1);
if ~isempty(lb)
    finDiffFlags.hasLBs = isfinite(lb); % Check for lower bounds
end
if ~isempty(ub)
    finDiffFlags.hasUBs = isfinite(ub); % Check for upper bounds
end

% Update constraint matrix and right hand side vector with bound constraints.
A = [lbmatrix;ubmatrix;Ain];
B = [lbrhs;ubrhs;Bin];
if isempty(A)
    A = zeros(0,numberOfVariables); B=zeros(0,1);
end
if isempty(Aeq)
    Aeq = zeros(0,numberOfVariables); Beq=zeros(0,1);
end

% Used for semi-infinite optimization:
s = nan; POINT =[]; NEWLAMBDA =[]; LAMBDA = []; NPOINT =[]; FLAG = 2;
OLDLAMBDA = [];

x(:) = XOUT;  % Set x to have user expected size
% Compute the objective function and constraints
f = initVals.f;
if isFseminf
    [ncineq,nceq,NPOINT,NEWLAMBDA,OLDLAMBDA,s] = ...
        semicon(x,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s,[],varargin{:});
else
    nceq = initVals.nceq; ncineq = initVals.ncineq;  % nonlinear constraints only
end 
% nctmp is used in the iterations to store the nonlinear inequalities
nctmp = ncineq;
nc = [nceq; ncineq];
c = [ Aeq*XOUT-Beq; nceq; A*XOUT-B; ncineq];

% Get information on the number and type of constraints.
non_eq = length(nceq);
non_ineq = length(ncineq);
lin_eq = size(Aeq,1);
lin_ineq = size(A,1);  % includes upper and lower bounds
eq = non_eq + lin_eq;
ineq = non_ineq + lin_ineq;
ncstr = ineq + eq;
% Now the start index in LAMBDA for the nonlinear inequalities can be
% assigned - required for semicon (fseminf)
startnlineq = ncstr - non_ineq + 1;
% Indices for finitedifferences() call. Make them column vectors
% so that, if they are empty, they'll keep the vectors they index into 
% column vectors
nonlEqs_idx = (1:non_eq)'; nonlIneqs_idx = (non_eq+1:non_eq+non_ineq)'; 

% Boolean displayActiveInequalities = true if and only if there exist
% either finite bounds or linear inequalities or nonlinear inequalities AND
% the caller is fmincon (see g210993).
% Used only for printing indices of active inequalities at the solution. 
displayActiveInequalities = ...
    (any(arglb) || any(argub) || size(Ain,1) > 0 || non_ineq > 0) && ...
    strcmp(caller, 'fmincon');

% Compute the initial constraint violation.
ga = [abs(c( (1:eq)' )) ; c( (eq+1:ncstr)' ) ];
if ~isempty(c)
    mg = max(ga);
else
    mg = 0;
end

if isempty(f)
    error('optim:nlconst:InvalidFUN', ...
        'FUN must return a non-empty objective function.')
end

% If the user-supplied nonlinear constraint gradients are sparse,
% we have to make them full after each call to the user functions
% and before passing them to qpsub---which would error otherwise.
if issparse(initVals.gnc) || issparse(initVals.gnceq)
    nonlinConstrGradIsSparse = true;
    initVals.gnc = full(initVals.gnc); initVals.gnceq = full(initVals.gnceq);
else
    nonlinConstrGradIsSparse = false;
end

% Get initial analytic gradients and check size.
if flags.grad || flags.gradconst
    if flags.grad
        gf_user = initVals.g;
    end
    if flags.gradconst
        gnc_user = [initVals.gnceq, initVals.gnc];   % Don't include A and Aeq yet
    else
        gnc_user = [];
    end
    if isempty(gnc_user) && isempty(nc)
        % Make gc compatible
        gnc = nc'; gnc_user = nc';
    end
end

OLDX = XOUT;
OLDC = c;
OLDgf = zeros(numberOfVariables,1);
gf = initVals.g;
gnc = [initVals.gnceq initVals.gnc];
OLDAN = zeros(ncstr,numberOfVariables);
LAMBDA = zeros(ncstr,1);
if isFseminf
    % LAMBDA is now initialised to the correct size. A further call to
    % could be made to semicon here using the initial settings for its
    % inputs, i.e. s = nan; POINT =[], NEWLAMBDA =[], LAMBDA = [], FLAG = 2
    % and OLDLAMBDA = []. This would set NEWLAMBDA, and hence lambdaNLP, to
    % have the correct size.

    % However, calling semicon in this way would just construct a NEWLAMBDA
    % in the following form:
    %
    % NEWLAMBDA = [zeros(lin_ineq, 1);zeros(num_finite_nonineq, 1);
    % zeros(num_seminfcon1, 1);.. zeros(num_seminfcon_ntheta, 1)] 
    %
    % At this point, this is identical to LAMBDA, so we just use LAMBDA to
    % initialize NEWLAMBDA here.
    NEWLAMBDA = LAMBDA;
    lambdaNLP = NEWLAMBDA;
else
    lambdaNLP = zeros(ncstr,1);
end
numFunEvals = 1;
numGradEvals = 1;

% Create a QP options structure for qpsub
% Iteration limit for sub-problem quadratic solver
qpmaxiter = optimget(OPTIONS,'MaxSQPIter',defaultopt,'fast');
if ischar(qpmaxiter)
    if isequal(lower(qpmaxiter),'10*max(numberofvariables,numberofinequalities+numberofbounds)')
        qpmaxiter = 10*max(numberOfVariables,ncstr-eq);
    else
        error('optim:nlconst:InvalidMaxSQPIter', ...
            'Option ''MaxSQPIter'' must be an integer value if not the default.')
    end
end    
qpoptions.MaxIter = qpmaxiter;
% Constraint tolerance for sub-problem solver
tolCon_subproblem = optimget(OPTIONS,'TolConSQP',defaultopt,'fast');
qpoptions.TolCon = min(tolCon_subproblem,tolCon);

% Prepare strings to give feedback to users on options they have or have not set.
% These are used in the exit messages.
optionFeedback = createOptionFeedback(OPTIONS);

% Display header information.
if flags.meritFunction == 1
    if isequal(caller,'fgoalattain')
        header = ...
            sprintf(['\n                 Attainment        Max     Line search     Directional \n',...
            ' Iter F-count        factor    constraint   steplength      derivative   Procedure ']);       
    else % fminimax
        header = ...
            sprintf(['\n                  Objective        Max     Line search     Directional \n',...
            ' Iter F-count         value    constraint   steplength      derivative   Procedure ']);
    end
    formatstrFirstIter = '%5.0f  %5.0f   %12.6g  %12.6g                                            %s';
    formatstr = '%5.0f  %5.0f   %12.4g  %12.4g %12.3g    %12.3g   %s  %s';
else % fmincon or fseminf is caller
    header = ...
        sprintf(['\n                                Max     Line search  Directional  First-order \n',...
        ' Iter F-count        f(x)   constraint   steplength   derivative   optimality Procedure ']);
    formatstrFirstIter = '%5.0f  %5.0f %12.6g %12.4g                                         %s';
    formatstr = '%5.0f  %5.0f %12.6g %12.4g %12.3g %12.3g %12.3g %s  %s';
end

how = '';
optimError = []; % In case we have convergence in 0th iteration, this needs a value.
optimScal = 1;
feasScal = 1;
%---------------------------------Main Loop-----------------------------
while ~done
    %----------------GRADIENTS----------------
    
    if constflag && ~flags.gradconst || ~flags.grad || DerivativeCheck
        % If there are nonlinear constraints and their gradients are not
        % supplied, or the objetive gradients are not supplied, or
        % derivative check is required, then compute finite difference
        % gradients.
        
        POINT = NPOINT;
        len_nc = length(nc);
        ncstr =  lin_eq + lin_ineq + len_nc;
        FLAG = 0; % For semi-infinite

        % Compute finite difference gradients
        if serialFinDiff         % Call serial finite-differences code
            if ~isFseminf
                if DerivativeCheck || (~flags.grad && ~flags.gradconst) % No objective gradients,
                    % no constraint gradients
                    [gf,gnc(:,nonlIneqs_idx),gnc(:,nonlEqs_idx),numEvals] = ...
                        finitedifferences(XOUT,funfcn{3},confcn{3},lb,ub,f, ...
                        nc(nonlIneqs_idx),nc(nonlEqs_idx),1:numberOfVariables, ...   
                        finDiffOpts,sizes,gf,gnc(:,nonlIneqs_idx), ...
                        gnc(:,nonlEqs_idx),finDiffFlags,[],varargin{:});
                elseif ~flags.gradconst % No constraint gradients; objective
                    % gradients supplied
                    [gf,gnc(:,nonlIneqs_idx),gnc(:,nonlEqs_idx),numEvals] = ...
                        finitedifferences(XOUT,[],confcn{3},lb,ub,f,nc(nonlIneqs_idx), ...
                        nc(nonlEqs_idx),1:numberOfVariables,finDiffOpts,sizes,gf, ...
                        gnc(:,nonlIneqs_idx),gnc(:,nonlEqs_idx),finDiffFlags,[],varargin{:});
                elseif ~flags.grad % No objective gradients, constraint gradients supplied
                    [gf,~,~,numEvals] = finitedifferences(XOUT,funfcn{3},[],lb,ub,f,[],[], ...
                        1:numberOfVariables,finDiffOpts,sizes,gf,[],[],finDiffFlags,[],varargin{:});
                end
            else
                if DerivativeCheck || (~flags.grad && ~flags.gradconst) % No objective gradients,
                    % no constraint gradients
                    [gf,gnc,NEWLAMBDA,OLDLAMBDA,s,numEvals] = finDiffFseminf(XOUT,x,funfcn, ...
                        lb,ub,f,nc,finDiffOpts.DiffMinChange,finDiffOpts.DiffMaxChange, ...
                        finDiffOpts.TypicalX,finDiffOpts.FinDiffType,'all',LAMBDA,NEWLAMBDA, ...
                        OLDLAMBDA,POINT,FLAG,s,startnlineq,varargin{:});
                    gnc = gnc'; % nlconst requires the transpose of the Jacobian
                elseif ~flags.gradconst % No constraint gradients; objective
                    % gradients supplied
                    [gf,gnc,NEWLAMBDA,OLDLAMBDA,s,numEvals] = finDiffFseminf(XOUT,x,[], ...
                        lb,ub,f,nc,finDiffOpts.DiffMinChange,finDiffOpts.DiffMaxChange, ...
                        finDiffOpts.TypicalX,finDiffOpts.FinDiffType,'all',LAMBDA,NEWLAMBDA, ...
                        OLDLAMBDA,POINT,FLAG,s,startnlineq,varargin{:});
                    gnc = gnc'; % nlconst requires the transpose of the Jacobian
                end
                % Case 'No objective gradients, constraint gradients supplied' is
                % not possible is fseminf
            end
        else      % Call parallel finite-differences code
            if DerivativeCheck || (~flags.grad && ~flags.gradconst) % No objective gradients,
                % no constraint gradients
                [gf,gnc(:,nonlIneqs_idx),gnc(:,nonlEqs_idx),numEvals] = ...
                    parfinitedifferences(XOUT,funfcn{3},confcn{3},lb,ub,f, ...
                    nc(nonlIneqs_idx),nc(nonlEqs_idx),1:numberOfVariables, ...
                    finDiffOpts,sizes,gf,gnc(:,nonlIneqs_idx), ...
                    gnc(:,nonlEqs_idx),finDiffFlags,[],varargin{:});
            elseif ~flags.gradconst % No constraint gradients; objective
                % gradients supplied
                [gf,gnc(:,nonlIneqs_idx),gnc(:,nonlEqs_idx),numEvals] = ...
                    parfinitedifferences(XOUT,[],confcn{3},lb,ub,f,nc(nonlIneqs_idx), ...
                    nc(nonlEqs_idx),1:numberOfVariables,finDiffOpts,sizes,gf, ...
                    gnc(:,nonlIneqs_idx),gnc(:,nonlEqs_idx),finDiffFlags,[],varargin{:});
            elseif ~flags.grad    % No objective gradients, constraint gradients supplied
                [gf,~,~,numEvals] = parfinitedifferences(XOUT,funfcn{3},[],lb,ub,f,[],[], ...
                    1:numberOfVariables,finDiffOpts,sizes,gf,[],[],finDiffFlags,[],varargin{:});
            end
        end
        
        % Gradient check
        if DerivativeCheck && (flags.grad || flags.gradconst) % analytic exists
            if flags.grad
                gfFD = gf;
                gf = gf_user;
                
                disp('Objective function derivative:')
                if isa(funfcn{4},'inline')
                    graderr(gfFD, gf, formula(funfcn{4}));
                else
                    graderr(gfFD, gf, funfcn{4});
                end
            end
            
            if flags.gradconst
                gncFD = gnc;
                gnc = gnc_user;
                
                if non_ineq > 0     % If there are nonlinear inequalities
                    disp('Nonlinear inequality constraint derivatives:')
                    if isa(confcn{4},'inline')
                        graderr(gncFD(:,non_eq+1:end), initVals.gnc, formula(confcn{4}));
                    else
                        graderr(gncFD(:,non_eq+1:end), initVals.gnc, confcn{4});
                    end
                end
                if non_eq > 0     % If there are nonlinear equalities
                    disp('Nonlinear equality constraint derivative:')
                    if isa(confcn{4},'inline')
                        graderr(gncFD(:,1:non_eq), initVals.gnceq, formula(confcn{4}));
                    else
                        graderr(gncFD(:,1:non_eq), initVals.gnceq, confcn{4});
                    end
                end

            end
            DerivativeCheck = 0;
        elseif flags.grad || flags.gradconst
            if flags.grad
                gf = gf_user;
            end
            if flags.gradconst
                gnc = gnc_user;
            end
        end % DerivativeCheck == 1 &  (flags.grad | flags.gradconst)
        
        FLAG = 1; % For semi-infinite
        numFunEvals = numFunEvals + numEvals;
    else % (~constflag | flags.grad) & flags.gradconst & no DerivativeCheck
        gnc = gnc_user;
        gf = gf_user;
    end
    
    % Now add in Aeq, and A
    if ~isempty(gnc)
        gc = [Aeq', gnc(:,1:non_eq), A', gnc(:,non_eq+1:non_ineq+non_eq)];
    elseif ~isempty(Aeq) || ~isempty(A)
        gc = [Aeq',A'];
    else
        gc = zeros(numberOfVariables,0);
    end
    AN = gc';
    
    % Iteration 0 is handled separately below
    if iter > 0 % All but 0th iteration ----------------------------------------
        % Compute the first order KKT conditions.
        if flags.meritFunction == 1
            % don't use this stopping test for fminimax or fgoalattain
            optimError = inf;
        else
            if isFseminf
                lambdaNLP = NEWLAMBDA;
            end
            normgradLag = norm(gf + AN'*lambdaNLP,inf);
            normcomp = norm(lambdaNLP(eq+1:ncstr).*c(eq+1:ncstr),inf);
            if isfinite(normgradLag) && isfinite(normcomp)
                optimError = max(normgradLag, normcomp);
            else
                optimError = inf;
            end
        end
        feasError = mg;
        
        % Print iteration information starting with iteration 1
        if verbosity > 2
            if flags.meritFunction == 1
                gamma = f;
                CurrOutput = sprintf(formatstr,iter,numFunEvals,gamma,mg,...
                    steplength,directionalDeriv,how,howqp);
                disp(CurrOutput)
            else
                CurrOutput = sprintf(formatstr,iter,numFunEvals,f,mg,...
                    steplength,directionalDeriv,optimError,how,howqp);
                disp(CurrOutput)
            end
        end
        % OutputFcn and PlotFcns call
        if haveoutputfcn || haveplotfcn
            [xOrigShape, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,problemInfo,XOUT, ...
                xOrigShape,'iter',iter,numFunEvals,f,nctmp,mg,steplength,gf,SD,directionalDeriv, ...
                flags.meritFunction,optimError,how,howqp,vararginOutputfcn{:});
            if stop  % Stop per user request.
                [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                    cleanUpInterrupt(xOrigShape,optimValues,caller,verbosity,flags.detailedExitMsg);
                return;
            end
        end
        
        %-------------TEST CONVERGENCE---------------
        % If NoStopIfFlatInfeas option is on, in addition to the objective looking
        % flat, also require that the iterate be feasible (among other things) to
        % detect that no further progress can be made.

        if noStopIfFlatInfeas
            noFurtherProgress = ( abs(steplength)*max(abs(SD)) < 2*tolX || (abs(prodGFSD) < 2*tolFun && ...
                feasError < tolCon*feasScal) ) && ( mg < tolCon || infeasIllPosedMaxSQPIter );
        else
            noFurtherProgress = false;
        end

        if optimError < tolFun*optimScal && feasError < tolCon*feasScal
            EXITFLAG = 1;
            done = true;
            outMessage = createExitMsg(Nlconst,EXITFLAG,verbosity > 1,flags.detailedExitMsg,caller, ...
                optimError,optionFeedback.TolFun,tolFun,feasError,optionFeedback.TolCon,tolCon);
            
            if verbosity > 1  % If the display is active, find active inequalities               
                if displayActiveInequalities
                    % Report active inequalities
                    [activeLb,activeUb,activeIneqLin,activeIneqNonlin] = ...
                        activeInequalities(c,tolCon,arglb,argub,lin_eq,non_eq,size(Ain));
                    
                    if any(activeLb) || any(activeUb) || any(activeIneqLin) || any(activeIneqNonlin)
                        fprintf('Active inequalities (to within options.TolCon = %g):\n',tolCon)
                        disp('  lower      upper     ineqlin   ineqnonlin')
                        printColumnwise(activeLb,activeUb,activeIneqLin,activeIneqNonlin);
                    else
                        disp('No active inequalities.')
                    end
                end
            end
        elseif noFurtherProgress
            [outMessage,EXITFLAG,lambdaNLP,optimError] = testConvergence(mg,SD,tolX,tolFun,tolCon,...
                verbosity,displayActiveInequalities,c,arglb,argub,lin_eq,non_eq,eq,ncstr,Ain,flags,...
                howqp,AN,gf,ACTIND,isFseminf,LAMBDA,optimScal,lambdaNLP,optimError,abs(prodGFSD), ...
                qpoptions.MaxIter,optionFeedback,flags.detailedExitMsg,caller);
            done = true;
        else % continue
            % NEED=[LAMBDA>0] | G>0
            if numFunEvals > maxFunEvals
                XOUT = MATX;
                f = OLDF;
                gf = OLDgf;
                EXITFLAG = 0;
                done = true;
                outMessage = createExitMsg(Nlconst,EXITFLAG,verbosity > 0,flags.detailedExitMsg,caller, ...
                    [],optionFeedback.MaxFunEvals,maxFunEvals);
            end
            if iter >= maxIter
                EXITFLAG = 0;
                done = true;
                % Call createExitMsg with exitflag = 10, for MaxIter violation
                outMessage = createExitMsg(Nlconst,10,verbosity > 0,flags.detailedExitMsg,caller, ...
                    [],optionFeedback.MaxIter,maxIter);
            end
        end
    else % ------------------------0th Iteration----------------------------------
        if verbosity > 2
            disp(header)
            % Print 0th iteration information (some columns left blank)
            if flags.meritFunction == 1
                gamma = f;
                CurrOutput = sprintf(formatstrFirstIter,iter,numFunEvals,gamma,mg,how);
                disp(CurrOutput)
            else
                if mg > tolCon
                    how = 'Infeasible start point';
                else
                    how = '';
                end
                CurrOutput = sprintf(formatstrFirstIter,iter,numFunEvals,f,mg,how);
                disp(CurrOutput)
            end
        end
        
        % Initialize the output and plot functions.
        if haveoutputfcn || haveplotfcn
            [xOrigShape, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,problemInfo, ...
                XOUT,xOrigShape,'init',iter,numFunEvals,f,nctmp,mg,[],gf,[],[],flags.meritFunction, ...
                [],[],[],vararginOutputfcn{:});
            if stop
                [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = cleanUpInterrupt(xOrigShape,optimValues, ...
                    caller,verbosity,flags.detailedExitMsg);
                return;
            end
            
            % OutputFcn call for 0th iteration
            [xOrigShape, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,problemInfo, ...
                XOUT,xOrigShape,'iter',iter,numFunEvals,f,nctmp,mg,[],gf,[],[],flags.meritFunction, ...
                [],how,'',vararginOutputfcn{:});
            if stop  % Stop per user request.
                [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                    cleanUpInterrupt(xOrigShape,optimValues,caller,verbosity,flags.detailedExitMsg);
                return;
            end            
        end % if haveoutputfcn || haveplotfcn
    end % if iter > 0
    
    % Continue if termination criteria do not hold or it is the 0th iteration-------------------------------------------
    if ~done
        how = '';
        iter = iter + 1;
        
        %-------------SEARCH DIRECTION---------------
        % For equality constraints make gradient face in
        % opposite direction to function gradient.
        for i = 1:eq
            schg = AN(i,:)*gf;
            if schg > 0
                AN(i,:) = -AN(i,:);
                c(i) = -c(i);
            end
        end
        
        if numGradEvals > 1  % Check for first call
            if flags.meritFunction ~= 5
                NEWLAMBDA = LAMBDA;
            end
            GNEW = gf + AN'*NEWLAMBDA;
            GOLD = OLDgf + OLDAN'*LAMBDA;
            YL = GNEW - GOLD;
            sdiff = XOUT - OLDX;
            
            % Make sure Hessian is positive definite in update.
            if YL'*sdiff < steplength^2*1e-3
                while YL'*sdiff < -1e-5
                    [YMAX,YIND] = min(YL.*sdiff);
                    YL(YIND) = YL(YIND)/2;
                end
                if YL'*sdiff < (eps*norm(HESS,'fro'))
                    how = ' Hessian modified twice';
                    FACTOR = AN'*c - OLDAN'*OLDC;
                    FACTOR = FACTOR.*(sdiff.*FACTOR>0).*(YL.*sdiff<=eps);
                    WT = 1e-2;
                    if max(abs(FACTOR))==0
                        FACTOR = 1e-5*sign(sdiff);
                    end
                    while YL'*sdiff < (eps*norm(HESS,'fro')) && WT < 1/eps
                        YL = YL + WT*FACTOR;
                        WT = WT*2;
                    end
                else
                    how = ' Hessian modified';
                end
            end
            
            if haveoutputfcn % Call output functions (we don't call plot functions with 'interrupt' flag)
                [unused1, unused2, stop] = callOutputAndPlotFcns(outputfcn,{},caller,problemInfo,XOUT, ...
                    xOrigShape,'interrupt',iter,numFunEvals,f,nctmp,mg,[],gf,[],[],flags.meritFunction, ...
                    [],[],[],vararginOutputfcn{:});
                if stop
                    [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                        cleanUpInterrupt(xOrigShape,optimValues,caller,verbosity,flags.detailedExitMsg);
                    return;
                end
            end
            
            %----------Perform BFGS Update If YL'S Is Positive---------
            if YL'*sdiff > eps
                HESS = HESS ...
                    +(YL*YL')/(YL'*sdiff)-((HESS*sdiff)*(sdiff'*HESS'))/(sdiff'*HESS*sdiff);
                % BFGS Update using Cholesky factorization  of Gill, Murray and Wright.
                % In practice this was less robust than above method and slower.
                %   R=chol(HESS);
                %   s2=R*S; y=R'\YL;
                %   W=eye(numberOfVariables,numberOfVariables)-(s2'*s2)\(s2*s2') + (y'*s2)\(y*y');
                %   HESS=R'*W*R;
            else
                how = ' Hessian not updated';
            end
        else % First call
            OLDLAMBDA = repmat(eps+gf'*gf,ncstr,1)./(sum(AN'.*AN')'+eps);
            ACTIND = 1:eq;
        end % if numGradEvals>1
        numGradEvals = numGradEvals + 1;
        
        LOLD = LAMBDA;
        OLDAN = AN;
        OLDgf = gf;
        OLDC = c;
        OLDF = f;
        OLDX = XOUT;
        XN = zeros(numberOfVariables,1);
        if flags.meritFunction>0 && flags.meritFunction<5
            % Minimax and attgoal problems have special Hessian:
            HESS(numberOfVariables,1:numberOfVariables) = zeros(1,numberOfVariables);
            HESS(1:numberOfVariables,numberOfVariables) = zeros(numberOfVariables,1);
            HESS(numberOfVariables,numberOfVariables) = 1e-8*norm(HESS,'inf');
            XN(numberOfVariables) = max(c); % Make a feasible solution for qp
        end
        
        GT = c;
        
        HESS = (HESS + HESS')*0.5;
        
        [SD,lambda,exitflagqp,outputqp,howqp,ACTIND] ...
            = qpsub(HESS,gf,AN,-GT,[],[],XN,eq,-1, ...
            Nlconst,size(AN,1),numberOfVariables,qpoptions,ACTIND,phaseOneTotalScaling);
        
        lambdaNLP(:,1) = 0;
        lambdaNLP(ACTIND) = lambda(ACTIND);
        lambda((1:eq)') = abs(lambda( (1:eq)' ));
        ga = [abs(c( (1:eq)' )) ; c( (eq+1:ncstr)' ) ];
        if ~isempty(c)
            mg = max(ga);
        else
            mg = 0;
        end
        
        if strncmp(howqp,'ok',2)
            howqp = '';
        end
        if ~isempty(how) && ~isempty(howqp)
            how = [how,'; '];
        end
        
        LAMBDA = lambda((1:ncstr)');
        OLDLAMBDA = max([LAMBDA';0.5*(LAMBDA+OLDLAMBDA)'])' ;
        
        % Compute directional derivative for the iterative display and for
        % the stopping test when noStopIfFlatInfeas is true
        sdNorm = max(norm(SD),eps);
        prodGFSD = gf'*SD;
        directionalDeriv = prodGFSD/sdNorm; 
        
        infeasIllPosedMaxSQPIter = strcmp(howqp,'infeasible') || ...
            strcmp(howqp,'ill posed') || strcmp(howqp,'MaxSQPIter');

        %---------------LINESEARCH--------------------
        MATX = XOUT;
        MATL = f + sum(OLDLAMBDA.*(ga>0).*ga) + 1e-30;
        
        if flags.meritFunction == 0 || flags.meritFunction == 5
            % This merit function looks for improvement in either the constraint
            % or the objective function unless the sub-problem is infeasible in which
            % case only a reduction in the maximum constraint is tolerated.
            % This less "stringent" merit function has produced faster convergence in
            % a large number of problems.
            if mg > 0
                MATL2 = mg;
            elseif f >=0
                MATL2 = -1/(f+1);
            else
                MATL2 = 0;
            end
            if ~infeasIllPosedMaxSQPIter && f < 0
                MATL2 = MATL2 + f - 1;
            end
        else
            % Merit function used for MINIMAX or ATTGOAL problems.
            MATL2 = mg + f;
        end
        if mg < eps && f < bestf
            bestf = f;
            bestx = XOUT;
            bestHess = HESS;
            bestgrad = gf;
            bestlambda = lambda;
            bestmg = mg;
            bestOptimError = optimError;
        end
        runLineSearch = true;
        trialsteplength = 2;
        while runLineSearch && numFunEvals < maxFunEvals
            trialsteplength = trialsteplength/2;
            if trialsteplength < 1e-4
                trialsteplength = -trialsteplength;
                
                % Semi-infinite may have changing sampling interval
                % so avoid too stringent check for improvement
                if flags.meritFunction == 5
                    trialsteplength = -trialsteplength;
                    MATL2 = MATL2 + 10;
                end
            end
            if hasBoundOnStep && (iter <= relLineSrchBndDuration)
                % Bound total displacement:
                % |steplength*SD(i)| <= relLineSrchBnd*max(|x(i)|, |typicalx(i)|)
                % for all i.
                indxViol = abs(trialsteplength*SD) > relLineSrchBnd*max(abs(MATX),abs(finDiffOpts.TypicalX));
                if any(indxViol)
                    trialsteplength = sign(trialsteplength)*min(  min( abs(trialsteplength), ...
                        relLineSrchBnd*max(abs(MATX(indxViol)),abs(finDiffOpts.TypicalX(indxViol))) ...
                        ./abs(SD(indxViol)) )  );
                end
            end
            
            % Test first-order approximation to function value decrease
            % and magnitude of the search direction to see if it is
            % worth continuing
            if ~noStopIfFlatInfeas
                if ( norm(SD,Inf) < 2*tolX || abs(trialsteplength*prodGFSD) < tolFun ) && ...
                        ( mg < tolCon || infeasIllPosedMaxSQPIter )
                    % Compute better approximation to lambdaNLP, check which
                    % convergence test is passed
                    [outMessage,EXITFLAG,lambdaNLP,optimError] = testConvergence(mg,SD,tolX,tolFun,tolCon,...
                        verbosity,displayActiveInequalities,c,arglb,argub,lin_eq,non_eq,eq,ncstr,Ain,flags,...
                        howqp,AN,gf,ACTIND,isFseminf,LAMBDA,optimScal,lambdaNLP,optimError, ...
                        abs(trialsteplength*prodGFSD),qpoptions.MaxIter,optionFeedback,flags.detailedExitMsg,caller);
                    done = true;
                    break;
                end
            end

            XOUT = MATX + trialsteplength*SD;   % Update current point
            x(:) = XOUT;
            
            if isFseminf
                f = feval(funfcn{3},x,varargin{3:end});
                
                [nctmp,nceqtmp,NPOINT,NEWLAMBDA,OLDLAMBDA,s] = ...
                    semicon(x,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,FLAG,s,startnlineq,varargin{:});
                nctmp = nctmp(:); nceqtmp = nceqtmp(:);
                non_ineq = length(nctmp);  % the length of nctmp can change
                ineq = non_ineq + lin_ineq;
                ncstr = ineq + eq;
                % Possibly changed constraints, even if same number,
                % so ACTIND may be invalid.
                ACTIND = 1:eq;
            else
                f = feval(funfcn{3},x,varargin{:});
                if constflag
                    [nctmp,nceqtmp] = feval(confcn{3},x,varargin{:});
                    nctmp = nctmp(:); nceqtmp = nceqtmp(:);
                else
                    nctmp = []; nceqtmp=[];
                end
            end
            numFunEvals = numFunEvals + 1;
            
            nc = [nceqtmp(:); nctmp(:)];
            c = [Aeq*XOUT-Beq; nceqtmp(:); A*XOUT-B; nctmp(:)];
            
            ga = [abs(c( (1:eq)' )) ; c( (eq+1:length(c))' )];
            if ~isempty(c)
                mg = max(ga);
            else
                mg = 0;
            end
            
            MERIT = f + sum(OLDLAMBDA.*(ga>0).*ga);
            if flags.meritFunction == 0 || flags.meritFunction == 5
                if mg > 0
                    MERIT2 = mg;
                elseif f >=0
                    MERIT2 = -1/(f+1);
                else
                    MERIT2 = 0;
                end
                if ~infeasIllPosedMaxSQPIter && f < 0
                    MERIT2 = MERIT2 + f - 1;
                end
            else
                MERIT2 = mg + f;
            end
            if haveoutputfcn % Call output functions (we don't call plot functions with 'interrupt' flag)
                [unused1, unused2, stop] = callOutputAndPlotFcns(outputfcn,{},caller,problemInfo,XOUT, ...
                    xOrigShape,'interrupt',iter,numFunEvals,f,nctmp,mg,[],gf,[],[],flags.meritFunction, ...
                    [],[],[],vararginOutputfcn{:});
                if stop
                    [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = ...
                        cleanUpInterrupt(xOrigShape,optimValues,caller,verbosity,flags.detailedExitMsg);
                    return;
                end
            end
            % If MERIT (MATL) or MERIT2 (MATL2) are very big numbers then the result of this test 
            % will always be false (line-search will terminate). 
            runLineSearch = (MERIT2 > MATL2) && (MERIT > MATL);
        end  % line search loop
        %------------Finished Line Search-------------
        steplength = trialsteplength;   % Update steplength
        if ~done
            if flags.meritFunction ~= 5
                mf = abs(steplength);
                LAMBDA = mf*LAMBDA + (1-mf)*LOLD;
            end
            
            x(:) = XOUT;
            switch funfcn{1} % evaluate function gradients
                case 'fun'
                    % do nothing, will use finite difference.
                case 'fungrad'
                    if isFseminf
                        [f,gf_user] = feval(funfcn{3},x,varargin{3:end});
                    else
                        [f,gf_user] = feval(funfcn{3},x,varargin{:});
                    end
                    gf_user = gf_user(:);
                    numGradEvals = numGradEvals + 1;
                    numFunEvals = numFunEvals + 1;
                case 'fun_then_grad'
                    if isFseminf
                        gf_user = feval(funfcn{4},x,varargin{3:end});
                    else
                        gf_user = feval(funfcn{4},x,varargin{:});
                    end
                    gf_user = gf_user(:);
                    numGradEvals = numGradEvals + 1;
                otherwise
                    error('optim:nlconst:UndefinedCalltypeInFMINCON', ...
                        'Undefined calltype in FMINCON.');
            end
            
            % Evaluate constraint gradients
            switch confcn{1}
                case 'fun'
                    gnceq=[]; gncineq=[];
                case 'fungrad'
                    [nctmp,nceqtmp,gncineq,gnceq] = feval(confcn{3},x,varargin{:});
                    nctmp = nctmp(:); nceqtmp = nceqtmp(:);
                    numGradEvals=numGradEvals+1;
                    % Objective/constraint evaluation counted above in evaluation of obj block
                case 'fun_then_grad'
                    [gncineq,gnceq] = feval(confcn{4},x,varargin{:});
                    numGradEvals=numGradEvals+1;
                case ''
                    nctmp=[]; nceqtmp =[];
                    gncineq = zeros(numberOfVariables,length(nctmp));
                    gnceq = zeros(numberOfVariables,length(nceqtmp));
                otherwise
                    error('optim:nlconst:UndefinedCalltypeInFMINCON', ...
                        'Undefined calltype in FMINCON.');
            end
            % Make sure the Jacobian matrix is full before passing it
            % to qpsub
            if nonlinConstrGradIsSparse
                gncineq = full(gncineq); gnceq = full(gnceq);
            end
            gnc_user = [gnceq, gncineq];
            gc = [Aeq', gnceq, A', gncineq];
        end % if ~done (convergence check after qpsub)
    end % if ~done (optimality check after qpsub AND linesearch)
end % while ~done

% Gradient is in the variable gf
GRADIENT = gf;

% If a better solution was found earlier, use it:
if f > bestf
    XOUT = bestx;
    f = bestf;
    HESS = bestHess;
    GRADIENT = bestgrad;
    lambda = bestlambda;
    mg = bestmg;
    gf = bestgrad;
    optimError = bestOptimError;
end

FVAL = f;
x(:) = XOUT;

if haveoutputfcn || haveplotfcn
    [xOrigShape, optimValues] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,problemInfo,XOUT,xOrigShape,'done', ...
        iter,numFunEvals,f,nctmp,mg,steplength,gf,SD,directionalDeriv,flags.meritFunction,optimError, ...
        how,howqp,vararginOutputfcn{:});
    % Do not check value of 'stop' as we are done with the optimization
    % already.
end

OUTPUT.iterations = iter;
OUTPUT.funcCount = numFunEvals;
OUTPUT.lssteplength = steplength;
OUTPUT.stepsize = abs(steplength) * norm(SD);
OUTPUT.algorithm = 'medium-scale: SQP, Quasi-Newton, line-search';
if flags.meritFunction == 1
    OUTPUT.firstorderopt = [];
else
    OUTPUT.firstorderopt = optimError;
end
OUTPUT.constrviolation = mg;
OUTPUT.message = outMessage;

[lin_ineq,Acol] = size(Ain);  % excludes upper and lower

lambda_out.lower=zeros(lenlb,1);
lambda_out.upper=zeros(lenub,1);

lambda_out.eqlin = lambdaNLP(1:lin_eq);
ii = lin_eq ;
lambda_out.eqnonlin = lambdaNLP(ii+1: ii+ non_eq);
ii = ii+non_eq;
lambda_out.lower(arglb) = lambdaNLP(ii+1 :ii+nnz(arglb));
ii = ii + nnz(arglb) ;
lambda_out.upper(argub) = lambdaNLP(ii+1 :ii+nnz(argub));
ii = ii + nnz(argub);
lambda_out.ineqlin = lambdaNLP(ii+1: ii + lin_ineq);
ii = ii + lin_ineq ;
lambda_out.ineqnonlin = lambdaNLP(ii+1 : end);

% NLCONST finished
%--------------------------------------------------------------------------
function [xOrigShape, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,problemInfo, ...
    x,xOrigShape,state,iter,numFunEvals,f,cineqval,mg,steplength,gf,SD,dirDeriv,meritFunctionType, ...
    optimError,how,howqp,varargin)
% CALLOUTPUTANDPLOTFCN assigns values to the struct OptimValues and then calls the
% outputfcn/plotfcns.
%
% The input STATE can have the values 'init','iter','interrupt', or 'done'.
%
% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.

optimValues.iteration = iter;
optimValues.funccount = numFunEvals;
% fval for fgoalattain and fminimax functions needs to be calculated
if strcmp(caller,'fmincon') || strcmp(caller,'fseminf')
    optimValues.fval = f;
elseif strcmp(caller,'fgoalattain')
    optimValues.fval = getUserVectorFval(cineqval,f,problemInfo);
    optimValues.attainfactor = f;
elseif strcmp(caller,'fminimax')
    optimValues.fval = getUserVectorFval(cineqval,f,problemInfo);
    optimValues.maxfval = f;    
end
optimValues.constrviolation = mg;
optimValues.lssteplength = steplength;
optimValues.stepsize = abs(steplength) * norm(SD);
optimValues.directionalderivative = dirDeriv;
optimValues.gradient = gf;
optimValues.searchdirection = SD;
if meritFunctionType == 1
    optimValues.firstorderopt = [];
else
    optimValues.firstorderopt = optimError;
end
optimValues.procedure = [how,'  ',howqp];
% Set x to have user expected size
if strcmp(caller,'fmincon') || strcmp(caller,'fseminf')
    xOrigShape(:) = x;
else % fgoalattain and fminimax
    xOrigShape(:) = x(1:end-1); % remove artificial variable
end

stop = false;
if ~isempty(outputfcn)
    switch state
        case {'iter','init','interrupt'}
            stop = callAllOptimOutputFcns(outputfcn,xOrigShape,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,xOrigShape,optimValues,state,varargin{:});
        otherwise
            error('optim:nlconst:UnknownStateInCALLOUTPUTANDPLOTFCNS', ...
                'Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
% Call plot functions
if ~isempty(plotfcns)
    switch state
        case {'iter','init'}
            stop = callAllOptimPlotFcns(plotfcns,xOrigShape,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimPlotFcns(plotfcns,xOrigShape,optimValues,state,varargin{:});
        otherwise
            error('optim:nlconst:UnknownStateInCALLOUTPUTANDPLOTFCNS', ...
                'Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
%--------------------------------------------------------------------------
function [x,FVAL,lambda_out,EXITFLAG,OUTPUT,GRADIENT,HESS] = cleanUpInterrupt( ...
                    xOrigShape,optimValues,caller,verbosity,detailedExitMsg)
% CLEANUPINTERRUPT updates or sets all the output arguments of NLCONST when the optimization
% is interrupted.  The HESSIAN and LAMBDA are set to [] as they may be in a
% state that is inconsistent with the other values since we are
% interrupting mid-iteration.

if strcmp(caller,'fmincon') || strcmp(caller,'fseminf')
    x = xOrigShape;
else % fgoalattain or fminimax
    % fgoalattain and fminimax expect that nlconst return
    % (a) a column vector, and (b) with additional artificial
    % scalar variable (which gets discarded on return)
    dummyVariable = 0;
    x = [xOrigShape(:); dummyVariable];
end

FVAL = optimValues.fval;
EXITFLAG = -1;
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.stepsize = optimValues.stepsize;
OUTPUT.lssteplength = optimValues.lssteplength;
OUTPUT.algorithm = 'medium-scale: SQP, Quasi-Newton, line-search';
OUTPUT.firstorderopt = optimValues.firstorderopt;
OUTPUT.constrviolation = optimValues.constrviolation;
OUTPUT.message = createExitMsg('nlconst',EXITFLAG,verbosity > 0,detailedExitMsg,caller);
GRADIENT = optimValues.gradient;
HESS = []; % May be in an inconsistent state
lambda_out = []; % May be in an inconsistent state

%--------------------------------------------------------------------------
function [activeLb,activeUb,activeIneqLin,activeIneqNonlin] = ...
    activeInequalities(c,tol,arglb,argub,linEq,nonlinEq,linIneq)
% ACTIVEINEQUALITIES returns the indices of the active inequalities
% and bounds.
% INPUT:
% c                 vector of constraints and bounds (see nlconst main code)
% tol               tolerance to determine when an inequality is active
% arglb, argub      boolean vectors indicating finite bounds (see nlconst
%                   main code)
% linEq             number of linear equalities
% nonlinEq          number of nonlinear equalities
% linIneq           number of linear inequalities
%
% OUTPUT
% activeLB          indices of active lower bounds
% activeUb          indices of active upper bounds
% activeIneqLin     indices of active linear inequalities
% activeIneqNonlin  indices of active nonlinear inequalities
%

% We check wether a constraint is active or not using '< tol'
% instead of '<= tol' to be onsistent with nlconst main code,
% where feasibility is checked using '<'.
finiteLb = nnz(arglb); % number of finite lower bounds
finiteUb = nnz(argub); % number of finite upper bounds

indexFiniteLb = find(arglb); % indices of variables with LB
indexFiniteUb = find(argub); % indices of variables with UB

% lower bounds
i = linEq + nonlinEq; % skip equalities

% Boolean vector that indicates which among the finite
% bounds is active
activeFiniteLb = abs(c(i + 1 : i + finiteLb)) < tol;

% indices of the finite bounds that are active
activeLb = indexFiniteLb(activeFiniteLb);

% upper bounds
i = i + finiteLb;

% Boolean vector that indicates which among the finite
% bounds is active
activeFiniteUb = abs(c(i + 1 : i + finiteUb)) < tol;

% indices of the finite bounds that are active
activeUb = indexFiniteUb(activeFiniteUb);

% linear inequalities
i = i + finiteUb;
activeIneqLin = find(abs(c(i + 1 : i + linIneq)) < tol);
% nonlinear inequalities
i = i + linIneq;
activeIneqNonlin = find(abs(c(i + 1 : end)) < tol);

%--------------------------------------------------------------------------
function printColumnwise(a,b,c,d)
% PRINTCOLUMNWISE prints vectors a, b, c, d (which
% in general have different lengths) column-wise.
%
% Example: if a = [1 2], b = [4 6 7], c = [], d = [8 11 13 15]
% then this function will produce the output (without the headers):
%
% a  b  c   d
%-------------
% 1  4      8
% 2  6     11
%    7     13
%          15
%
length1 = length(a); length2 = length(b);
length3 = length(c); length4 = length(d);

for k = 1:max([length1,length2,length3,length4])
    % fprintf stops printing numbers as soon as it encounters [].
    % To avoid this, we convert all numbers to string
    % (fprintf doesn't stop when it comes across the blank
    % string ' '.)
    if k <= length1
        value1 = num2str(a(k));
    else
        value1 = ' ';
    end
    if k <= length2
        value2 = num2str(b(k));
    else
        value2 = ' ';
    end
    if k <= length3
        value3 = num2str(c(k));
    else
        value3 = ' ';
    end
    if k <= length4
        value4 = num2str(d(k));
    else
        value4 = ' ';
    end
    fprintf('%5s %10s %10s %10s\n',value1,value2,value3,value4);
end

%--------------------------------------------------------------------------
function [outMessage,EXITFLAG,lambda,optimError] = testConvergence(mg,SD,tolX,tolFun,tolCon,...
    verbosity,displayActiveInequalities,c,arglb,argub,lin_eq,non_eq,eq,ncstr,Ain,flags,...
    howqp,AN,gf,ACTIND,isFseminf,LAMBDA,optimScal,lambdaQPSUB,optimErr,dirDeriv, ...
    maxSQPIter,optionFeedback,detailedExitMsg,caller)

% The algorithm can make no more progress.  If feasible, compute
% the new up-to-date Lagrange multipliers (with new gradients)
% and recompute the KKT error.  Then output appropriate termination
% message.
if mg < tolCon
    if flags.meritFunction == 1
        optimError = Inf;
        lambda = lambdaQPSUB;
    else
        if ~isFseminf
            lambda = zeros(ncstr,1);
            
            warningstate1 = warning('off','MATLAB:nearlySingularMatrix');
            warningstate2 = warning('off','MATLAB:singularMatrix');
            warningstate3 = warning('off','MATLAB:rankDeficientMatrix');
            lambda(ACTIND) = -AN(ACTIND,:)'\gf;
            warning(warningstate1);
            warning(warningstate2);
            warning(warningstate3);
            
            lambda(eq+1:ncstr) = max(0,lambda(eq+1:ncstr));
        else % the caller is fseminf
            % Use LAMBDA from latest successful step taken (instead of NEWLAMBDA)
            lambda = LAMBDA;
            % Adjust the number of constraints accordingly just for the calculation of 
            % complementarity (normcomp)
            ncstr = min(numel(lambda),numel(c));
        end
        normgradLag = norm(gf + AN'*lambda,inf);
        normcomp = norm(lambda(eq+1:ncstr).*c(eq+1:ncstr),Inf);
        if isfinite(normgradLag) && isfinite(normcomp)
            optimError = max(normgradLag, normcomp);
        else
            optimError = Inf;
        end
    end
    
    if optimError < tolFun*optimScal
        EXITFLAG = 1;
        outMessage = createExitMsg('nlconst',EXITFLAG,verbosity > 1,detailedExitMsg,caller, ...
            optimError,optionFeedback.TolFun,tolFun,mg,optionFeedback.TolCon,tolCon);
    elseif norm(SD,Inf) < 2*tolX
        EXITFLAG = 4;
        outMessage = createExitMsg('nlconst',EXITFLAG,verbosity > 1,detailedExitMsg,caller, ...
            norm(SD,Inf),optionFeedback.TolX,tolX,mg,optionFeedback.TolCon,tolCon);
    else
        EXITFLAG = 5;
        outMessage = createExitMsg('nlconst',EXITFLAG,verbosity > 1,detailedExitMsg,caller, ...
            dirDeriv,optionFeedback.TolFun,tolFun,mg,optionFeedback.TolCon,tolCon);
    end
    
    if verbosity > 1
        if displayActiveInequalities % If the display is active, find active inequalities
            % Report active inequalities
            [activeLb,activeUb,activeIneqLin,activeIneqNonlin] = ...
                activeInequalities(c,tolCon,arglb,argub,lin_eq,non_eq,size(Ain));
            if any(activeLb) || any(activeUb) || any(activeIneqLin) || any(activeIneqNonlin)
                fprintf('Active inequalities (to within options.TolCon = %g):\n', tolCon)
                disp('  lower      upper     ineqlin   ineqnonlin')
                printColumnwise(activeLb,activeUb,activeIneqLin,activeIneqNonlin);
            else
                disp('No active inequalities.')
            end
        end
    end
else                         % if mg >= tolCon
    if strcmp(howqp,'MaxSQPIter')
        % Call createExitMsg with createExitMsgexitflag = -20 for MaxSQPIter and infeasible
        outMessage = createExitMsg('nlconst',-20,verbosity > 0,detailedExitMsg,caller, ...
            [],optionFeedback.MaxSQPIter,maxSQPIter,mg,optionFeedback.TolCon,tolCon);
    elseif norm(SD,Inf) < 2*tolX
        % Call createExitMsg with createExitMsgexitflag = -24 for small search direction and infeasible
        outMessage = createExitMsg('nlconst',-24,verbosity > 0,detailedExitMsg,caller, ...
            norm(SD,Inf),optionFeedback.TolX,tolX,mg,optionFeedback.TolCon,tolCon);
    else
        % Call createExitMsg with createExitMsgexitflag = -25 for small directional derivative and infeasible
        outMessage = createExitMsg('nlconst',-25,verbosity > 0,detailedExitMsg,caller, ...
            dirDeriv,optionFeedback.TolFun,tolFun,mg,optionFeedback.TolCon,tolCon);
    end
    EXITFLAG = -2;
    % Set these output quantities to the last that we computed
    optimError = optimErr;
    lambda = lambdaQPSUB;
end                          % of "if mg < tolCon"

%============================== getUserVectorFval ============================
function fval = getUserVectorFval(cval,lambda,problemInfo)
% Get the user function value (vector-value function) for fgoalattain and
% fminimax functions from the inequality constraint vector 'cval' that is
% calculated in 'goalcon'. The vector 'cval' has nonlinear constraints
% followed by goal functions and hard goals (weight = 0 for fgoalattain). 
% This function returns the vector 'fval' containing the value of the goal 
% functions.

% Determine the number of hard goals
nHardConstr = problemInfo.nHardConstraints;
weight = problemInfo.weight;
goal = problemInfo.goal;
% Number of goal functions
nUserObjective = length(goal);
fval = zeros(nUserObjective,1);
% Total number of constraints
nTotalConstr = length(cval);

% Calculate the values of goal functions from cval
start = (nTotalConstr - nUserObjective - nHardConstr) + 1;
finish = (nTotalConstr - nHardConstr);
j = 1; % index for fval (different from cval when they are not equal in length)
for i = start:finish
    fval(j) = (cval(i) + lambda)*weight(j) + goal(j);
    j = j + 1;
end
