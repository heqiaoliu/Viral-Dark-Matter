function [x,f,grad,hessian,exitflag,output] = ...
    fminusub(funfcn,x,options,defaultopt,f,grad,hessian,flags,varargin)
% FMINUSUB finds the minimizer x of a function funfcn of several variables. 
% On input, x is the initial guess, f and grad are the values of the
% function and the gradient, respectively, both evaluated at the initial
% guess x. The input variable hessian is the initial quasi-Newton matrix.
% On output, x is the computed solution, f and grad are the values of the
% function and the gradient, evaluated at the computed solution x. The
% output variable hessian is the final quasi-Newton matrix.
 
%   Copyright 1990-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.15 $  $Date: 2009/12/02 06:46:03 $

%
% Initialization
%
verbosity = flags.verbosity;
detailedExitMsg = flags.detailedExitMsg;

[xRows,xCols] = size(x); % Store original user-supplied shape
sizes.xRows = xRows; sizes.xCols = xCols;
x = x(:);                % Reshape x to a column vector
numberOfVariables = length(x);
initialHessIsAScalar = [];
exitflagLnSrch = [];     % define in case x0 is solution and lineSearch never called
dir = [];                % define for last call to outputFcn in case x0 is solution
formatstr = ' %5.0f       %5.0f    %13.6g  %13.6g   %12.3g  %s';

% Line search parameters: rho < 1/2 and rho < sigma < 1. Typical values are
% rho = 0.01 and sigma = 0.9.
rho = 0.01; sigma = 0.9;
fminimum = f - 1e8*(1+abs(f));

% Read in options
gradflag =  strcmp(optimget(options,'GradObj',defaultopt,'fast'),'on');
TolX = optimget(options,'TolX',defaultopt,'fast');

HessUpdate = optimget(options,'HessUpdate',defaultopt,'fast'); 
InitialHessType = optimget(options,'InitialHessType',defaultopt,'fast');
InitialHessMatrix = optimget(options,'InitialHessMatrix',defaultopt,'fast');

if isequal(lower(InitialHessType),'user-supplied') 
    if isempty(InitialHessMatrix)    
        warning('optim:fminusub:ResettingToInitialHessType', ...
            ['options.InitialHessType = ''user-supplied'' but options.InitialHessMatrix = [];\n' ... 
            ' resetting InitialHessType = ''identity''.'])
        InitialHessType = 'identity';    
    else
        % Determine size of InitialHessMatrix
        [ihRows,ihCols] = size(InitialHessMatrix);
        if (ihRows==numberOfVariables && ihCols==1) || (ihRows==1 && ihCols==numberOfVariables)
          initialHessIsAScalar = false;
        elseif ihRows==1 && ihCols==1
          initialHessIsAScalar = true;          
        else
          error('optim:fminusub:InitialHessMatrixSize', ...
                  ['Option ''InitialHessMatrix'' must be a scalar or a vector', ...
                  ' of length numberOfVariables.'])
        end    
    end
end

TolFun = optimget(options,'TolFun',defaultopt,'fast');
finDiffOpts.DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
finDiffOpts.DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');
finDiffOpts.TypicalX = optimget(options,'TypicalX',defaultopt,'fast') ;
if ischar(finDiffOpts.TypicalX)
    if isequal(lower(finDiffOpts.TypicalX),'ones(numberofvariables,1)')
        finDiffOpts.TypicalX = ones(numberOfVariables,1);
    else
        error('optim:fminusub:TypicalXNumOrDefault', ... 
              'Option ''TypicalX'' must be a numeric value if not the default.')
    end
end
checkoptionsize('TypicalX', size(finDiffOpts.TypicalX), numberOfVariables);
finDiffOpts.FinDiffType = optimget(options,'FinDiffType',defaultopt,'fast'); 

maxFunEvals = optimget(options,'MaxFunEvals',defaultopt,'fast');
maxIter = optimget(options,'MaxIter',defaultopt,'fast');

