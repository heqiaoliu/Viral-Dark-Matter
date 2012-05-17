function [x,Fvec,JAC,EXITFLAG,OUTPUT,msgData]= trustnleqn(funfcn,x,verbosity, ...
  gradflag,options,defaultopt,Fvec,JAC,detailedExitMsg,optionFeedback,varargin)
%TRUSTNLEQN Trust-region dogleg nonlinear systems of equation solver.
%
%   TRUSTNLEQN solves a system of nonlinear equations using a dogleg trust
%   region approach.  The algorithm implemented is similar in nature
%   to the FORTRAN program HYBRD1 of J.J. More', B.S.Garbow and K.E. 
%   Hillstrom, User Guide for MINPACK 1, Argonne National Laboratory, 
%   Rept. ANL-80-74, 1980, which itself was based on the program CALFUN 
%   of M.J.D. Powell, A Fortran subroutine for solving systems of
%   nonlinear algebraic equations, Chap. 7 in P. Rabinowitz, ed.,
%   Numerical Methods for Nonlinear Algebraic Equations, Gordon and
%   Breach, New York, 1970.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/04/15 23:21:33 $
%
% NOTE: 'x' passed in and returned in matrix form.
%       'Fvec' passed in and returned in vector form.
%
% Throughout this routine 'x' and 'F' are matrices while
% 'xvec', 'xTrial', 'Fvec' and 'FTrial' are vectors. 
% This was done for compatibility with the 'fsolve.m' interface.

% Define some sizes.
xvec = x(:);         % vector representation of x
% Convert values to full to avoid unnecessary sparse operation overhead
Fvec = full(Fvec); 
nfnc = length(Fvec);  
nvar = length(xvec);

% Get user-defined options.
[maxfunc,maxit,tolf,tolx,derivCheck,DiffMinChange,DiffMaxChange,...
 mtxmpy,typx,giventypx,JACfindiff,structure,outputfcn,plotfcns] = ...
    getOpts(nfnc,nvar,options,defaultopt,gradflag);

if giventypx    % scaling featured only enabled when typx values provided
  scale = true;    
else
  scale = false;
end

% Handle the output function
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
    % Parse OutputFcn which is needed to support cell array syntax for OutputFcn.
    outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
end

% Handle the plot function
if isempty(plotfcns)
    haveplotfcn = false;
else
    haveplotfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
    % Parse PlotFcns which is needed to support cell array syntax for PlotFcns.
    plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
end

% Initialize local arrays.
d       = zeros(nvar,1);
scalMat = ones(nvar,1); 

if derivCheck
    if gradflag
        JACfindiff = JAC; % Initialize finite difference Jacobian with 
    else                % structure given by real Jacobian 
        if verbosity > 0              
            warning('optim:trustnleqn:DerivativeCheckOff', ...
                    ['DerivativeCheck on but analytic Jacobian not provided;\n' ...
                     '         turning DerivativeCheck off.'])
        end
        derivCheck = false;
    end
end

% Initialize some trust region parameters.
Delta    = 1e0;
DeltaMax = 1e10;
eta1     = 0.05;
eta2     = 0.9;
alpha1   = 2.5;
alpha2   = 0.25;

% Other initializations.
iter = 0;
numFevals = 1;   % computed in fsolve.m
if gradflag
  numJevals = 1; % computed in fsolve.m
else
  numJevals = 0;
end 
stepAccept = true;
normd = 0.0e0;
scalemin = eps;
scalemax = 1/scalemin;
objold = 1.0e0;
obj = 0.5*Fvec'*Fvec;  % Initial Fvec computed in fsolve.m

% Compute initial finite difference Jacobian, objective and gradient.
if derivCheck || ~gradflag
  if structure && issparse(JACfindiff)
    group = color(JACfindiff); % only do color if given some structure and sparse
  else
    group = 1:nvar;
  end 
  [JACfindiff,numFDfevals] = sfdnls(x,Fvec,JACfindiff,group,[], ...
                      DiffMinChange,DiffMaxChange,funfcn{3},varargin{:});
  numFevals = numFevals + numFDfevals;
end

