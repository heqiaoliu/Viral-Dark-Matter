function [XOUT,costFun,JAC,EXITFLAG,OUTPUT,msgData] = levenbergMarquardt(funfcn,XOUT,verbosity,...
    options,defaultopt,costFun,JAC,caller,lambda,detailedExitMsg,optionFeedback,varargin)
%levenbergMarquardt Levenberg-Marquardt solver of non-linear least squares problems.
%   levenbergMarquardt solves problems of the form:
%   min sum {FUN(X).^2} 
%      x
%   using the Levenberg-Marquardt algorithm.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/02 06:46:25 $

% ------------Initialization----------------
[xRows,xCols] = size(XOUT);  % Get original size of X
sizes.xRows = xRows; sizes.xCols = xCols;
XOUT = XOUT(:);
nVar = length(XOUT);
OUTPUT = [];
iter = 0;

% Handle the output
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    % Parse OutputFcn which is needed to support cell array syntax for OutputFcn.
    outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
end

% Handle the output
plotfcns = optimget(options,'PlotFcns',defaultopt,'fast');
if isempty(plotfcns)
    haveplotfcn = false;
else
    haveplotfcn = true;
    % Parse PlotFcns which is needed to support cell array syntax for PlotFcns.
    plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
end
% 1st iteration does not show last column norm(step) because it's undefined
formatStrFirstIter = ' %5.0f       %5.0f   %13.6g    %12.3g %12.6g\n';
formatstr          = ' %5.0f       %5.0f   %13.6g    %12.3g %12.6g   %12.6g\n';

% options
gradflag =  strcmp(optimget(options,'Jacobian',defaultopt,'fast'),'on');
tolX = optimget(options,'TolX',defaultopt,'fast');
tolFun = optimget(options,'TolFun',defaultopt,'fast');
finDiffOpts.DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
finDiffOpts.DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');
finDiffOpts.TypicalX = optimget(options,'TypicalX',defaultopt,'fast') ;
if ischar(finDiffOpts.TypicalX)
   % finDiffOpts.TypicalX should be 'ones(numberofvariables,1)'
   finDiffOpts.TypicalX = ones(nVar,1);
end

% Create structure of flags for finitedifferences
finDiffFlags.fwdFinDiff = true; % Always forward fin-diff
finDiffFlags.scaleObjConstr = false; % No scaling
finDiffFlags.chkFunEval = false; % Don't validate function values
finDiffFlags.isGrad = false; % Compute Jacobian, not gradient
finDiffFlags.hasLBs = false(nVar,1); % No lower bounds
finDiffFlags.hasUBs = false(nVar,1); % No upper bounds

maxFunEvals = optimget(options,'MaxFunEvals',defaultopt,'fast');
maxIter = optimget(options,'MaxIter',defaultopt,'fast');
% If MaxFunEvals is default string, set to default setting for LM
% Also accept string 100*numberOfVariables (previous default)
if strcmpi(maxFunEvals,'200*numberofvariables')
    maxFunEvals = 200*nVar;
elseif strcmpi(maxFunEvals,'100*numberofvariables')
    maxFunEvals = 100*nVar;
end

% Convert values to full to avoid having a sparse sum of squares
costFun = full(costFun); 
nfun = length(costFun);
numFunEvals = 1;
sumSq = costFun'*costFun;  % Sum of squares
zeroPad = zeros(nVar,1);   % Padding for LM step computation
successfulStep = true; % Flag indicating that JAC needs to be computed this loop iteration
% Initialize the step variable for the OutputFcn and PlotFcn
step = [];

% Compute initial Jacobian via finite-differences for derivative check or
% if JAC is empty.
if ~gradflag || DerivativeCheck
    JACFD = zeros(nfun,nVar); % pre-allocate derivative array
    [JACFD,~,~,numEvals] = finitedifferences(XOUT,funfcn{3},[],[],[],costFun, ...
        [],[],1:nVar,finDiffOpts,sizes,JACFD,[],[],finDiffFlags,[],varargin{:});
    numFunEvals = numFunEvals + numEvals;

    % Gradient check
    if DerivativeCheck && gradflag
        if isa(funfcn{3},'inline')
            % If using inlines, the gradient is in funfcn{4}
            graderr(JACFD, JAC, formula(funfcn{4})); %
        else
            % Otherwise fun/grad in funfcn{3}
            graderr(JACFD, JAC,  funfcn{3});
        end
    else
        JAC = JACFD;
    end