if ischar(maxFunEvals)
    if isequal(lower(maxFunEvals),'100*numberofvariables')
        maxFunEvals = 100*numberOfVariables;
    else
        error('optim:fminusub:MaxFunEvalsIntOrDefault', ...
              'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end

% Create structure of flags for finitedifferences
finDiffFlags.fwdFinDiff = strcmpi(finDiffOpts.FinDiffType,'forward'); % Check for forward fin-diff
finDiffFlags.scaleObjConstr = false; % No scaling
finDiffFlags.chkFunEval = false; % Don't validate function values
finDiffFlags.isGrad = true; % Compute gradient, not Jacobian
finDiffFlags.hasLBs = false(numberOfVariables,1); % No lower bounds
finDiffFlags.hasUBs = false(numberOfVariables,1); % No upper bounds

% Prepare strings to give feedback to users on options they have or have not set.
% These are used in the exit messages.
optionFeedback = createOptionFeedback(options);

% Output function
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = reshape(x,xRows,xCols); % Last x passed to outputfcn; has the input x's shape
    % Parse OutputFcn which is needed to support cell array syntax for
    % OutputFcn.
    outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
end

% Plot functions
plotfcns = optimget(options,'PlotFcns',defaultopt,'fast');
if isempty(plotfcns)
    haveplotfcn = false;
else
    haveplotfcn = true;
    xOutputfcn = reshape(x,xRows,xCols); % Last x passed to outputfcn; has the input x's shape
    % Parse PlotFcns which is needed to support cell array syntax for
    % PlotFcns.
    plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
end

funcCount = 1; % function evaluated in FMINUNC
iter = 0;

% Initialize output alpha: if x0 is the solution, alpha = [] is returned in
% output structure
alpha = []; 
fOld = []; gOld = []; 
hessUpdateMsg = [];       

% Compute finite difference gradient at initial point, if needed
if ~gradflag || DerivativeCheck
    gradFd = zeros(numberOfVariables,1); % pre-allocate finite-difference gradient
    [gradFd,~,~,numEvals] = finitedifferences(x,funfcn{3},[],[],[],f,[],[], ...
        1:numberOfVariables,finDiffOpts,sizes,gradFd,[],[],finDiffFlags,[],varargin{:});
    funcCount = funcCount + numEvals;
    
    % Gradient check
    if DerivativeCheck && gradflag
        if isa(funfcn{4},'inline')
            graderr(gradFd,grad,formula(funfcn{4}));
        else
            graderr(gradFd,grad,funfcn{4});
        end
    else
        grad = gradFd;
    end
end

% Norm of initial gradient, used in stopping tests
g0Norm = norm(grad,Inf); 

% Initialize the output function.
if haveoutputfcn || haveplotfcn
  [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,'init',iter,funcCount, ...
        f,[],grad,[],varargin{:});
  if stop
    [x,f,exitflag,output,grad,H] = cleanUpInterrupt(xOutputfcn,optimValues,verbosity,detailedExitMsg);
    return;
  end
end

% Print output header
if verbosity > 2
  disp(sprintf(['                                                        First-order \n',...
  ' Iteration  Func-count       f(x)        Step-size       optimality']));
end

% Display 0th iteration quantities
if verbosity > 2
  disp(sprintf(' %5.0f       %5.0f    %13.6g                  %12.3g',iter,funcCount,f,g0Norm));
end

% OutputFcn call 0th iteration
if haveoutputfcn || haveplotfcn
  [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,'iter',iter,funcCount, ...
        f,[],grad,[],varargin{:});
  if stop  % Stop per user request.
    [x,f,exitflag,output,grad,H] = cleanUpInterrupt(xOutputfcn,optimValues,verbosity,detailedExitMsg);
    return;
  end
end

% Check convergence at initial point
[done,exitflag,outMessage] = initialTestStop(g0Norm,TolFun,detailedExitMsg,verbosity,optionFeedback); 

% Form initial inverse Hessian approximation
if ~done                  
  H = initialQuasiNewtonMatrix(InitialHessType,InitialHessMatrix, ...
                    HessUpdate,initialHessIsAScalar,numberOfVariables);
end                       
%                     
% Main loop
%
while ~done
    iter = iter + 1;
    
    % Form search direction
    dir = -H*grad;
    dirDerivative = grad'*dir; 
    
    % Perform line search along dir
    alpha1 = 1;
    if iter == 1 
        alpha1 = min(1/g0Norm,1); 
    end  
    fOld = f; gradOld = grad; alphaOld = alpha;

    % During line search, don't exceed the overall total maxFunEvals.
    maxFunEvalsLnSrch = maxFunEvals - funcCount;
    [alpha,f,grad,exitflagLnSrch,funcCountLnSrch] = ... 
          lineSearch(funfcn,x,numberOfVariables,dir,f,dirDerivative, ...
          alpha1,rho,sigma,fminimum,maxFunEvalsLnSrch,eps(max(1,abs(f))), ...
          finDiffOpts,finDiffFlags,sizes,grad,varargin{:});
    funcCount = funcCount + funcCountLnSrch;
    
    % Break if line search didn't finish successfully
    if exitflagLnSrch < 0 && f >= fOld
      % Restore previous values
      alpha = alphaOld;
      f = fOld;
      grad = gradOld;
      break
    end
    
    % Update iterate
    deltaX = alpha*dir;
    x = x + deltaX;
    
    % Display iteration quantities
    if verbosity > 2
      % Print header periodically
      if mod(iter,20) == 0
        disp(sprintf(['                                                        First-order \n', ...
            ' Iteration  Func-count       f(x)        Step-size       optimality']));        
      end
        disp(sprintf(formatstr,iter,funcCount,f,alpha,norm(grad,inf),hessUpdateMsg))
    end

    % OutputFcn call
    if haveoutputfcn || haveplotfcn
      [xOutputfcn,optimValues,stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,'iter',iter,funcCount, ...
           f,alpha,grad,dir,varargin{:});      
      if stop  % Stop per user request.
        [x,f,exitflag,output,grad,H] = ...
                cleanUpInterrupt(xOutputfcn,optimValues,verbosity,detailedExitMsg);
        return;
      end
    end
        
    [done,exitflag,outMessage] = testStop(x,deltaX,iter,funcCount,TolX,TolFun,maxIter, ...
                                     maxFunEvals,grad,g0Norm,exitflagLnSrch,detailedExitMsg, ...
                                     verbosity,optionFeedback);
    if ~done
        % Update quasi-Newton matrix.
        [H,hessUpdateMsg] = updateQuasiNewtonMatrix(H,deltaX,grad-gradOld,HessUpdate, ...
                                            InitialHessType,iter);
    end
    
end % of while

% Handle cases in which line search didn't terminate normally
if funcCount >= maxFunEvals
  exitflag = 0;
  outMessage = createExitMsg('fminusub',exitflag,verbosity > 0,detailedExitMsg, ...
      'fminunc',[],optionFeedback.MaxFunEvals,maxFunEvals);
elseif exitflagLnSrch == -2
  exitflag = 5;
  outMessage = createExitMsg('fminusub',exitflag,verbosity > 1,detailedExitMsg, ...
      'fminunc');
end
  
% Compute finite-difference Hessian only if asked for in output
if flags.computeHessian
  if verbosity > 1
      if ~gradflag
        fprintf('\nComputing finite-difference Hessian using user-supplied objective function.\n')          
        % If problem large, estimating the finite difference Hessian with
        % only function values may take time
        if numberOfVariables >= 100
          fprintf(' This may take a substantial amount of time.\n')
        end
      end
  end
  hessian = finDiffHessian(funfcn,x,xRows,xCols,numberOfVariables,gradflag,f, ...
                           grad,finDiffOpts,varargin{:});
end  

% OutputFcn call
if haveoutputfcn || haveplotfcn
  callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,'done',iter,funcCount, ...
      f,alpha,grad,dir,varargin{:});      
