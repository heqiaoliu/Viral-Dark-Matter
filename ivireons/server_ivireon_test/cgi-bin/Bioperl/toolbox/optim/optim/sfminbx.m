function [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = sfminbx(funfcn,x,l,u,verb,options,defaultopt,...
    computeLambda,initialf,initialGRAD,initialHESS,Hstr,detailedExitMsg,computeConstrViolForOutput,varargin)
%SFMINBX Nonlinear minimization with box constraints.
%
% Locate a local minimizer to 
%
%               min { f(x) :  l <= x <= u }.
%
%	where f(x) maps n-vectors to scalars.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2010/05/10 17:32:04 $

caller = funfcn{2};
%   Initialization
xcurr = x(:);  % x has "the" shape; xcurr is a vector
n = length(xcurr); 
iter = 0; 
numFunEvals = 1;  % feval of user function in fmincon or fminunc

header = sprintf(['\n                                Norm of      First-order \n',...
        ' Iteration        f(x)          step          optimality   CG-iterations']);
formatstrFirstIter = ' %5.0f      %13.6g                  %12.3g                ';
formatstr = ' %5.0f      %13.6g  %13.6g   %12.3g     %7.0f';
if n == 0, 
    error('optim:sfminbx:InvalidN','n must be positive.')
end

% Create structure of flags for finitedifferences
finDiffFlags.fwdFinDiff = true; % Always forward fin-diff
finDiffFlags.scaleObjConstr = false; % No scaling
finDiffFlags.chkFunEval = false; % Don't validate function values
finDiffFlags.isGrad = true; % Compute gradient, not Jacobian

if isempty(l)
   l = -inf*ones(n,1);
   finDiffFlags.hasLBs = false(n,1);
else
    % Some variables are possibly bounded (i.e. lb ~= [])
    arg2 = (l <= -1e10);
    l(arg2) = -inf;
    finDiffFlags.hasLBs = isfinite(l);
end
if isempty(u)
   u = inf*ones(n,1); 
   finDiffFlags.hasUBs = false(n,1);
else
    % Some variables are possibly bounded (i.e. ub ~= [])
   arg = (u >= 1e10); 
   u(arg) = inf;
   finDiffFlags.hasUBs = isfinite(u);
end

if any(u == l) 
    error('optim:sfminbx:InvalidBounds', ...
          ['Equal upper and lower bounds not permitted in trust-region-reflective algorithm. ' ...
           'Use either interior-point or SQP algorithms instead.'])
end

% Add ActiveConstrTol and Preconditioner to defaultopt. These are not
% documented options, and are not added to defaultopt at the user-facing
% function level.
defaultopt.ActiveConstrTol = sqrt(eps);
defaultopt.Preconditioner = @hprecon;

% Read in user options
finDiffOpts.TypicalX = optimget(options,'TypicalX',defaultopt,'fast') ;
% In case the defaults were gathered from calling: optimset('quadprog'):
numberOfVariables = n;
if ischar(finDiffOpts.TypicalX)
    if isequal(lower(finDiffOpts.TypicalX),'ones(numberofvariables,1)')
        finDiffOpts.TypicalX = ones(numberOfVariables,1);
    else
        error('optim:sfminbx:InvalidTypicalX', ...
              'Option ''TypicalX'' must be a matrix (not a string) if not the default.')
    end
end
checkoptionsize('TypicalX', size(finDiffOpts.TypicalX), numberOfVariables);
finDiffOpts.DiffMinChange = optimget(options,'DiffMinChange',defaultopt,'fast');
finDiffOpts.DiffMaxChange = optimget(options,'DiffMaxChange',defaultopt,'fast');
DerivativeCheck = strcmp(optimget(options,'DerivativeCheck',defaultopt,'fast'),'on');

pcmtx = optimget(options,'Preconditioner',defaultopt,'fast');

mtxmpy = optimget(options,'HessMult',defaultopt,'fast');
% Check if name clash
functionNameClashCheck('HessMult',mtxmpy,'hessMult_optimInternal', ...
    'optim:sfminbx:HessMultNameClash');

% Use internal Hessian-multiply function if user does not provide HessMult function 
% or options.Hessian is off
if isempty(mtxmpy) || (~strcmpi(funfcn{1},'fungradhess') && ~strcmpi(funfcn{1},'fun_then_grad_then_hess'))
    mtxmpy = @hessMult_optimInternal;
end

% Handle the output
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
    % Parse OutputFcn which is needed to support cell array syntax for OutputFcn.
    outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
end

% Handle the plot functions
plotfcns = optimget(options,'PlotFcns',defaultopt,'fast');
if isempty(plotfcns)
    haveplotfcn = false;
else
    haveplotfcn = true;
    xOutputfcn = x; % Last x passed to outputfcn; has the input x's shape
    % Parse PlotFcn which is needed to support cell array syntax for PlotFcn.
    plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
end

active_tol = optimget(options,'ActiveConstrTol',defaultopt,'fast');
pcflags = optimget(options,'PrecondBandWidth',defaultopt,'fast') ;
tol2 = optimget(options,'TolX',defaultopt,'fast') ;
tol1 = optimget(options,'TolFun',defaultopt,'fast') ;
maxiter = optimget(options,'MaxIter',defaultopt,'fast') ;
maxfunevals = optimget(options,'MaxFunEvals',defaultopt,'fast') ;
pcgtol = optimget(options,'TolPCG',defaultopt,'fast') ;  % pcgtol = .1;
kmax = optimget(options,'MaxPCGIter', defaultopt,'fast') ;
if ischar(kmax)
    if isequal(lower(kmax),'max(1,floor(numberofvariables/2))')
        kmax = max(1,floor(numberOfVariables/2));
    else
        error('optim:sfminbx:InvalidMaxPCGIter', ...
              'Option ''MaxPCGIter'' must be an integer value if not the default.')
    end
end

if ischar(maxfunevals)
    if isequal(lower(maxfunevals),'100*numberofvariables')
        maxfunevals = 100*numberOfVariables;
    else
        error('optim:sfminbx:InvalidMaxFunEvals', ...
              'Option ''MaxFunEvals'' must be an integer value if not the default.')
    end
end

% Prepare strings to give feedback to users on options they have or have not set.
% These are used in the exit messages.
optionFeedback = createOptionFeedback(options);

dnewt = [];  
ex = 0; posdef = 1; npcg = 0; 

pcgit = 0; delta = 10;nrmsx = 1; ratio = 0;
oval = inf;  g = zeros(n,1); newgrad = g; Z = []; 
% Inputs to finitedifferences():
finDiffOpts.FinDiffType = 'forward';
[sizes.xRows,sizes.xCols] = size(x);

% First-derivative check
if DerivativeCheck
    %
    % Calculate finite-difference gradient
    % 
    gf = zeros(numberOfVariables,1); % pre-allocate finite-difference gradient
    [gf,~,~,numEvals]=finitedifferences(xcurr,funfcn{3},[],l,u,initialf,[],[],...
        1:numberOfVariables,finDiffOpts,sizes,gf,[],[],finDiffFlags,[],varargin{:});
    %
    % Compare user-supplied versus finite-difference gradients
    %
    disp('Function derivative')
    if isa(funfcn{4},'inline')
        graderr(gf, initialGRAD, formula(funfcn{4}));
    else 
        graderr(gf, initialGRAD, funfcn{4});
    end
    numFunEvals = numFunEvals + numEvals;
end

if ~isempty(Hstr)  % use sparse finite differencing
    switch funfcn{1}
        case 'fungrad'
            val = initialf; g(:) = initialGRAD;
        case 'fun_then_grad'
            val = initialf; g(:) = initialGRAD;
        otherwise
            error('optim:sfminbx:UndefinedCalltype','Undefined calltype.')
    end
    % Determine coloring/grouping for sparse finite-differencing
    p = colamd(Hstr)'; 
    p = (n+1) - p;
    group = color(Hstr,p);
    % pass in the user shaped x
    H = sfd(x,g,Hstr,group,[],finDiffOpts.DiffMinChange,finDiffOpts.DiffMaxChange,funfcn,varargin{:});
    %
else % user-supplied computation of H or dnewt
    switch funfcn{1}
        case 'fungradhess'
            val = initialf; g(:) = initialGRAD; H = initialHESS;
        case 'fun_then_grad_then_hess'
            val = initialf; g(:) = initialGRAD; H = initialHESS;
        otherwise
            error('optim:sfminbx:UndefinedCalltype','Undefined calltype.')
    end
end

delbnd = max(100*norm(xcurr),1);
[nn,pp] = size(g);

%   Extract the Newton direction?
if pp == 2, dnewt = g(1:n,2); end
if verb > 2
    disp(header)
end

% Initialize the output function.
if haveoutputfcn || haveplotfcn
   [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,xcurr,xOutputfcn,'init',iter,numFunEvals, ...
        val,[],[],[],pcgit,[],[],[],delta,l,u,varargin{:});
    if stop
        [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = ...
            cleanUpInterrupt(xOutputfcn,optimValues,npcg,verb,detailedExitMsg,caller);
        return;
    end
end

%   MAIN LOOP: GENERATE FEAS. SEQ.  xcurr(iter) S.T. f(x(iter)) IS DECREASING.
while ~ex
    if ~isfinite(val) || any(~isfinite(g))
        error('optim:sfminbx:InvalidUserFunction', ...
              '%s cannot continue: user function is returning Inf or NaN values.',caller)
    end
    
    %     Update
    [v,dv] = definev(g(:,1),xcurr,l,u); 
    gopt = v.*g(:,1); gnrm = norm(gopt,inf);
    r = abs(min(u-xcurr,xcurr-l)); degen = min(r + abs(g(:,1)));
    % If no upper and lower bounds (e.g., fminunc), then set degen flag to -1.
    if all( (l == -inf) & (u == inf) )
        degen = -1; 
    end
    
    % Display
    if verb > 2
        if iter > 0
            currOutput = sprintf(formatstr,iter,val,nrmsx,gnrm,pcgit);
        else
            currOutput = sprintf(formatstrFirstIter,iter,val,gnrm);
        end
        disp(currOutput);
    end
    
    % OutputFcn call
    if haveoutputfcn || haveplotfcn
       [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,xcurr,xOutputfcn,'iter',iter,numFunEvals, ...
            val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,l,u,varargin{:});
        if stop  % Stop per user request.
            [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = ...
                cleanUpInterrupt(xOutputfcn,optimValues,npcg,verb,detailedExitMsg,caller);
            return;
        end
    end
    
    %     TEST FOR CONVERGENCE
    diff = abs(oval-val); 
    oval = val; 
    if ((gnrm < tol1) && (posdef == 1) )
        ex = 3; EXITFLAG = 1;
        if iter == 0
            msgFlag = 100;
        else
            msgFlag = EXITFLAG;
        end
        % Call createExitMsg with createExitMsgExitflag = 100 if x0 is
        % optimal, otherwise createExitMsgExitflag = 1
        outMessage = createExitMsg('sfminle',msgFlag,verb > 1,detailedExitMsg,caller, ...
            gnrm,optionFeedback.TolFun,tol1);
    elseif (nrmsx < .9*delta) && (ratio > .25) && (diff < tol1*(1+abs(oval)))
        ex = 1; EXITFLAG = 3;
        outMessage = createExitMsg('sfminle',EXITFLAG,verb > 1,detailedExitMsg,caller, ...
            diff/(1+abs(oval)),optionFeedback.TolFun,tol1);
    elseif (iter > 1) && (nrmsx < tol2) 
        ex = 2; EXITFLAG = 2;
        outMessage = createExitMsg('sfminle',EXITFLAG,verb > 1,detailedExitMsg,caller, ...
            nrmsx,optionFeedback.TolX,tol2);
    elseif numFunEvals > maxfunevals
        ex = 4; EXITFLAG = 0;
        outMessage = createExitMsg('sfminle',EXITFLAG,verb > 0,detailedExitMsg,caller, ...
            [],optionFeedback.MaxFunEvals,maxfunevals);
    elseif iter > maxiter
        ex = 4; EXITFLAG = 0;
        % Call createExitMsg with createExitMsgExitflag = 10 for MaxIter exceeded
        outMessage = createExitMsg('sfminle',10,verb > 0,detailedExitMsg,caller, ...
            [],optionFeedback.MaxIter,maxiter);
    end
      
    %     Step computation
    if ~ex
        if haveoutputfcn % Call output functions (we don't call plot functions with 'interrupt' flag)
            [unused1, unused2, stop] = callOutputAndPlotFcns(outputfcn,{},xcurr,xOutputfcn,'interrupt',iter,numFunEvals, ...
                val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,l,u,varargin{:});
            if stop  % Stop per user request.
                [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = ...
                    cleanUpInterrupt(xOutputfcn,optimValues,npcg,verb,detailedExitMsg,caller);
                return;
            end
        end
        %       Determine trust region correction
        dd = abs(v); D = sparse(1:n,1:n,full(sqrt(dd))); 
        theta = max(.95,1-gnrm);  
        oposdef = posdef;
        [sx,snod,qp,posdef,pcgit,Z] = trdog(xcurr, g(:,1),H,D,delta,dv,...
            mtxmpy,pcmtx,pcflags,pcgtol,kmax,theta,l,u,Z,dnewt,'hessprecon',varargin{:});
        if isempty(posdef), posdef = oposdef; end
        nrmsx=norm(snod); npcg=npcg + pcgit;
        newx=xcurr + sx;
        
        %       Perturb?
        [pert,newx] = perturb(newx,l,u); 
        
        % Make newx conform to user's input x
        x(:) = newx;
        % Evaluate f, g, and H
        if ~isempty(Hstr) % use sparse finite differencing
            switch funfcn{1}
                case 'fungrad'
                    [newval,newgrad(:)] = feval(funfcn{3},x,varargin{:});
                case 'fun_then_grad'
                    newval = feval(funfcn{3},x,varargin{:}); 
                    newgrad(:) = feval(funfcn{4},x,varargin{:});
                otherwise
                    error('optim:sfminbx:UndefinedCalltype','Undefined calltype.')
            end
            newH = sfd(x,newgrad,Hstr,group,[],finDiffOpts.DiffMinChange,finDiffOpts.DiffMaxChange, ...
                       funfcn,varargin{:});
            
        else % user-supplied computation of H or dnewt
            switch funfcn{1}
                case 'fungradhess'
                    [newval,newgrad(:),newH] = feval(funfcn{3},x,varargin{:});
                case 'fun_then_grad_then_hess'
                    newval = feval(funfcn{3},x,varargin{:}); 
                    newgrad(:) = feval(funfcn{4},x,varargin{:});
                    newH = feval(funfcn{5},x,varargin{:});
                otherwise
                    error('optim:sfminbx:UndefinedCalltype','Undefined calltype.')
            end
            
        end       
        numFunEvals = numFunEvals + 1;
        
        % Update trust region radius using change in objective and 
        % in quadratic model 
        [nn,pp] = size(newgrad);
        aug = .5*snod'*((dv.*abs(newgrad(:,1))).*snod);
        ratio = (newval + aug -val)/qp;
        
        if (ratio >= .75) && (nrmsx >= .9*delta)
            delta = min(delbnd,2*delta);
        elseif ratio <= .25
            delta = min(nrmsx/4,delta/4);
        end
        if newval == inf
            delta = min(nrmsx/20,delta/20);
        end
        
        %       Update
        if newval < val
            xcurr = newx; 
            val = newval; 
            g = newgrad; 
            H = newH;
            Z = [];
            
            %          Extract the Newton direction?
            if pp == 2, dnewt = newgrad(1:n,2); end
        end
        iter = iter + 1;
    end % if ~ex
end % while

if haveoutputfcn || haveplotfcn
   callOutputAndPlotFcns(outputfcn,plotfcns,xcurr,xOutputfcn,'done',iter,numFunEvals, ...
        val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,l,u,varargin{:});
    % Do not check value of 'stop' as we are done with the optimization
    % already.
end
HESSIAN = H;
GRAD = g;
FVAL = val;
LAMBDA = [];

OUTPUT.iterations = iter;
OUTPUT.funcCount = numFunEvals;
OUTPUT.cgiterations = npcg;
OUTPUT.firstorderopt = gnrm;
OUTPUT.algorithm = 'large-scale: trust-region reflective Newton'; 
OUTPUT.message = outMessage;
if computeConstrViolForOutput
    OUTPUT.constrviolation = max([0; (l-xcurr); (xcurr-u) ]);
else
    OUTPUT.constrviolation = [];
end

x(:) = xcurr;
if computeLambda
    g = full(g);
    
    LAMBDA.lower = zeros(length(l),1);
    LAMBDA.upper = zeros(length(u),1);
    argl = logical(abs(xcurr-l) < active_tol);
    argu = logical(abs(xcurr-u) < active_tol);
    
    LAMBDA.lower(argl) = (g(argl));
    LAMBDA.upper(argu) = -(g(argu));
    LAMBDA.ineqlin = []; 
    LAMBDA.eqlin = []; 
    LAMBDA.ineqnonlin = []; 
    LAMBDA.eqnonlin = [];
else
    LAMBDA = [];   
end

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,xvec,xOutputfcn,state, ... 
    iter,numFunEvals, ...
    val,nrmsx,g,gnrm,pcgit,posdef,ratio,degen,delta,l,u,varargin)
% CALLOUTPUTANDPLOTFCNS assigns values to the struct OptimValues and then calls the
% outputfcn/plotfcns.  
%
% The input STATE can have the values 'init','iter','interrupt', or 'done'. 
%
% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.

optimValues.iteration = iter;
optimValues.funccount = numFunEvals;
optimValues.fval = val;
optimValues.stepsize = nrmsx;
optimValues.gradient = g;
optimValues.firstorderopt = gnrm;
optimValues.cgiterations = pcgit; 
optimValues.positivedefinite = posdef;
optimValues.ratio = ratio;
optimValues.degenerate = min(degen,1);
optimValues.trustregionradius = delta;
optimValues.procedure = '';
optimValues.constrviolation = max([0; (l-xvec); (xvec-u) ]);

xOutputfcn(:) = xvec;  % Set x to have user expected size
stop = false;
if ~isempty(outputfcn)
    switch state
        case {'iter','init','interrupt'}
            stop = callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:});
        otherwise
            error('optim:sfminbx:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
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
            error('optim:sfminbx:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
%--------------------------------------------------------------------------
function [x,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = cleanUpInterrupt(xOutputfcn,optimValues,npcg, ...
                                                        verb,detailedExitMsg,caller)
% CLEANUPINTERRUPT updates or sets all the output arguments of SFMINBX when the optimization 
% is interrupted.  The HESSIAN and LAMBDA are set to [] as they may be in a
% state that is inconsistent with the other values since we are
% interrupting mid-iteration.

x = xOutputfcn; 
FVAL = optimValues.fval;
EXITFLAG = -1; 
OUTPUT.iterations = optimValues.iteration;
OUTPUT.funcCount = optimValues.funccount;
OUTPUT.stepsize = optimValues.stepsize;
OUTPUT.algorithm = 'large-scale: trust-region reflective Newton'; 
OUTPUT.firstorderopt = optimValues.firstorderopt; 
OUTPUT.cgiterations = npcg; % total number of CG iterations
OUTPUT.message = createExitMsg('sfminle',EXITFLAG,verb > 0,detailedExitMsg,caller);
OUTPUT.constrviolation = optimValues.constrviolation; 
GRAD = optimValues.gradient;
HESSIAN = []; % May be in an inconsistent state
LAMBDA = []; % May be in an inconsistent state