end

gradF = JAC'*costFun;
sqrtEps = sqrt(eps);
% Initial 1st order optimality with safeguard to prevent value of 0, used in stopping tests
relFactor = max(norm(gradF,Inf),sqrtEps); 
% tolOpt: tolerance used when checking the 1st-order optimality
tolOpt = 1e-4 * tolFun;

jacIsSparse = issparse(JAC);  % Flag indicating that JAC is a sparse matrix
scaleStep = strcmpi(optimget(options,'ScaleProblem',defaultopt,'fast'),'jacobian');
if scaleStep
    diagJacTJac = sum(JAC.^2,1)'; % Compute diagonal of J'*J, used for scaling in LM step
end

% Display first iteration information
if verbosity > 1
    fprintf( ...
        ['\n                                        First-Order                    Norm of \n', ...
        ' Iteration  Func-count    Residual       optimality      Lambda           step\n']);
    fprintf(formatStrFirstIter,iter,numFunEvals,sumSq,norm(gradF,Inf),lambda);
end

if haveoutputfcn || haveplotfcn
    directionalDeriv = [];  % Initialize the directional-derivative
    % Initialize the output function.
    [optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,reshape(XOUT,xRows,xCols),...
        'init',iter,numFunEvals,costFun,sumSq,[],gradF,[],lambda,varargin{:});
    if stop
        [costFun,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(optimValues,caller);
        msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller};
        return;
    end
    % Call for iteration 0
    [optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,reshape(XOUT,xRows,xCols),...
        'iter',iter,numFunEvals,costFun,sumSq,[],gradF,[],lambda,varargin{:});
    if stop
        [costFun,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(optimValues,caller);
        msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller};
        return;
    end
end

% Check to see if the initial point is optimal
[done,EXITFLAG,msgData,iter] = testConvergence(detailedExitMsg,optionFeedback, ...
    verbosity,caller,gradF,tolOpt,relFactor,tolFun,iter);