end   

x = reshape(x,xRows,xCols); % restore user shape
output.iterations = iter;
output.funcCount = funcCount;
output.stepsize = alpha;
output.firstorderopt = norm(grad,inf);
output.algorithm = 'medium-scale: Quasi-Newton line search';
output.message = outMessage;
%--------------------------------------------------------------------------
function [done,exitflag,msg] = testStop(x,deltaX,iter,funcCount,TolX, ...
                        TolFun,maxIter,maxFunEvals,grad,g0Norm,exitflagLnSrch, ...
                        detailedExitMsg,verbosity,optionFeedback)
%
% TESTSTOP checks if the stopping conditions are met

if norm(grad,Inf) < TolFun*(1+g0Norm)
     done = true;
     exitflag = 1;
     msg = createExitMsg('fminusub',exitflag,verbosity > 1,detailedExitMsg, ...
         'fminunc',norm(grad,Inf)/(1+g0Norm),optionFeedback.TolFun,TolFun);
elseif norm(deltaX ./ (1 + abs(x)),inf) < TolX
    done = true;
    exitflag = 2;
    msg = createExitMsg('fminusub',exitflag,verbosity > 1,detailedExitMsg, ...
        'fminunc',norm(deltaX ./ (1 + abs(x)),inf),optionFeedback.TolX,TolX);
