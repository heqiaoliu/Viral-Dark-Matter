function [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] = fmincon(FUN,X,A,B,Aeq,Beq,LB,UB,NONLCON,options,varargin)
%FMINCON finds a constrained minimum of a function of several variables.
%   FMINCON attempts to solve problems of the form:
%    min F(X)  subject to:  A*X  <= B, Aeq*X  = Beq (linear constraints)
%     X                     C(X) <= 0, Ceq(X) = 0   (nonlinear constraints)
%                              LB <= X <= UB        (bounds)
%    
%   FMINCON implements four different algorithms: interior point, SQP, active 
%   set, and trust region reflective. Choose one via the option Algorithm: 
%   for instance, to choose SQP, set OPTIONS = optimset('Algorithm','sqp'), 
%   and then pass OPTIONS to FMINCON. 
%                                                           
%   X = FMINCON(FUN,X0,A,B) starts at X0 and finds a minimum X to the 
%   function FUN, subject to the linear inequalities A*X <= B. FUN accepts 
%   input X and returns a scalar function value F evaluated at X. X0 may be
%   a scalar, vector, or matrix. 
%
%   X = FMINCON(FUN,X0,A,B,Aeq,Beq) minimizes FUN subject to the linear 
%   equalities Aeq*X = Beq as well as A*X <= B. (Set A=[] and B=[] if no 
%   inequalities exist.)
%
%   X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB) defines a set of lower and upper
%   bounds on the design variables, X, so that a solution is found in 
%   the range LB <= X <= UB. Use empty matrices for LB and UB
%   if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below; 
%   set UB(i) = Inf if X(i) is unbounded above.
%
%   X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON) subjects the minimization
%   to the constraints defined in NONLCON. The function NONLCON accepts X 
%   and returns the vectors C and Ceq, representing the nonlinear 
%   inequalities and equalities respectively. FMINCON minimizes FUN such 
%   that C(X) <= 0 and Ceq(X) = 0. (Set LB = [] and/or UB = [] if no bounds
%   exist.)
%
%   X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS) minimizes with 
%   the default optimization parameters replaced by values in the structure
%   OPTIONS, an argument created with the OPTIMSET function. See OPTIMSET
%   for details. For a list of options accepted by FMINCON refer to the
%   documentation.
%  
%   X = FMINCON(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a
%   structure with the function FUN in PROBLEM.objective, the start point
%   in PROBLEM.x0, the linear inequality constraints in PROBLEM.Aineq
%   and PROBLEM.bineq, the linear equality constraints in PROBLEM.Aeq and
%   PROBLEM.beq, the lower bounds in PROBLEM.lb, the upper bounds in 
%   PROBLEM.ub, the nonlinear constraint function in PROBLEM.nonlcon, the
%   options structure in PROBLEM.options, and solver name 'fmincon' in
%   PROBLEM.solver. Use this syntax to solve at the command line a problem 
%   exported from OPTIMTOOL. The structure PROBLEM must have all the fields.
%
%   [X,FVAL] = FMINCON(FUN,X0,...) returns the value of the objective 
%   function FUN at the solution X.
%
%   [X,FVAL,EXITFLAG] = FMINCON(FUN,X0,...) returns an EXITFLAG that 
%   describes the exit condition of FMINCON. Possible values of EXITFLAG 
%   and the corresponding exit conditions are listed below. See the
%   documentation for a complete description.
%   
%   All algorithms:
%     1  First order optimality conditions satisfied.
%     0  Too many function evaluations or iterations.
%    -1  Stopped by output/plot function.
%    -2  No feasible point found.
%   Trust-region-reflective, interior-point, and sqp:
%     2  Change in X too small.
%   Trust-region-reflective:
%     3  Change in objective function too small.
%   Active-set only:
%     4  Computed search direction too small.
%     5  Predicted change in objective function too small.
%   Interior-point and sqp:
%    -3  Problem seems unbounded.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = FMINCON(FUN,X0,...) returns a structure 
%   OUTPUT with information such as total number of iterations, and final 
%   objective function value. See the documentation for a complete list.
%
%   [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = FMINCON(FUN,X0,...) returns the 
%   Lagrange multipliers at the solution X: LAMBDA.lower for LB, 
%   LAMBDA.upper for UB, LAMBDA.ineqlin is for the linear inequalities, 
%   LAMBDA.eqlin is for the linear equalities, LAMBDA.ineqnonlin is for the
%   nonlinear inequalities, and LAMBDA.eqnonlin is for the nonlinear 
%   equalities.
%
%   [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD] = FMINCON(FUN,X0,...) returns the 
%   value of the gradient of FUN at the solution X.
%
%   [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] = FMINCON(FUN,X0,...) 
%   returns the value of the exact or approximate Hessian of the Lagrangian
%   at X. 
%
%   Examples
%     FUN can be specified using @:
%        X = fmincon(@humps,...)
%     In this case, F = humps(X) returns the scalar function value F of 
%     the HUMPS function evaluated at X.
%
%     FUN can also be an anonymous function:
%        X = fmincon(@(x) 3*sin(x(1))+exp(x(2)),[1;1],[],[],[],[],[0 0])
%     returns X = [0;0].
%
%   If FUN or NONLCON are parameterized, you can use anonymous functions to
%   capture the problem-dependent parameters. Suppose you want to minimize 
%   the objective given in the function myfun, subject to the nonlinear 
%   constraint mycon, where these two functions are parameterized by their 
%   second argument a1 and a2, respectively. Here myfun and mycon are 
%   MATLAB file functions such as
%
%        function f = myfun(x,a1)      
%        f = x(1)^2 + a1*x(2)^2;       
%                                      
%        function [c,ceq] = mycon(x,a2)
%        c = a2/x(1) - x(2);
%        ceq = [];
%
%   To optimize for specific values of a1 and a2, first assign the values 
%   to these two parameters. Then create two one-argument anonymous 
%   functions that capture the values of a1 and a2, and call myfun and 
%   mycon with two arguments. Finally, pass these anonymous functions to 
%   FMINCON:
%
%        a1 = 2; a2 = 1.5; % define parameters first
%        options = optimset('Algorithm','interior-point'); % run interior-point algorithm
%        x = fmincon(@(x) myfun(x,a1),[1;2],[],[],[],[],[],[],@(x) mycon(x,a2),options)
%
%   See also OPTIMSET, OPTIMTOOL, FMINUNC, FMINBND, FMINSEARCH, @, FUNCTION_HANDLE.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/05/10 17:37:58 $

defaultopt = struct( ...
    'Algorithm','trust-region-reflective', ...
    'AlwaysHonorConstraints','bounds', ...
    'DerivativeCheck','off', ...
    'Diagnostics','off', ...
    'DiffMaxChange',1e-1, ...
    'DiffMinChange',1e-8, ...
    'Display','final', ...
    'FinDiffType','forward', ...    
    'FunValCheck','off', ...
    'GradConstr','off', ...
    'GradObj','off', ...
    'HessFcn',[], ...
    'Hessian',[], ...    
    'HessMult',[], ...
    'HessPattern','sparse(ones(numberOfVariables))', ...
    'InitBarrierParam',0.1, ...
    'InitTrustRegionRadius','sqrt(numberOfVariables)', ...
    'LargeScale','on', ...
    'MaxFunEvals',[], ...
    'MaxIter',[], ...
    'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
    'MaxProjCGIter','2*(numberOfVariables-numberOfEqualities)', ...    
    'MaxSQPIter','10*max(numberOfVariables,numberOfInequalities+numberOfBounds)', ...
    'NoStopIfFlatInfeas','off', ...
    'ObjectiveLimit',-1e20, ...
    'OutputFcn',[], ...
    'PhaseOneTotalScaling','off', ...
    'PlotFcns',[], ...
    'PrecondBandWidth',0, ...
    'RelLineSrchBnd',[], ...
    'RelLineSrchBndDuration',1, ...
    'ScaleProblem','obj-and-constr', ...
    'SubproblemAlgorithm','ldl-factorization', ...
    'TolCon',1e-6, ...
    'TolConSQP',1e-6, ...    
    'TolFun',1e-6, ...
    'TolGradCon',1e-6, ...
    'TolPCG',0.1, ...
    'TolProjCG',1e-2, ...
    'TolProjCGAbs',1e-10, ...
    'TolX',[], ...
    'TypicalX','ones(numberOfVariables,1)', ...
    'UseParallel','never' ...
    );

% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(FUN,'defaults')
   X = defaultopt;
   return
end

if nargin < 10
    options = [];
    if nargin < 9
        NONLCON = [];
        if nargin < 8
            UB = [];
            if nargin < 7
                LB = [];
                if nargin < 6
                    Beq = [];
                    if nargin < 5
                        Aeq = [];
                    end
                end
            end
        end
    end
end

problemInput = false;
if nargin == 1
    if isa(FUN,'struct')
        problemInput = true;
        [FUN,X,A,B,Aeq,Beq,LB,UB,NONLCON,options] = separateOptimStruct(FUN);
    else % Single input and non-structure.
        error('optim:fmincon:InputArg','The input to FMINCON should be either a structure with valid fields or consist of at least four arguments.' );
    end
end

if nargin < 4 && ~problemInput
  error('optim:fmincon:AtLeastFourInputs','FMINCON requires at least four input arguments.')
end

if isempty(NONLCON) && isempty(A) && isempty(Aeq) && isempty(UB) && isempty(LB)
   error('optim:fmincon:ConstrainedProblemsOnly', ...
         'FMINCON is for constrained problems. Use FMINUNC for unconstrained problems.')
end

% Check for non-double inputs
% SUPERIORFLOAT errors when superior input is neither single nor double;
% We use try-catch to override SUPERIORFLOAT's error message when input
% data type is integer.
try
    dataType = superiorfloat(X,A,B,Aeq,Beq,LB,UB);
catch ME
    if strcmp(ME.identifier,'MATLAB:datatypes:superiorfloat')
       dataType = 'notDouble';
    end
end

if ~strcmp(dataType,'double')
    error('optim:fmincon:NonDoubleInput', ...
        'FMINCON only accepts inputs of data type double.')
end

if nargout > 4
   computeLambda = true;
else 
   computeLambda = false;
end

activeSet = 'medium-scale: SQP, Quasi-Newton, line-search';
sqp = 'sequential quadratic programming';
trustRegionReflective = 'large-scale: trust-region reflective Newton';
interiorPoint = 'interior-point';

XOUT = X(:);
numberOfVariables=length(XOUT);
% Check for empty X
if numberOfVariables == 0
   error('optim:fmincon:EmptyX','You must provide a non-empty starting point.');
end

display = optimget(options,'Display',defaultopt,'fast');
flags.detailedExitMsg = ~isempty(strfind(display,'detailed'));
switch display
    case {'off','none'}
        verbosity = 0;
    case {'notify','notify-detailed'}
        verbosity = 1;
    case {'final','final-detailed'}
        verbosity = 2;
    case {'iter','iter-detailed'}
        verbosity = 3;
    case 'testing'
        verbosity = 4;
    otherwise
        verbosity = 2;
end

% Set linear constraint right hand sides to column vectors
% (in particular, if empty, they will be made the correct
% size, 0-by-1)
B = B(:);
Beq = Beq(:);

% Check for consistency of linear constraints, before evaluating
% (potentially expensive) user functions 

% Set empty linear constraint matrices to the correct size, 0-by-n
if isempty(Aeq)
    Aeq = reshape(Aeq,0,numberOfVariables);
end
if isempty(A)
    A = reshape(A,0,numberOfVariables);   
end

[lin_eq,Aeqcol] = size(Aeq);
[lin_ineq,Acol] = size(A);
% These sizes checks assume that empty matrices have already been made the correct size
if Aeqcol ~= numberOfVariables
   error('optim:fmincon:WrongNumberOfColumnsInAeq','Aeq must have %i column(s).',numberOfVariables)
end
if lin_eq ~= length(Beq)
    error('optim:fmincon:AeqAndBeqInconsistent', ...
        'Row dimension of Aeq is inconsistent with length of beq.')
end
if Acol ~= numberOfVariables
   error('optim:fmincon:WrongNumberOfColumnsInA','A must have %i column(s).',numberOfVariables)
end
if lin_ineq ~= length(B)
    error('optim:fmincon:AeqAndBinInconsistent', ...
        'Row dimension of A is inconsistent with length of b.')
end
% End of linear constraint consistency check

LargeScaleFlag = strcmpi(optimget(options,'LargeScale',defaultopt,'fast'),'on'); 
Algorithm = optimget(options,'Algorithm',defaultopt,'fast'); 
% Option needed for processing initial guess
AlwaysHonorConstraints = optimget(options,'AlwaysHonorConstraints',defaultopt,'fast'); 

% Read in and error check option TypicalX
[typicalx,ME] = getNumericOrStringFieldValue('TypicalX','ones(numberOfVariables,1)', ...
    ones(numberOfVariables,1),'a numeric value',options,defaultopt);
if ~isempty(ME)
    throw(ME)
end
checkoptionsize('TypicalX', size(typicalx), numberOfVariables);
chckdOpts.TypicalX = typicalx;

% Determine algorithm user chose via options. (We need this now
% to set OUTPUT.algorithm in case of early termination due to 
% inconsistent bounds.) 
% This algorithm choice may be modified later when we check the 
% problem type and supplied derivatives
algChoiceOptsConflict = false;
if strcmpi(Algorithm,'active-set')
    OUTPUT.algorithm = activeSet;
elseif strcmpi(Algorithm,'sqp')
    OUTPUT.algorithm = sqp;
elseif strcmpi(Algorithm,'interior-point')
    OUTPUT.algorithm = interiorPoint;
elseif strcmpi(Algorithm,'trust-region-reflective')
    if LargeScaleFlag
        OUTPUT.algorithm = trustRegionReflective;
    else
        % Conflicting options Algorithm='trust-region-reflective' and
        % LargeScale='off'. Choose active-set algorithm.
        algChoiceOptsConflict = true; % warn later, not in early termination
        OUTPUT.algorithm = activeSet;
    end
else
    error('optim:fmincon:InvalidAlgorithm',...
        ['Invalid choice of option Algorithm for FMINCON. Choose ''sqp'',', ...
        ' ''interior-point'', ''trust-region-reflective'', or ''active-set''.']);
end    

[XOUT,l,u,msg] = checkbounds(XOUT,LB,UB,numberOfVariables);
if ~isempty(msg)
   EXITFLAG = -2;
   [FVAL,LAMBDA,GRAD,HESSIAN] = deal([]);
   
   OUTPUT.iterations = 0;
   OUTPUT.funcCount = 0;
   OUTPUT.stepsize = [];
   if strcmpi(OUTPUT.algorithm,activeSet) || strcmpi(OUTPUT.algorithm,sqp)
       OUTPUT.lssteplength = [];
   else % trust-region-reflective, interior-point
       OUTPUT.cgiterations = [];
   end
   if strcmpi(OUTPUT.algorithm,interiorPoint) || strcmpi(OUTPUT.algorithm,activeSet) || ...
      strcmpi(OUTPUT.algorithm,sqp)
       OUTPUT.constrviolation = [];
   end
   OUTPUT.firstorderopt = [];
   OUTPUT.message = msg;
   
   X(:) = XOUT;
   if verbosity > 0
      disp(msg)
   end
   return
end
lFinite = l(~isinf(l));
uFinite = u(~isinf(u));

% Create structure of flags and initial values, initialize merit function
% type and the original shape of X.
flags.meritFunction = 0;
initVals.xOrigShape = X;

diagnostics = isequal(optimget(options,'Diagnostics',defaultopt,'fast'),'on');
funValCheck = strcmpi(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
flags.grad = strcmpi(optimget(options,'GradObj',defaultopt,'fast'),'on');

% Notice that defaultopt.Hessian = [], so the variable "hessian" can be empty
hessian = optimget(options,'Hessian',defaultopt,'fast'); 
% If calling trust-region-reflective with an unavailable Hessian option value, 
% issue informative error message
if strcmpi(OUTPUT.algorithm,trustRegionReflective) && ...
        ~( isempty(hessian) || strcmpi(hessian,'on') || strcmpi(hessian,'user-supplied') || ...
           strcmpi(hessian,'off') || strcmpi(hessian,'fin-diff-grads')  )
    error('optim:fmincon:BadTRReflectHessianValue', ...
        ['Value of Hessian option unavailable in trust-region-reflective algorithm. Possible\n' ...
         ' values are ''user-supplied'' and ''fin-diff-grads''.'])
end

if ~iscell(hessian) && ( strcmpi(hessian,'user-supplied') || strcmpi(hessian,'on') )
    flags.hess = true;
else
    flags.hess = false;
end

if isempty(NONLCON)
   flags.constr = false;
else
   flags.constr = true;
end

% Process objective function
if ~isempty(FUN)  % will detect empty string, empty matrix, empty cell array
   % constrflag in optimfcnchk set to false because we're checking the objective, not constraint
   funfcn = optimfcnchk(FUN,'fmincon',length(varargin),funValCheck,flags.grad,flags.hess,false,Algorithm);
else
   error('optim:fmincon:InvalidFUN', ...
         ['FUN must be a function handle;\n', ...
          ' or, FUN may be a cell array that contains function handles.']);
end

% Process constraint function
if flags.constr % NONLCON is non-empty
   flags.gradconst = strcmpi(optimget(options,'GradConstr',defaultopt,'fast'),'on');
   % hessflag in optimfcnchk set to false because hessian is never returned by nonlinear constraint 
   % function
   %
   % constrflag in optimfcnchk set to true because we're checking the constraints
   confcn = optimfcnchk(NONLCON,'fmincon',length(varargin),funValCheck,flags.gradconst,false,true);
else
   flags.gradconst = false; 
   confcn = {'','','','',''};
end

[rowAeq,colAeq] = size(Aeq);

% Look at problem type and supplied derivatives, and determine if need to
% switch algorithm
if strcmpi(OUTPUT.algorithm,activeSet) || strcmpi(OUTPUT.algorithm,sqp)
    % Check if Algorithm was originally set to 'trust-region-reflective'
    % and then changed to 'active-set' because LargeScale was 'off'.
    % Do not warn if Algorithm was set to 'sqp' (defensive code).
    if algChoiceOptsConflict && strcmpi(OUTPUT.algorithm,activeSet)
        % Active-set algorithm chosen as a result of conflicting options
        warning('optim:fmincon:NLPAlgLargeScaleConflict', ...
            ['Options LargeScale = ''off'' and Algorithm = ''trust-region-reflective'' conflict.\n' ...
            'Ignoring Algorithm and running active-set algorithm. To run trust-region-reflective, set\n' ...
            'LargeScale = ''on''. To run active-set without this warning, use Algorithm = ''active-set''.'])
    end
    if issparse(Aeq) || issparse(A)
        warning('optim:fmincon:ConvertingToFull', ...
            'Cannot use sparse matrices with %s algorithm: converting to full.',Algorithm)
    end
    if flags.hess % conflicting options
        flags.hess = false;
        warning('optim:fmincon:HessianIgnored', ...
            ['An analytic Hessian cannot be used when OPTIONS.Algorithm = ''%s''.\n' ...
            'OPTIONS.Hessian will be ignored (user-supplied Hessian will not be used).'], Algorithm);
        if isequal(funfcn{1},'fungradhess')
            funfcn{1}='fungrad';
        elseif  isequal(funfcn{1},'fun_then_grad_then_hess')
            funfcn{1}='fun_then_grad';
        end
    end
elseif strcmpi(OUTPUT.algorithm,trustRegionReflective)
    if isempty(NONLCON) && isempty(A) && isempty(Aeq) && flags.grad
        % if only l and u then call sfminbx
    elseif isempty(NONLCON) && isempty(A) && isempty(lFinite) && isempty(uFinite) && flags.grad ...
            && colAeq > rowAeq
        % if only Aeq beq and Aeq has more columns than rows, then call sfminle
    else
        warning('optim:fmincon:SwitchingToMediumScale', ...
            ['Trust-region-reflective algorithm does not solve this type of problem, ' ...
            'using active-set algorithm. You could also try the interior-point or ' ...
            'sqp algorithms: set the Algorithm option to ''interior-point'' ', ...
            'or ''sqp'' and rerun. For more help, see %s in the documentation.'], ...
            addLink('Choosing the Algorithm','choose_algorithm'))
        if isequal(funfcn{1},'fungradhess')
            funfcn{1}='fungrad';
            warning('optim:fmincon:HessianIgnored', ...
                ['Active-set algorithm is a Quasi-Newton method and does not use\n' ...
                'analytic Hessian. Hessian flag in options will be ignored.'])
        elseif  isequal(funfcn{1},'fun_then_grad_then_hess')
            funfcn{1}='fun_then_grad';
            warning('optim:fmincon:HessianIgnored', ...
                ['Active-set algorithm is a Quasi-Newton method and does not use\n' ...
                'analytic Hessian. Hessian flag in options will be ignored.'])
        end
        flags.hess = false;
        OUTPUT.algorithm = activeSet; % switch to active-set
    end
end

lenvlb = length(l);
lenvub = length(u);

if strcmpi(OUTPUT.algorithm,activeSet)
   %
   % Ensure starting point lies within bounds
   %
   i=1:lenvlb;
   lindex = XOUT(i)<l(i);
   if any(lindex)
      XOUT(lindex)=l(lindex)+1e-4; 
   end
   i=1:lenvub;
   uindex = XOUT(i)>u(i);
   if any(uindex)
      XOUT(uindex)=u(uindex);
   end
   X(:) = XOUT;
elseif strcmpi(OUTPUT.algorithm,trustRegionReflective)
   %
   % If components of initial x not within bounds, set those components  
   % of initial point to a "box-centered" point
   %
   arg = (u >= 1e10); arg2 = (l <= -1e10);
   u(arg) = inf;
   l(arg2) = -inf;
   xinitOutOfBounds_idx = XOUT < l | XOUT > u;
   if any(xinitOutOfBounds_idx)
       XOUT = startx(u,l,XOUT,xinitOutOfBounds_idx);
       X(:) = XOUT;
   end
elseif strcmpi(OUTPUT.algorithm,interiorPoint)
    % Variables: fixed, finite lower bounds, finite upper bounds
    xIndices = classifyBoundsOnVars(l,u,numberOfVariables,true);

    % If honor bounds mode, then check that initial point strictly satisfies the
    % simple inequality bounds on the variables and exactly satisfies fixed variable
    % bounds.
    if strcmpi(AlwaysHonorConstraints,'bounds') || strcmpi(AlwaysHonorConstraints,'bounds-ineqs')
        violatedFixedBnds_idx = XOUT(xIndices.fixed) ~= l(xIndices.fixed);
        violatedLowerBnds_idx = XOUT(xIndices.finiteLb) <= l(xIndices.finiteLb);
        violatedUpperBnds_idx = XOUT(xIndices.finiteUb) >= u(xIndices.finiteUb);
        if any(violatedLowerBnds_idx) || any(violatedUpperBnds_idx) || any(violatedFixedBnds_idx)
            if verbosity >= 4 
                fprintf(['Initial point not strictly inside bounds and AlwaysHonorConstraints=''%s'';\n' ...
                    ' shifting initial point inside bounds.\n'],AlwaysHonorConstraints);
            end
            XOUT = shiftInitPtToInterior(numberOfVariables,XOUT,l,u,Inf);
            X(:) = XOUT;
        end
    end
else % SQP
    % Classify variables: finite lower bounds, finite upper bounds
    xIndices = classifyBoundsOnVars(l,u,numberOfVariables,false);
    
    % SQP always honors the bounds. Check that initial point
    % strictly satisfies the bounds on the variables.
    violatedLowerBnds_idx = XOUT(xIndices.finiteLb) < l(xIndices.finiteLb);
    violatedUpperBnds_idx = XOUT(xIndices.finiteUb) > u(xIndices.finiteUb);
    if any(violatedLowerBnds_idx) || any(violatedUpperBnds_idx)
        if verbosity >= 4
            fprintf(['Initial point not inside bounds for the sqp algorithm;\n' ...
                ' shifting initial point inside bounds.\n']);
        end
        
        finiteLbIdx = find(xIndices.finiteLb);
        finiteUbIdx = find(xIndices.finiteUb);
        XOUT(finiteLbIdx(violatedLowerBnds_idx)) = l(finiteLbIdx(violatedLowerBnds_idx));
        XOUT(finiteUbIdx(violatedUpperBnds_idx)) = u(finiteUbIdx(violatedUpperBnds_idx));
        X(:) = XOUT;
    end
end

% Evaluate function
initVals.g = zeros(numberOfVariables,1);
HESSIAN = [];

switch funfcn{1}
case 'fun'
   try
      initVals.f = feval(funfcn{3},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:ObjectiveError', ...
            'Failure in initial user-supplied objective function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
case 'fungrad'
   try
      [initVals.f,initVals.g(:)] = feval(funfcn{3},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:ObjectiveError', ...
            'Failure in initial user-supplied objective function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
case 'fungradhess'
   try
      [initVals.f,initVals.g(:),HESSIAN] = feval(funfcn{3},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:ObjectiveError', ...
            'Failure in initial user-supplied objective function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
case 'fun_then_grad'
   try
      initVals.f = feval(funfcn{3},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:ObjectiveError', ...
            'Failure in initial user-supplied objective function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
   try
      initVals.g(:) = feval(funfcn{4},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:GradientError', ...
            'Failure in initial user-supplied objective gradient function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
case 'fun_then_grad_then_hess'
   try
      initVals.f = feval(funfcn{3},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:ObjectiveError', ...
            'Failure in initial user-supplied objective function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
   try
      initVals.g(:) = feval(funfcn{4},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:GradientError', ...
            'Failure in initial user-supplied objective gradient function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
   try
      HESSIAN = feval(funfcn{5},X,varargin{:});
   catch userFcn_ME
        optim_ME = MException('optim:fmincon:HessianError', ...
            'Failure in initial user-supplied objective Hessian function evaluation. FMINCON cannot continue.');            
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
   end
otherwise
   error('optim:fmincon:UndefinedCallType','Undefined calltype in FMINCON.');
end

% Check that the objective value is a scalar
if numel(initVals.f) ~= 1
   error('optim:fmincon:NonScalarObj','User supplied objective function must return a scalar value.')
end

% Evaluate constraints
switch confcn{1}
case 'fun'
    try
        [ctmp,ceqtmp] = feval(confcn{3},X,varargin{:});
    catch userFcn_ME
        if strcmpi('MATLAB:maxlhs',userFcn_ME.identifier)
                error('optim:fmincon:InvalidHandleNonlcon', ...
                    ['The constraint function must return two outputs; ' ... 
                     'the nonlinear inequality constraints and ' ...
                     'the nonlinear equality constraints.'])
        else
            optim_ME = MException('optim:fmincon:NonlconError', ...
                'Failure in initial user-supplied nonlinear constraint function evaluation. FMINCON cannot continue.');
            userFcn_ME = addCause(userFcn_ME,optim_ME);
            rethrow(userFcn_ME)
        end
    end
    initVals.ncineq = ctmp(:);
    initVals.nceq = ceqtmp(:);
    initVals.gnc = zeros(numberOfVariables,length(initVals.ncineq));
    initVals.gnceq = zeros(numberOfVariables,length(initVals.nceq));
case 'fungrad'
   try
      [ctmp,ceqtmp,initVals.gnc,initVals.gnceq] = feval(confcn{3},X,varargin{:});
   catch userFcn_ME
       optim_ME = MException('optim:fmincon:NonlconError', ...
           'Failure in initial user-supplied nonlinear constraint function evaluation. FMINCON cannot continue.');           
       userFcn_ME = addCause(userFcn_ME,optim_ME);
       rethrow(userFcn_ME)
   end
   initVals.ncineq = ctmp(:);
   initVals.nceq = ceqtmp(:);
case 'fun_then_grad'
    try
        [ctmp,ceqtmp] = feval(confcn{3},X,varargin{:});
    catch userFcn_ME
        optim_ME = MException('optim:fmincon:NonlconError', ...
            'Failure in initial user-supplied nonlinear constraint function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
    end
    initVals.ncineq = ctmp(:);
    initVals.nceq = ceqtmp(:);
    try
        [initVals.gnc,initVals.gnceq] = feval(confcn{4},X,varargin{:});
    catch userFcn_ME
        optim_ME = MException('optim:fmincon:NonlconFunOrGradError', ...
            'Failure in initial user-supplied nonlinear constraint gradinet function evaluation. FMINCON cannot continue.');
        userFcn_ME = addCause(userFcn_ME,optim_ME);
        rethrow(userFcn_ME)
    end
case ''
   % No nonlinear constraints. Reshaping of empty quantities is done later
   % in this file, where both cases, (i) no nonlinear constraints and (ii)
   % nonlinear constraints that have one type missing (equalities or
   % inequalities), are handled in one place
   initVals.ncineq = [];
   initVals.nceq = [];
   initVals.gnc = [];
   initVals.gnceq = [];
otherwise
   error('optim:fmincon:UndefinedCalltype','Undefined calltype in FMINCON.');
end

non_eq = length(initVals.nceq);
non_ineq = length(initVals.ncineq);

% Make sure empty constraint and their derivatives have correct sizes (not 0-by-0):
if isempty(initVals.ncineq)
    initVals.ncineq = reshape(initVals.ncineq,0,1);
end
if isempty(initVals.nceq)
    initVals.nceq = reshape(initVals.nceq,0,1);
end
if isempty(initVals.gnc)
    initVals.gnc = reshape(initVals.gnc,numberOfVariables,0);
end
if isempty(initVals.gnceq)
    initVals.gnceq = reshape(initVals.gnceq,numberOfVariables,0);
end
[cgrow,cgcol] = size(initVals.gnc);
[ceqgrow,ceqgcol] = size(initVals.gnceq);

if cgrow ~= numberOfVariables || cgcol ~= non_ineq
   error('optim:fmincon:WrongSizeGradNonlinIneq', ...
         'Gradient of nonlinear inequality constraints must have size %i-by-%i.', ...
         numberOfVariables,non_ineq)
end
if ceqgrow ~= numberOfVariables || ceqgcol ~= non_eq
   error('optim:fmincon:WrongSizeGradNonlinEq', ...
         'Gradient of nonlinear equality constraints must have size %i-by-%i.', ...
         numberOfVariables,non_eq)
end

if diagnostics > 0
   % Do diagnostics on information so far
   diagnose('fmincon',OUTPUT,flags.grad,flags.hess,flags.constr,flags.gradconst,...
      ~LargeScaleFlag,options,defaultopt,XOUT,non_eq,...
      non_ineq,lin_eq,lin_ineq,l,u,funfcn,confcn,initVals.f,initVals.g,HESSIAN, ...
      initVals.ncineq,initVals.nceq,initVals.gnc,initVals.gnceq);
end

% call algorithm
if strcmpi(OUTPUT.algorithm,activeSet) % active-set
    defaultopt.MaxIter = 400; defaultopt.MaxFunEvals = '100*numberofvariables'; defaultopt.TolX = 1e-6;
    defaultopt.Hessian = 'off';
    problemInfo = []; % No problem related data
    [X,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN]=...
        nlconst(funfcn,X,l,u,full(A),B,full(Aeq),Beq,confcn,options,defaultopt, ...
        chckdOpts,verbosity,flags,initVals,problemInfo,varargin{:});
elseif strcmpi(OUTPUT.algorithm,trustRegionReflective) % trust-region-reflective
   if (isequal(funfcn{1}, 'fun_then_grad_then_hess') || isequal(funfcn{1}, 'fungradhess'))
      Hstr = [];
   elseif (isequal(funfcn{1}, 'fun_then_grad') || isequal(funfcn{1}, 'fungrad'))
      n = length(XOUT); 
      Hstr = optimget(options,'HessPattern',defaultopt,'fast');
      if ischar(Hstr) 
         if isequal(lower(Hstr),'sparse(ones(numberofvariables))')
            Hstr = sparse(ones(n));
         else
            error('optim:fmincon:InvalidHessPattern', ...
                  'Option ''HessPattern'' must be a matrix if not the default.')
         end
      end
      checkoptionsize('HessPattern', size(Hstr), n);
   end
   
   defaultopt.MaxIter = 400; defaultopt.MaxFunEvals = '100*numberofvariables'; defaultopt.TolX = 1e-6;
   defaultopt.Hessian = 'off';
   % Trust-region-reflective algorithm does not compute constraint
   % violation as it progresses. If the user requests the output structure,
   % we need to calculate the constraint violation at the returned
   % solution.
   if nargout > 3
       computeConstrViolForOutput = true;
   else
       computeConstrViolForOutput = false;
   end
   if isempty(Aeq)
      [X,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = ...
         sfminbx(funfcn,X,l,u,verbosity,options,defaultopt,computeLambda,initVals.f,initVals.g, ...
         HESSIAN,Hstr,flags.detailedExitMsg,computeConstrViolForOutput,varargin{:});
   else
      [X,FVAL,LAMBDA,EXITFLAG,OUTPUT,GRAD,HESSIAN] = ...
         sfminle(funfcn,X,sparse(Aeq),Beq,verbosity,options,defaultopt,computeLambda,initVals.f, ...
         initVals.g,HESSIAN,Hstr,flags.detailedExitMsg,computeConstrViolForOutput,varargin{:});
   end
elseif strcmpi(OUTPUT.algorithm,interiorPoint)
    defaultopt.MaxIter = 1000; defaultopt.MaxFunEvals = 3000; defaultopt.TolX = 1e-10;
    defaultopt.Hessian = 'bfgs';
    mEq = lin_eq + non_eq + nnz(xIndices.fixed); % number of equalities
    % Interior-point-specific options. Default values for lbfgs memory is 10, and 
    % ldl pivot threshold is 0.01
    [options_ip,optionFeedback] = getIpOptions(options,numberOfVariables,mEq,flags.constr,defaultopt,10,0.01); 

    [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] = barrier(funfcn,X,A,B,Aeq,Beq,l,u,confcn,options_ip.HessFcn, ...
        initVals.f,initVals.g,initVals.ncineq,initVals.nceq,initVals.gnc,initVals.gnceq,HESSIAN, ...
        xIndices,options_ip,optionFeedback,varargin{:});
else % sqp
    defaultopt.MaxIter = 400; defaultopt.MaxFunEvals = '100*numberofvariables'; 
    defaultopt.TolX = 1e-6; defaultopt.Hessian = 'bfgs';
    % Validate options used by sqp
    [options,optionFeedback] = getSQPOptions(options,defaultopt,numberOfVariables);
    optionFeedback.detailedExitMsg = flags.detailedExitMsg;
    % Call algorithm
    [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] = sqpLineSearch(funfcn,X,full(A),full(B),full(Aeq),full(Beq), ...
        full(l),full(u),confcn,initVals.f,full(initVals.g),full(initVals.ncineq),full(initVals.nceq), ...
        full(initVals.gnc),full(initVals.gnceq),xIndices,options,verbosity,optionFeedback,varargin{:});
end