switch funfcn{1}
case 'fun'
  JAC = JACfindiff;
case 'fungrad'         % Initial Jacobian computed in fsolve.m
  if derivCheck, graderr(JACfindiff,JAC,funfcn{3}); end
case 'fun_then_grad'   % Initial Jacobian computed in fsolve.m
  if derivCheck, graderr(JACfindiff,JAC,funfcn{4}); end
otherwise
  error('optim:trustnleqn:UndefinedCalltype','Undefined calltype in FSOLVE.')
end 
grad = feval(mtxmpy,JAC,Fvec,-1,varargin{:});  % compute JAC'*Fvec
normgradinf = norm(grad,inf);

% Print header.
header = sprintf(['\n                                         Norm of      First-order   Trust-region\n',...
                    ' Iteration  Func-count     f(x)          step         optimality    radius']);
formatstr = ' %5.0f      %5.0f   %13.6g  %13.6g   %12.3g    %12.3g';
if verbosity > 1
  disp(header);
end

% Initialize the output function.
if haveoutputfcn || haveplotfcn
    [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,xvec,xOutputfcn,'init',iter, ...
        numFevals,Fvec,[],[],[],Delta,stepAccept,varargin{:});
    if stop
        [x,Fvec,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(xOutputfcn,optimValues);
        msgData = {'trustnleqn',EXITFLAG,verbosity > 0,detailedExitMsg,'fsolve'};
        return;
    end
end

% Compute initial diagonal scaling matrix.
if scale
  if giventypx && ~isempty(typx) % scale based on typx values
    typx(typx==0) = 1; % replace any zero entries with ones
    scalMat = 1./abs(typx);
  else         % scale based on norm of the Jacobian (not currently active)  
    scalMat = getscalMat(nvar,JAC,scalemin,scalemax);
  end
end

% Display initial iteration information.
formatstr0 = ' %5.0f      %5.0f   %13.6g                  %12.3g    %12.3g';
% obj is 0.5*F'*F but want to display F'*F
iterOutput0 = sprintf(formatstr0,iter,numFevals,2*obj,normgradinf,Delta);
if verbosity > 1
   disp(iterOutput0);
end
% OutputFcn call
if haveoutputfcn || haveplotfcn
    [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,xvec,xOutputfcn,'iter',iter, ...
        numFevals,Fvec,normd,grad,normgradinf,Delta,stepAccept,varargin{:});
    if stop
        [x,Fvec,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(xOutputfcn,optimValues);
        msgData = {'trustnleqn',EXITFLAG,verbosity > 0,detailedExitMsg,'fsolve'};
        return;
    end
end


% Test convergence at initial point.
[done,EXITFLAG,msgData] = testStop(normgradinf,tolf,tolx,...
     stepAccept,iter,maxit,numFevals,maxfunc,Delta,normd,...
     obj,objold,d,xvec,detailedExitMsg,optionFeedback,verbosity);

% Beginning of main iteration loop.
while ~done
  iter = iter + 1;

  % Compute step, d, using dogleg approach.
  [d,quadObj,normd,normdscal] = ...
       dogleg(nvar,Fvec,JAC,grad,Delta,scalMat,mtxmpy,varargin);

  % Compute the model reduction given by d (pred).
  pred = -quadObj;

  % Compute the trial point, xTrial.
  xTrial = xvec + d;

  % Evaluate nonlinear equations and objective at trial point.
  x(:) = xTrial; % reshape xTrial to a matrix for evaluations. 
  switch funfcn{1}
  case 'fun'
    F = feval(funfcn{3},x,varargin{:});
  case 'fungrad'
    [F,JACTrial] = feval(funfcn{3},x,varargin{:});
    numJevals = numJevals + 1;
  case 'fun_then_grad'
    F = feval(funfcn{3},x,varargin{:}); 
  otherwise
    error('optim:trustnleqn:UndefinedCalltype','Undefined calltype in FSOLVE.')
  end  
  numFevals = numFevals + 1;
  FTrial = full(F(:)); % make FTrial a vector, convert to full
  objTrial = 0.5*FTrial'*FTrial; 

  % Compute the actual reduction given by xTrial (ared).
  ared = obj - objTrial;

  % Compute ratio = ared/pred.
  if pred <= 0 % reject step
    ratio = 0;
  else
    ratio = ared/pred;
  end
  
  if haveoutputfcn % Call output functions (we don't call plot functions with 'interrupt' flag)
      [unused1, unused2, stop] = callOutputAndPlotFcns(outputfcn,{},xvec,xOutputfcn,'interrupt',iter, ...
          numFevals,Fvec,normd,grad,normgradinf,Delta,stepAccept,varargin{:});
      if stop  % Stop per user request.
          [x,Fvec,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(xOutputfcn,optimValues);
          msgData = {'trustnleqn',EXITFLAG,verbosity > 0,detailedExitMsg,'fsolve'};
          return;
      end
  end
  
  if ratio > eta1 % accept step.

    xvec = xTrial; Fvec = FTrial; objold = obj; obj = objTrial;
    x(:) = xvec; % update matrix representation
    % Compute JAC at new point. (already computed with F if 'fungrad')

    % Compute sparse finite difference Jacobian if needed.
    if ~gradflag
      [JACfindiff,numFDfevals] = sfdnls(x,Fvec,JACfindiff,group,[], ...
                  DiffMinChange,DiffMaxChange,funfcn{3},varargin{:});
      numFevals = numFevals + numFDfevals;
    end

    switch funfcn{1}
        case 'fun'
            JAC = JACfindiff;
        case 'fungrad'
            JAC = JACTrial;
        case 'fun_then_grad'
            JAC = feval(funfcn{4},x,varargin{:});
            numJevals = numJevals + 1;
        otherwise
            error('optim:trustnleqn:UndefinedCalltype','Undefined calltype in FSOLVE.')
    end
      
    grad = feval(mtxmpy,JAC,Fvec,-1,varargin{:});  % compute JAC'*Fvec
    normgradinf = norm(grad,inf);

    % Update internal diagonal scaling matrix (dynamic scaling).
    if scale && ~giventypx
      scalMat = getscalMat(nvar,JAC,scalemin,scalemax);
    end

    stepAccept = true;
  else % reject step.
    stepAccept = false;
  end 

  % Print iteration statistics.
  if verbosity > 1
      % obj is 0.5*F'*F but want to display F'*F
      iterOutput = sprintf(formatstr,iter,numFevals,2*obj,normd,normgradinf,Delta);
      disp(iterOutput);
  end
  % OutputFcn call
  if haveoutputfcn || haveplotfcn
      [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,xvec,xOutputfcn,'iter',iter, ...
        numFevals,Fvec,normd,grad,normgradinf,Delta,stepAccept,varargin{:});
      if stop
          [x,Fvec,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(xOutputfcn,optimValues);
          msgData = {'trustnleqn',EXITFLAG,verbosity > 0,detailedExitMsg,'fsolve'};
          return;
      end
  end

  % Update trust region radius.
  Delta = updateDelta(Delta,ratio,normdscal,eta1,eta2,...
                      alpha1,alpha2,DeltaMax);

  % Check for termination.
  [done,EXITFLAG,msgData] = testStop(normgradinf,tolf,tolx,...
       stepAccept,iter,maxit,numFevals,maxfunc,Delta,normd,...
       obj,objold,d,xvec,detailedExitMsg,optionFeedback,verbosity);
end

if haveoutputfcn || haveplotfcn
    callOutputAndPlotFcns(outputfcn,plotfcns,xvec,xOutputfcn,'done',iter, ...
        numFevals,Fvec,normd,grad,normgradinf,Delta,stepAccept,varargin{:});
    % Optimization done, so ignore "stop"
end


% Optimization is finished.

% Assign output statistics.
OUTPUT.iterations = iter;
OUTPUT.funcCount = numFevals;
OUTPUT.algorithm = 'trust-region dogleg';
OUTPUT.firstorderopt = normgradinf;

% TRUSTNLEQN finished

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [maxfunc,maxit,tolf,tolx,derivCheck,DiffMinChange,...
          DiffMaxChange,mtxmpy,typx,giventypx,JACfindiff,structure,outputfcn,plotfcns] = ...
          getOpts(nfnc,nvar,options,defaultopt,gradflag)
%getOpts gets the user-defined options for TRUSTNLEQN.

% Both Medium and Large-Scale options.
maxfunc = optimget(options,'MaxFunEvals',defaultopt,'fast');
if ischar(maxfunc)
  if isequal(lower(maxfunc),'100*numberofvariables')
    maxfunc = 100*nvar;
  else
    error('optim:trustnleqn:InvalidMaxFunEvals', ...
          'Option ''MaxFunEvals'' must be an integer value if not the default.')
  end
end
maxit = optimget(options,'MaxIter',defaultopt,'fast');
tolf = optimget(options,'TolFun',defaultopt,'fast');
tolx = optimget(options,'TolX',defaultopt,'fast');
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
plotfcns = optimget(options,'PlotFcns',defaultopt,'fast');

% Medium-Scale only options.
derivCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');
DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');

% Use internal Jacobian-multiply function - JacobMult is not an option
% for this algorithm because it requires the Jacobian matrix to solve
% for the Newton direction
mtxmpy = @atamult;

giventypx = true;
typx = optimget(options,'TypicalX',defaultopt,'fast');
if ischar(typx)
  if isequal(lower(typx),'ones(numberofvariables,1)')
    typx = ones(nvar,1);
    giventypx = false;
  else
    error('optim:trustnleqn:InvalidTypicalX', ...
          'Option ''TypicalX'' must be a matrix (not a string) if not the default.')
  end
end
checkoptionsize('TypicalX', size(typx), nvar);
structure = true;
if ~gradflag
  JACfindiff = optimget(options,'JacobPattern',defaultopt,'fast');
  if ischar(JACfindiff) 
    if isequal(lower(JACfindiff),'sparse(ones(jrows,jcols))')
      JACfindiff = sparse(ones(nfnc,nvar));
      structure = false;
    else
      error('optim:trustnleqn:InvalidJacobPattern', ...
            'Option ''JacobPattern'' must be a matrix if not the default.')
    end
  end
  checkoptionsize('JacobPattern', size(JACfindiff), nvar, nfnc);
else
  JACfindiff = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [done,EXITFLAG,msgData] = testStop(normgradinf,tolf,tolx,...
     stepAccept,iter,maxit,numFevals,maxfunc,Delta,normd,...
     obj,objold,d,xvec,detailedExitMsg,optionFeedback,verbosity)
%testStop checks the termination criteria for TRUSTNLEQN.

done = false;
EXITFLAG = 0;
msgData = {};

% Check termination criteria.
if stepAccept && normgradinf < tolf
  done = true;
  EXITFLAG = 1;
  if iter == 0
      msgFlag = 100;
  else
      msgFlag = EXITFLAG;
  end
  % Setup input parameters for createExitMsg with msgFlag = 100 if x0 is
  % optimal, otherwise msgFlag = 1
  msgData = {'trustnleqn',msgFlag,verbosity > 0,detailedExitMsg,'fsolve', ...
      normgradinf,optionFeedback.TolFun,tolf,2*obj,optionFeedback.TolFun,sqrt(tolf)};
elseif iter > 1 && max(abs(d)./(abs(xvec)+1)) < max(tolx^2,eps)
   % Assign msgFlag, a unique internal exitflag, to 2 or -22 for this
   % stopping test depending on whether the result appears to be a root or
   % not.
   if 2*obj < sqrt(tolf) % fval'*fval < sqrt(tolf)
      EXITFLAG = 2; msgFlag = 2;
      dispMsg = verbosity > 0;
   else
      EXITFLAG = -2; msgFlag = -22;
      dispMsg = verbosity > 0;
   end
   % Setup input parameters for createExitMsg
   msgData = {'trustnleqn',msgFlag,dispMsg,detailedExitMsg,'fsolve', ...
       max(abs(d)./(abs(xvec)+1)),optionFeedback.TolX,max(tolx^2,eps), ...
       2*obj,optionFeedback.TolFun,sqrt(tolf)};
   done = true;
elseif iter > 1 && stepAccept && normd < 0.9*Delta ...
                && abs(objold-obj) < max(tolf^2,eps)*(1+abs(objold))
  % Assign msgFlag, a unique internal exitflag, to 3 or -23 for this
  % stopping test depending on whether the result appears to be a root or
  % not.
  if 2*obj < sqrt(tolf) % fval'*fval < sqrt(tolf)
     EXITFLAG = 3; msgFlag = 3;
     dispMsg = verbosity > 0;
  else
     EXITFLAG = -2; msgFlag = -23;
     dispMsg = verbosity > 0;
  end
  % Setup input parameters for createExitMsg
  msgData = {'trustnleqn',msgFlag,dispMsg,detailedExitMsg,'fsolve', ...
      abs(objold-obj)./(abs(objold)+1),optionFeedback.TolFun,max(tolf^2,eps), ...
      2*obj,optionFeedback.TolFun,sqrt(tolf)};
  done = true;
elseif Delta < 2*eps
  EXITFLAG = -3;
  msgData = {'trustnleqn',EXITFLAG,verbosity > 0,detailedExitMsg,'fsolve', ...
      Delta,'',2*eps};
  done = true;
elseif iter >= maxit
  EXITFLAG = 0;
  msgData = {'trustnleqn',10,verbosity > 0,detailedExitMsg,'fsolve', ...
      [],optionFeedback.MaxIter,maxit};
  done = true;
elseif numFevals >= maxfunc
  EXITFLAG = 0;
  msgData = {'trustnleqn',EXITFLAG,verbosity > 0,detailedExitMsg,'fsolve', ...
      [],optionFeedback.MaxFunEvals,maxfunc};
  done = true;
end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Delta = updateDelta(Delta,ratio,normdscal,eta1,eta2,...
                             alpha1,alpha2,DeltaMax)
%updateDelta updates the trust region radius in TRUSTNLEQN.
%
%   updateDelta updates the trust region radius based on the value of
%   ratio and the norm of the scaled step.

if ratio < eta1
  Delta = alpha2*normdscal;
elseif ratio >= eta2
  Delta = max(Delta,alpha1*normdscal);
end
Delta = min(Delta,DeltaMax);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function scalMat = getscalMat(nvar,JAC,scalemin,scalemax)
%getscalMat computes the scaling matrix in TRUSTNLEQN.
%
%   getscalMat computes the scaling matrix based on the norms 
%   of the columns of the Jacobian.

scalMat = ones(nvar,1);
for i=1:nvar
  scalMat(i,1) = norm(JAC(:,i));
end
scalMat(scalMat<scalemin) = scalemin;  % replace small entries
scalMat(scalMat>scalemax) = scalemax;  % replace large entries

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,xvec,xOutputfcn,state,iter,numFevals, ...
    Fvec,normd,grad,normgradinf,Delta,stepAccept,varargin)
% CALLOUTPUTANDPLOTFCNS assigns values to the struct OptimValues and then calls the
% outputfcn/plotfcns.  
%
% state - can have the values 'init','iter','interrupt', or 'done'. 
%
% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.

optimValues.iteration = iter;
optimValues.funccount = numFevals;
optimValues.fval = Fvec;
optimValues.stepsize = normd; 
optimValues.gradient = grad; 
optimValues.firstorderopt = normgradinf;
optimValues.trustregionradius = Delta;
optimValues.stepaccept = stepAccept;

xOutputfcn(:) = xvec;  % Set xvec to have user expected size
stop = false;
% Call output functions
if ~isempty(outputfcn)
    switch state
        case {'iter','init','interrupt'}
            stop = callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:});
        otherwise
            error('optim:trustnleqn:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
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
            error('optim:trustnleqn:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
%--------------------------------------------------------------------------
function [x,Fvec,JAC,EXITFLAG,OUTPUT] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT sets the outputs arguments to be the values at the last call
% of the outputfcn during an 'iter' call (when these values were last known to
% be consistent). 

x = xOutputfcn; 
Fvec = optimValues.fval;
EXITFLAG = -1; 
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.algorithm = 'trust-region dogleg';
OUTPUT.firstorderopt = optimValues.firstorderopt; 
JAC = []; % May be in an inconsistent state