elseif exitflagLnSrch == -2 % Line search could not reduce function value any more
    done = true;    % Exit Message will be handled outside of main loop
    exitflag = 5;
    msg = '';
elseif funcCount >= maxFunEvals
     done = true;   % Exit Message will be handled outside of main loop
     exitflag = 0;
     msg = '';
elseif iter > maxIter 
     done = true;
     exitflag = 0;
     % Call createExitMsg with createExitMsgExitflag = 10 for MaxIter exceeded
     msg = createExitMsg('fminusub',10,verbosity > 0,detailedExitMsg, ...
         'fminunc',[],optionFeedback.MaxIter,maxIter);
else
   exitflag = [];
   done = false;
   msg = [];
end

%-------------------------------------------------------------------------------
function [done,exitflag,msg] = initialTestStop(g0Norm,TolFun,detailedExitMsg,verbosity,optionFeedback)
%
% INITIALTESTSTOP checks if the starting point satisfies a convergence
% criterion.

if g0Norm < TolFun
  % Call createExitMsg with exitflag = 100 for an optimal x0
  msg = createExitMsg('fminusub',100,verbosity > 1,detailedExitMsg, ...
      'fminunc',g0Norm,optionFeedback.TolFun,TolFun);
  done = true;
  exitflag = 1;
else
  exitflag = [];
  done = false;
  msg = [];
end   

%--------------------------------------------------------------------------
function H = initialQuasiNewtonMatrix(InitialHessType,InitialHessMatrix, ...
                           HessUpdate,initialHessIsAScalar,numberOfVariables)
% INITIALQNMATRIX sets the initial quasi-Newton matrix that approximates
% the inverse to the Hessian.

% Unless running steepest-descent, compute initial H
if ~strncmp(HessUpdate,'s',1)                         % not steepest-descent
    if isequal(lower(InitialHessType),'identity') || ...
        isequal(lower(InitialHessType),'scaled-identity')
        % Built-in initial quasi-Newton matrix. In 'scaled-identity' case,
        % the scaling occurs right after the end of the 1st iteration.
        H = eye(numberOfVariables);
    else
        % User-supplied initial approximation to the Hessian. We invert 
        % this initial matrix because we maintain an approximation H to the
        % inverse of the Hessian. The check for InitialHessMatrix > 0 was
        % already done in optimset.m
        if initialHessIsAScalar
            % InitialHessMatrix is a scalar
            H = 1/InitialHessMatrix*eye(numberOfVariables);
        else
            % InitialHessMatrix is a vector
            H = diag(1./InitialHessMatrix);
        end
    end
else
    % Steepest-descent: H is always the identity
    H = eye(numberOfVariables);
end

%--------------------------------------------------------------------------
function [H,msg] = updateQuasiNewtonMatrix(H,deltaX,deltaGrad,HessUpdate, ...
                                           InitialHessType,iter)
% UPDATEQUASINEWTONMATRIX updates the quasi-Newton matrix that approximates
% the inverse to the Hessian.