while ~done  
    % Compute scaling matrix if needed
    if ~scaleStep   % Unscaled Jacobian
        if ~jacIsSparse
            scaleMat = sqrt(lambda)*eye(nVar);
        else
            scaleMat = sqrt(lambda)*speye(nVar);
        end
    else
        if ~jacIsSparse
            scaleMat = diag(sqrt(lambda*diagJacTJac));
        else
            scaleMat = spdiags(sqrt(lambda*diagJacTJac),0,nVar,nVar);
        end
    end

    % Compute LM step
    if successfulStep
        % Augmented Jacobian
        AugJac = [JAC; scaleMat];
        AugRes = [-costFun; zeroPad]; % Augmented residual
    else
        % If previous step failed, replace only the part of the matrix that has changed
        AugJac(nfun+1:end,:) = scaleMat;
    end
    % Disable the warnings about conditioning for singular and
    % nearly singular matrices
    warningstate1 = warning('off','MATLAB:nearlySingularMatrix');
    warningstate2 = warning('off','MATLAB:singularMatrix');
    warningstate3 = warning('off','MATLAB:rankDeficientMatrix');

    step = AugJac \ AugRes;              % Compute LM step   

    % Restore the warning states to their original settings
    warning(warningstate1)
    warning(warningstate2)
    warning(warningstate3)

    trialX = XOUT + step;                  % Update X with computed step

    % Evaluate objective functions and Jacobian, if given by user
    
    % If the previous step wasn't successful, we don't need to evaluate the
    % Jacobian until we're sure that the latest step is a good one. Only
    % evaluate the cost function in that case.
    if ~successfulStep || strcmpi(funfcn{1},'fun')
        trialCostFun = feval(funfcn{3},reshape(trialX,xRows,xCols),varargin{:});
    else
        switch funfcn{1}
           %case 'fun' computed above
            case 'fungrad'
                [trialCostFun,JAC] = feval(funfcn{3},reshape(trialX,xRows,xCols),varargin{:});
            case 'fun_then_grad'
                trialCostFun = feval(funfcn{3},reshape(trialX,xRows,xCols),varargin{:});
                JAC = feval(funfcn{4},reshape(trialX,xRows,xCols),varargin{:});
        end
    end
    trialCostFun = full(trialCostFun(:));          % Convert to full to prevent error with iterative display
    numFunEvals = numFunEvals + 1;
    trialSumSq = trialCostFun'*trialCostFun;             % Updated sum of squares
    
    if trialSumSq < sumSq               % If we've reduced the sum squared error
        costFun = trialCostFun;         % Save a copy of the last successful cost function
        XOUT = trialX;                  % Update X
        if successfulStep
            lambda = max(0.1*lambda,eps);    % Reduce LM parameter, only if previous step was good        
        end
        % If Jacobian given by user, and previous step(s) were
        % unsuccessful, we have yet to compute the Jacobian, so compute
        % it here.
        if gradflag && ~successfulStep   
            switch funfcn{1}
               % If funfcn == 'fun', JAC will be updated when it is computed by finite-differences                    
                case 'fungrad'
                    [~,JAC] = feval(funfcn{3},reshape(trialX,xRows,xCols),varargin{:});
                case 'fun_then_grad'
                    JAC = feval(funfcn{4},reshape(trialX,xRows,xCols),varargin{:});
             end
        elseif ~gradflag
            [JAC,~,~,numEvals] = finitedifferences(XOUT,funfcn{3},[],[],[],costFun, ...
                [],[],1:nVar,finDiffOpts,sizes,JAC,[],[],finDiffFlags,[],varargin{:});
            numFunEvals = numFunEvals + numEvals;
        end
        
        if scaleStep  % Recompute scaling factor from latest Jacobian information
            diagJacTJac = sum(JAC.^2,1)'; % Compute diagonal of J'*J, used for scaling in LM step
        end
        successfulStep = true;        % Successful step, new Jacobian needs to be computed 
        gradF = JAC'*costFun;     
        
        % Print iterative display
        if verbosity > 1
            fprintf(formatstr,iter,numFunEvals,trialSumSq,norm(gradF,Inf),lambda,norm(step));
        end
        
        if haveoutputfcn || haveplotfcn                 % Call Output or PlotFcn 
            directionalDeriv = gradF'*step/norm(step);  % Compute directional derivative for OutputFcn
            [optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,reshape(XOUT,xRows,xCols),...
                'iter',iter,numFunEvals,costFun,trialSumSq,directionalDeriv,gradF,step,lambda,varargin{:});
            if stop
                [costFun,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(optimValues,caller);
                msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller};
                return;
            end
        end
        
        % Check Termination Criteria
        [done,EXITFLAG,msgData,iter] = testConvergence(detailedExitMsg,optionFeedback, ...
            verbosity,caller,gradF,tolOpt,relFactor,tolFun,iter,XOUT,trialSumSq,tolX,sqrtEps, ...
            step,sumSq,numFunEvals,maxFunEvals,maxIter);

        sumSq = trialSumSq;         % Update sum of squares after convergence test
    else                                
        lambda = 10*lambda;              % Increase LM parameter
        successfulStep = false;          % Unsuccessful step, no need to re-compute the Jacobian

        % LM parameter too large, cannot proceed or too many function evals
        if lambda > 1e16 
            EXITFLAG = -3;
            msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller, ...
                lambda,'',0};
            done = true;
        elseif numFunEvals > maxFunEvals
            EXITFLAG = 0;
            msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller, ...
                [],optionFeedback.MaxFunEvals,maxFunEvals};
            done = true;
        end        
    end % if newF < oldF
end  % while ~done

XOUT = reshape(XOUT,xRows,xCols);
OUTPUT.iterations    = iter;
OUTPUT.funcCount     = numFunEvals;
OUTPUT.stepsize      = norm(step);
OUTPUT.cgiterations  = [];
OUTPUT.firstorderopt = norm(gradF,Inf);
OUTPUT.algorithm     = 'Levenberg-Marquardt';

if haveoutputfcn || haveplotfcn
    callOutputAndPlotFcns(outputfcn,plotfcns,caller,XOUT,'done',iter,numFunEvals, ...
        costFun,sumSq,directionalDeriv,gradF,step,lambda,varargin{:});
    % Optimization done, so ignore "stop"
end