deltaXDeltaGrad = deltaX'*deltaGrad;
updateOk = deltaXDeltaGrad >= sqrt(eps)*max( eps,norm(deltaX)*norm(deltaGrad) );
if iter == 1 && strncmp(InitialHessType,'scaledIdentity',2)
    if updateOk
        % Reset the initial quasi-Newton matrix to a scaled identity aimed
        % at reflecting the size of the inverse true Hessian
        H = deltaXDeltaGrad/(deltaGrad'*deltaGrad)*eye(length(deltaX));
    end
end

if strncmp(HessUpdate,'b',1)
  if updateOk
    HdeltaGrad = H*deltaGrad;
    % BFGS update
    H = H + (1 + deltaGrad'*HdeltaGrad/deltaXDeltaGrad) * ...
        deltaX*deltaX'/deltaXDeltaGrad - (deltaX*HdeltaGrad' + ... 
        HdeltaGrad*deltaX')/deltaXDeltaGrad;
    msg = '';
  else
    msg = 'skipped update';
  end
elseif strncmp(HessUpdate,'d',1)
  if updateOk
    HdeltaGrad = H*deltaGrad;
    % DFP update
    H = H + deltaX*deltaX'/deltaXDeltaGrad - HdeltaGrad*HdeltaGrad'/(deltaGrad'*HdeltaGrad);    
    msg = '';
  else
    msg = 'skipped update';
  end  
elseif strncmp(HessUpdate,'s',1)
  % Steepest descent
  H = eye(length(deltaX));
  msg = '';  
else
    ME = MException('optim:fminusub:UnknownHessUpdate', ...
        'Unknown value of option HessUpdate.');
    throwAsCaller(ME)
end

%--------------------------------------------------------------------------  
function [Hessian,functionCalls] = finDiffHessian(funfcn,x,xRows,xCols, ...
            numberOfVariables,useGrad,f,grad,finDiffOpts,varargin) 
% FINDIFFHESSIAN calculates the numerical Hessian of funfcn evaluated at x
% using finite differences. 

Hessian = zeros(numberOfVariables);

if useGrad
  % Define stepsize 
  CHG = sqrt(eps)*sign(x).*max(abs(x),1); 

  % Make sure step size lies within DiffMinChange and DiffMaxChange
  CHG = sign(CHG+eps).*min(max(abs(CHG),finDiffOpts.DiffMinChange),finDiffOpts.DiffMaxChange);
  % Calculate finite difference Hessian by columns with the user-supplied
  % gradient. We use the forward difference formula.
  %
  % Hessian(:,j) = 1/h(j) * [grad(x+h(j)*ej) - grad(x)]               (1)
  for j = 1:numberOfVariables
    xplus = x; 
    xplus(j) = x(j) + CHG(j);
    % evaluate gradPlus 
    switch funfcn{1}          
     case 'fun'
      error('optim:fminusub:WrongUseGrad','Gradient not supplied but useGrad set to true.')
     case 'fungrad'
      [fplus,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
      gradPlus = gradPlus(:);
     case 'fun_then_grad'
      gradPlus = feval(funfcn{4},reshape(xplus,xRows,xCols),varargin{:});
      gradPlus = gradPlus(:);
     otherwise
      error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
    end    
    % Calculate jth column of Hessian
    Hessian(:,j) = (gradPlus - grad) / CHG(j);
  end
  % Symmetrize the Hessian
  Hessian = 0.5*(Hessian + Hessian');
  
  functionCalls = numberOfVariables;
else % of 'if useGrad'
  % Define stepsize  
  CHG = eps^(1/4)*sign(x).*max(abs(x),1);  
  
  % Make sure step size lies within DiffMinChange and DiffMaxChange
  CHG = sign(CHG+eps).*min(max(abs(CHG),finDiffOpts.DiffMinChange),finDiffOpts.DiffMaxChange);
  % Calculate the upper triangle of the finite difference Hessian element 
  % by element, using only function values. The forward difference formula 
  % we use is
  %
  % Hessian(i,j) = 1/(h(i)*h(j)) * [f(x+h(i)*ei+h(j)*ej) - f(x+h(i)*ei) 
  %                          - f(x+h(j)*ej) + f(x)]                   (2) 
  % 
  % The 3rd term in (2) is common within each column of Hessian and thus
  % can be reused. We first calculate that term for each column and store
  % it in the row vector fplus_array.
  fplus_array = zeros(1,numberOfVariables);
  for j = 1:numberOfVariables
    xplus = x;
    xplus(j) = x(j) + CHG(j);
    % evaluate  
    switch funfcn{1}
     case 'fun'
      fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});       
     case 'fungrad'
      [fplus,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     case 'fun_then_grad'  
      fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     otherwise
      error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
    end    
    fplus_array(j) = fplus;
  end
  
  for i = 1:numberOfVariables
    % For each row, calculate the 2nd term in (4). This term is common to
    % the whole row and thus it can be reused within the current row: we
    % store it in fplus_i.
    xplus = x;
    xplus(i) = x(i) + CHG(i);
    % evaluate  
    switch funfcn{1}
     case 'fun'
      fplus_i = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});        
     case 'fungrad'
      [fplus_i,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     case 'fun_then_grad'  
      fplus_i = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
     otherwise
      error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
    end     
 
    for j = i:numberOfVariables   % start from i: only upper triangle
      % Calculate the 1st term in (2); this term is unique for each element
      % of Hessian and thus it cannot be reused.
      xplus = x;
      xplus(i) = x(i) + CHG(i);
      xplus(j) = xplus(j) + CHG(j);
      % evaluate  
      switch funfcn{1}
       case 'fun'
        fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});        
       case 'fungrad'
        [fplus,gradPlus] = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
       case 'fun_then_grad'  
        fplus = feval(funfcn{3},reshape(xplus,xRows,xCols),varargin{:});
       otherwise
        error('optim:fminusub:UndefCallType','Undefined calltype in FMINUNC.')
      end    
      Hessian(i,j) = (fplus - fplus_i - fplus_array(j) + f)/(CHG(i)*CHG(j)); 
    end 
  end % of "for i = 1:numberOfVariables"
  % Fill in the lower triangle of the Hessian
  Hessian = Hessian + triu(Hessian,1)';
  functionCalls = 2*numberOfVariables + ...        % 2nd and 3rd terms,
      numberOfVariables*(numberOfVariables + 1)/2; % 1st term in (2)
end % of 'if useGrad'

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,state,iter,funcCount, ...
    f,alpha,grad,dir,varargin)
% CALLOUTPUTANDPLOTFCNS assigns values to the struct OptimValues and then
% calls the outputfcn/plotfcns.  

% state - can have the values 'init', 'iter', or 'done'. 
% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.

optimValues.iteration = iter;
optimValues.funccount = funcCount;
optimValues.fval = f;
optimValues.stepsize = alpha;
if ~isempty(dir)
    optimValues.directionalderivative = dir'*grad;
else
    optimValues.directionalderivative = [];
end
optimValues.gradient = grad;
optimValues.searchdirection = dir;
optimValues.firstorderopt = norm(grad,Inf);
optimValues.procedure = '';
xOutputfcn(:) = x;  % Set x to have user expected size

stop = false;
% Call output function
if ~isempty(outputfcn)
    switch state
        case {'iter','init'}
            stop = callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:});
        % case 'interrupt' No 'interrupt' case in fminusub            
        otherwise
            error('optim:fminusub:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
% Call plot functions
if ~isempty(plotfcns)
    switch state
        case {'iter','init'}
            stop = callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimPlotFcns(plotfcns,xOutputfcn,optimValues,state,varargin{:});
        otherwise
            error('optim:fminusub:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
%--------------------------------------------------------------------------
function [x,fval,exitflag,output,gradient,hessian] = cleanUpInterrupt(xOutputfcn,optimValues,verbosity,detailedExitMsg)
% CLEANUPINTERRUPT updates or sets all the output arguments of NLCONST when the optimization 
% is interrupted.  The HESSIAN and LAMBDA are set to [] as they may be in a state that is 
% inconsistent with the other values since we are interrupting mid-iteration.

x = xOutputfcn;
fval = optimValues.fval;
exitflag = -1; 
output.iterations = optimValues.iteration;
output.funcCount = optimValues.funccount;
output.stepsize = optimValues.stepsize;
output.algorithm = 'medium-scale: Quasi-Newton line search';
output.firstorderopt = optimValues.firstorderopt; 
output.cgiterations = [];
output.message = createExitMsg('fminusub',exitflag,verbosity > 0,detailedExitMsg,'fminunc');
gradient = optimValues.gradient;
hessian = []; % May be in an inconsistent state