%--------------------------------------------------------------------------
function [optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,caller,...
    xOutputfcn,state,iter,numFunEvals,costFun,newF,gdnew,gradF,step,lambda,varargin)
% CALLOUTPUTANDPLOTFCNS assigns values to the struct OptimValues and then calls the
% outputfcn/plotfcns.  reshape(XOUT,xRows,xCols),
%
% state - can have the values 'init','iter', or 'done'. 

% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.
optimValues.iteration = iter;
optimValues.funccount = numFunEvals;
optimValues.stepsize = norm(step);
optimValues.directionalderivative = gdnew;
optimValues.gradient = gradF;
optimValues.firstorderopt = norm(gradF,Inf);
optimValues.searchdirection = step;
optimValues.lambda = lambda;
if isequal(caller,'fsolve') 
   optimValues.fval = costFun; 
else % lsqnonlin, lsqcurvefit 
   optimValues.residual = costFun; 
   optimValues.resnorm = newF; 
end 

stop = false;
% Call output function
if ~isempty(outputfcn)
    switch state
        case {'iter','init'}
            stop = callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:});
    end
end
% Call plot functions
if ~isempty(plotfcns)
    switch state
        case {'iter','init'}
            stop = callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:});
    end
end
%--------------------------------------------------------------------------
function [costFun,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(optimValues,caller)

% costFun can be either 'fval' (fsolve) or 'residual'
if isequal(caller,'fsolve') 
    costFun = optimValues.fval;
else 
    costFun = optimValues.residual;
end
EXITFLAG = -1; 
OUTPUT.iterations    = optimValues.iteration;
OUTPUT.funcCount     = optimValues.funccount;
OUTPUT.stepsize      = optimValues.stepsize;
OUTPUT.cgiterations  = [];
OUTPUT.firstorderopt = [];
OUTPUT.algorithm     = 'Levenberg-Marquardt';

JAC = []; % May be in an inconsistent state

%--------------------------------------------------------------------------
function [done,EXITFLAG,msgData,iter] = testConvergence(detailedExitMsg, ...
    optionFeedback,verbosity,caller,gradF,tolOpt,relFactor,tolFun,iter,XOUT, ...
    newF,tolX,sqrtEps,step,oldF,numFunEvals,maxFunEvals,maxIter)
% testConvergence tests all of the termination criteria for the
% Levenberg-Marquardt algorithm. This function is called at each successful
% step of the algorithm. In addition, testConvergence is called before the
% main loop of levenbergMarquardt to only check the initial point for
% optimality. In this case, only 6 inputs are required.

% Initialize these quantities in case no criteria are met.
done = false;
EXITFLAG = [];
msgData = {};

if norm(gradF,Inf) < tolOpt * relFactor
    EXITFLAG = 1;
    if iter == 0
        msgFlag = 100;
    else
        msgFlag = EXITFLAG;
    end
    % Call createExitMsg with createExitMsgExitflag = 100 if x0 is
    % optimal, otherwise createExitMsgExitflag = 1
    msgData = {'levenbergMarquardt',msgFlag,verbosity > 0,detailedExitMsg,caller, ...
        norm(gradF,Inf)/relFactor,optionFeedback.TolFun,tolOpt};
    done = true;
elseif iter > 0
    if norm(step) < tolX*(sqrtEps + norm(XOUT))
        EXITFLAG = 4;        
        msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller, ...
            norm(step)/(sqrtEps+norm(XOUT)),optionFeedback.TolX,tolX};
        done = true;
    elseif abs(newF - oldF) <= tolFun*oldF
        EXITFLAG = 3;        
        msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller, ...
            abs(newF-oldF)/oldF,optionFeedback.TolFun,tolFun};
        done = true;
    elseif numFunEvals > maxFunEvals
        EXITFLAG = 0;        
        msgData = {'levenbergMarquardt',EXITFLAG,verbosity > 0,detailedExitMsg,caller, ...
            [],optionFeedback.MaxFunEvals,maxFunEvals};
        done = true;
    elseif iter > maxIter
        EXITFLAG = 0;        
        msgData = {'levenbergMarquardt',10,verbosity > 0,detailedExitMsg,caller, ...
            [],optionFeedback.MaxIter,maxIter};
        done = true;
    else
        iter = iter + 1;
    end
else
    iter = iter + 1;
end
