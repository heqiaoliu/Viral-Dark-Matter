function [x,FVAL,MAXFVAL,EXITFLAG,OUTPUT,LAMBDA] = fminimax(FUN,x,A,B,Aeq,Beq,LB,UB,NONLCON,options,varargin)
%FMINIMAX finds a minimax solution of a function of several variables.
%   FMINIMAX attempts to solve the following problem:
%   min (max {FUN(X} )  where FUN and X can be vectors or matrices.
%    X 
% 
%   X = FMINIMAX(FUN,X0) starts at X0 and finds a minimax solution X to 
%   the functions in FUN. FUN accepts input X and returns a vector
%   (matrix) of function values F evaluated at X. X0 may be a scalar,
%   vector, or matrix. 
%
%   X = FMINIMAX(FUN,X0,A,B) solves the minimax problem subject to the
%   linear inequalities A*X <= B.
%
%   X = FMINIMAX(FUN,X0,A,B,Aeq,Beq) solves the minimax problem
%   subject to the linear equalities Aeq*X = Beq as well.  (Set A = [] and 
%   B = [] if no inequalities exist.)
%
%   X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB) defines a set of lower 
%   and upper bounds on the design variables, X, so that the solution is 
%   in the range LB <= X <= UB. You may use empty matrices for LB and UB
%   if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below; 
%   set UB(i) = Inf if X(i) is unbounded above.
%   
%   X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON) subjects the 
%   goal attainment problem to the constraints defined in NONLCON (usually 
%   a MATLAB file: NONLCON.m). The function NONLCON should return the vectors
%   C and Ceq, representing the nonlinear inequalities and equalities 
%   respectively, when called with feval: [C, Ceq] = feval(NONLCON,X). 
%   FMINIMAX optimizes such that C(X) <= 0 and Ceq(X) = 0.
%
%   X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS) minimizes with 
%   the default optimization parameters replaced by values in the structure 
%   OPTIONS, an argument created with the OPTIMSET function. See OPTIMSET 
%   for details.  Used options are Display, TolX, TolFun, TolCon, 
%   DerivativeCheck, FunValCheck, GradObj, GradConstr, MaxFunEvals,
%   MaxIter, MeritFunction, MinAbsMax, Diagnostics, DiffMinChange,
%   DiffMaxChange, PlotFcns, OutputFcn, and TypicalX. Use the GradObj
%   option to specify that FUN may be called with two output arguments
%   where the second, G, is the partial derivatives of the function df/dX,
%   at  the point X: [F,G] = feval(FUN,X). Use the GradConstr option to
%   specify that  NONLCON may be called with four output arguments:
%   [C,Ceq,GC,GCeq] = feval(NONLCON,X) where GC is the partial derivatives
%   of  the constraint vector of inequalities C an GCeq is the partial
%   derivatives  of the constraint vector of equalities Ceq. Use OPTIONS =
%   [] as a place  holder if no options are set.
%
%   X = FMINIMAX(PROBLEM) finds a minimax solution for PROBLEM. PROBLEM is 
%   a structure with the function FUN in PROBLEM.objective, the start point
%   in PROBLEM.x0, the linear inequality constraints in PROBLEM.Aineq
%   and PROBLEM.bineq, the linear equality constraints in PROBLEM.Aeq and
%   PROBLEM.beq, the lower bounds in PROBLEM.lb, the upper bounds in 
%   PROBLEM.ub, the nonlinear constraint function in PROBLEM.nonlcon, the
%   options structure in PROBLEM.options, and solver name 'fminimax' in
%   PROBLEM.solver. Use this syntax to solve at the command line a problem 
%   exported from OPTIMTOOL. The structure PROBLEM must have all the fields.
%
%   [X,FVAL] = FMINIMAX(FUN,X0,...) returns the value of the objective 
%   functions at the solution X: FVAL = feval(FUN,X).
%
%   [X,FVAL,MAXFVAL] = FMINIMAX(FUN,X0,...) returns 
%   MAXFVAL = max { FUN(X) } at the solution X.
%
%   [X,FVAL,MAXFVAL,EXITFLAG] = FMINIMAX(FUN,X0,...) returns an EXITFLAG 
%   that describes the exit condition of FMINIMAX. Possible values of 
%   EXITFLAG and the corresponding exit conditions are listed below. See
%   the documentation for a complete description.
%
%     1  FMINIMAX converged to a solution.
%     4  Computed search direction too small.
%     5  Predicted change in max objective function too small.
%     0  Too many function evaluations or iterations.
%    -1  Stopped by output/plot function.
%    -2  No feasible point found.
%   
%   [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT] = FMINIMAX(FUN,X0,...) returns a 
%   structure OUTPUT with the number of iterations taken in 
%   OUTPUT.iterations, the number of function evaluations in 
%   OUTPUT.funcCount, the norm of the final step in OUTPUT.stepsize, the 
%   final line search steplength in OUTPUT.lssteplength, the algorithm used
%   in OUTPUT.algorithm, the first-order optimality in 
%   OUTPUT.firstorderopt, and the exit message in OUTPUT.message. 
%
%   [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT,LAMBDA] = FMINIMAX(FUN,X0,...) returns 
%   the Lagrange multipliers at the solution X: LAMBDA.lower for LB, 
%   LAMBDA.upper for UB, LAMBDA.ineqlin is for the linear inequalities, 
%   LAMBDA.eqlin is for the linear equalities, LAMBDA.ineqnonlin is for the
%   nonlinear inequalities, and LAMBDA.eqnonlin is for the nonlinear 
%   equalities.
%
%   Examples
%     FUN can be specified using @:
%        x = fminimax(@myfun,[2 3 4])
%
%   where myfun is a MATLAB function such as:
%
%       function F = myfun(x)
%       F = cos(x);
%
%   FUN can also be an anonymous function:
%
%       x = fminimax(@(x) sin(3*x),[2 5])
%
%   If FUN is parameterized, you can use anonymous functions to capture the 
%   problem-dependent parameters. Suppose you want to solve a minimax 
%   problem where the objectives given in the function myfun are 
%   parameterized by its second argument c. Here myfun is a MATLAB file 
%   function such as
%
%       function F = myfun(x,c)
%       F = [x(1)^2 + c*x(2)^2;
%            x(2) - x(1)];
%
%   To optimize for a specific value of c, first assign the value to c. 
%   Then create a one-argument anonymous function that captures that value 
%   of c and calls myfun with two arguments. Finally pass this anonymous 
%   function to FMINIMAX:
%
%       c = 2; % define parameter first
%       x = fminimax(@(x) myfun(x,c),[1;1])
%
%   See also OPTIMSET, @, INLINE, FGOALATTAIN, LSQNONLIN.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2010/02/08 22:38:36 $


defaultopt = struct( ...
    'DerivativeCheck','off', ...
    'Diagnostics','off', ...
    'DiffMaxChange',1e-1, ...
    'DiffMinChange',1e-8, ...
    'Display','final', ...
    'FinDiffType','forward', ...
    'FunValCheck','off', ...
    'GradConstr','off', ...
    'GradObj','off', ...
    'Hessian','off', ...    % Not used
    'LargeScale','off', ... % Not used    
    'MaxFunEvals','100*numberOfVariables', ...
    'MaxIter',400, ...    
    'MaxSQPIter','10*max(numberOfVariables,numberOfInequalities+numberOfBounds)', ...    
    'MeritFunction','multiobj', ...    
    'MinAbsMax',0, ...
    'NoStopIfFlatInfeas','off', ...    
    'OutputFcn',[], ...
    'PhaseOneTotalScaling','off', ...    
    'PlotFcns',[], ...    
    'RelLineSrchBnd',[], ...
    'RelLineSrchBndDuration',1, ...    
    'TolCon',1e-6, ...
    'TolConSQP',1e-6, ...
    'TolFun',1e-6, ...
    'TolX',1e-6, ...
    'TypicalX','ones(numberOfVariables,1)', ...
    'UseParallel','never' ...
    );
% If just 'defaults' passed in, return the default options in X
if nargin == 1 && nargout <= 1 && isequal(FUN,'defaults')
   x = defaultopt;
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
                        if nargin < 4
                            B = [];
                            if nargin < 3
                                A = [];
                            end
                        end
                    end
                end
            end
        end
    end
end

% Detect problem structure input
if nargin == 1
    if isa(FUN,'struct')
        [FUN,x,A,B,Aeq,Beq,LB,UB,NONLCON,options] = separateOptimStruct(FUN);
    else % Single input and non-structure.
        error('optim:fminimax:InputArg','The input to FMINIMAX should be either a structure with valid fields or consist of at least two arguments.');
    end
end

if nargin == 0 
    error('optim:fminimax:NotEnoughInputs','FMINIMAX requires two input arguments.')
end

% Check for non-double inputs
% SUPERIORFLOAT errors when superior input is neither single nor double;
% We use try-catch to override SUPERIORFLOAT's error message when input
% data type is integer.
try
    dataType = superiorfloat(x,A,B,Aeq,Beq,LB,UB);
catch ME
    if strcmp(ME.identifier,'MATLAB:datatypes:superiorfloat')
        dataType = 'notDouble';
    end
end

if ~strcmp(dataType,'double')
    error('optim:fminimax:NonDoubleInput', ...
        'FMINIMAX only accepts inputs of data type double.')
end

initVals.xOrigShape = x;
xnew = [x(:); 0];

numberOfVariablesplus1 = length(xnew);
numberOfVariables = numberOfVariablesplus1 - 1;

diagnostics = isequal(optimget(options,'Diagnostics',defaultopt,'fast'),'on');

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
    otherwise
        verbosity = 2;
end

% Set to column vectors
B = B(:);
Beq = Beq(:);

[xnew(1:numberOfVariables),l,u,msg] = checkbounds(xnew(1:numberOfVariables),LB,UB,numberOfVariables);
if ~isempty(msg)
    EXITFLAG = -2;
    [FVAL,MAXFVAL,LAMBDA] = deal([]);
    OUTPUT.iterations = 0;
    OUTPUT.funcCount = 0;
    OUTPUT.stepsize = [];
    OUTPUT.lssteplength = [];
    OUTPUT.algorithm = 'minimax SQP, Quasi-Newton, line_search';
    OUTPUT.firstorderopt = [];
    OUTPUT.constrviolation =[];
    OUTPUT.message = msg;
    x(:) = xnew(1:numberOfVariables);
    if verbosity > 0
        disp(msg)
    end
    return
end

neqgoals = optimget(options, 'MinAbsMax',defaultopt,'fast');

% flags.meritFunction is 1 unless changed by user to fmincon merit function;
% formerly options(7)
% 0 uses the fmincon single-objective merit and Hess; 1 is the default
flags.meritFunction = strcmp(optimget(options,'MeritFunction',defaultopt,'fast'),'multiobj');
lenVarIn = length(varargin);
% goalcon and goalfun also take:
% neqgoals,funfcn,gradfcn,WEIGHT,GOAL,x,errCheck
goalargs = 7; 

funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');
usergradflag = strcmp(optimget(options,'GradObj',defaultopt,'fast'),'on');
usergradconstflag = strcmp(optimget(options,'GradConstr',defaultopt,'fast'),'on');
userhessflag = strcmp(optimget(options,'Hessian',defaultopt,'fast'),'on');
if userhessflag
    warning('optim:fminimax:UserHessNotUsed','FMINIMAX does not use user-supplied Hessian.')
    userhessflag = 0;
end

if isempty(NONLCON)
    userconstflag = 0;
else
    userconstflag = 1;
end

% Read in and error check option TypicalX
[typicalx,ME] = getNumericOrStringFieldValue('TypicalX','ones(numberOfVariables,1)', ...
    ones(numberOfVariables,1),'a numeric value',options,defaultopt);
if ~isempty(ME)
    throw(ME)
end
checkoptionsize('TypicalX', size(typicalx), numberOfVariables);
chckdOpts.TypicalX = [typicalx(:); 1]; % add element for auxiliary variable

line_search = strcmp(optimget(options,'LargeScale',defaultopt,'fast'),'off'); % 0 means trust-region, 1 means line-search
if ~line_search
    warning('optim:fminimax:NoLargeScale','Large-scale algorithm not currently available for this problem type.')
    line_search = 1;
end

flags.grad = 1; % always can compute gradient of goalfun since based on x
flags.hess = 0;
% If (user) nonlinear constraints exist, need 
%  either both function and constraint gradients, or not

if userconstflag
    if usergradflag && usergradconstflag
        flags.gradconst = 1;
    elseif usergradflag && ~usergradconstflag
        usergradflag = 0;
        flags.gradconst = 0;
    elseif ~usergradflag && usergradconstflag
        usergradconstflag = 0;
        flags.gradconst = 0;
    else
        flags.gradconst = 0;
    end
else % No user nonlinear constraints
    if usergradflag
        flags.gradconst = 1;
    else
        flags.gradconst = 0;
    end
end

% Convert to inline function as needed
if ~isempty(FUN)  % will detect empty string, empty matrix, empty cell array
   funfcn = optimfcnchk(FUN,'goalcon',length(varargin),funValCheck,usergradflag,userhessflag);
else
   error('optim:fminimax:invalidFUN', ...
         'FUN must be a function handle or a cell array of two function handles.')
end
% We can always compute gradient since based only on xnew.
% Pass in false for funValCheck argument as goalfun is not a user function.
ffun = optimfcnchk(@goalfun,'fminimax',lenVarIn+goalargs,false,flags.grad);

if userconstflag % NONLCON is non-empty, goalcon is the caller to NONLCON
   confcn = ...
      optimfcnchk(NONLCON,'goalcon',length(varargin),funValCheck,usergradconstflag,0,1);
else
   confcn{1} = '';
end
% Pass in false for funValCheck argument as goalfun is not a user function
cfun = optimfcnchk(@goalcon,'fminimax',lenVarIn+goalargs,false,flags.gradconst,0,1); 

lenvlb = length(l);
lenvub = length(u);

i = 1:lenvlb;
lindex = xnew(i) < l(i);
if any(lindex)
   xnew(lindex) = l(lindex) + 1e-4; 
end
i = 1:lenvub;
uindex = xnew(i) > u(i);
if any(uindex)
   xnew(uindex) = u(uindex);
end
x(:) = xnew(1:end-1);

% Evaluate user function to get number of function values at x.
user_f = feval(funfcn{3},x,varargin{:});
user_f = user_f(:);
len_user_f = length(user_f);

% Check if neqgoals (MinAbsMax) is less or equal to the length of user function                           
if neqgoals > len_user_f
    warning('optim:fminimax:InconsistentNumEqGoal', ...
        'Option MinAbsMax cannot be greater than the number of elements in F returned by FUN. Setting MinAbsMax to numel(F) instead.')
    % The number of F(x) to minimize the worst case absolute values can be
    % at most equal to the length of user objective function.
    neqgoals = len_user_f;
end

WEIGHT = ones(len_user_f,1);
GOAL = zeros(len_user_f,1);

initVals.g = zeros(numberOfVariablesplus1,1);
initVals.H = [];
errCheck = true; % Perform error checking on initial function evaluations

extravarargin = {neqgoals,funfcn,confcn,WEIGHT,GOAL,x,errCheck,varargin{:}}; 
% Evaluate goal function
switch ffun{1}
    case 'fun'
        initVals.f = feval(ffun{3},xnew,extravarargin{:});
    case 'fungrad'
        [initVals.f,initVals.g] = feval(ffun{3},xnew,extravarargin{:});
    otherwise
        error('optim:fminimax:UndefinedCalltype','Undefined calltype in FMINIMAX.')
end

% Evaluate goal constraints
switch cfun{1}
    case 'fun'
        [ctmp,ceqtmp] = feval(cfun{3},xnew,extravarargin{:});
        initVals.ncineq = ctmp(:);
        initVals.nceq = ceqtmp(:);
        initVals.gnc = zeros(numberOfVariablesplus1,length(initVals.ncineq));
        initVals.gnceq = zeros(numberOfVariablesplus1,length(initVals.nceq));
    case 'fungrad'
        [ctmp,ceqtmp,initVals.gnc,initVals.gnceq] = feval(cfun{3},xnew,extravarargin{:});
        initVals.ncineq = ctmp(:);
        initVals.nceq = ceqtmp(:);
    otherwise
        error('optim:fminimax:UndefinedCalltype','Undefined calltype in FMINIMAX.')
end

% Make sure empty constraint and their derivatives have correct sizes (not 0-by-0):
if isempty(initVals.ncineq)
    initVals.ncineq = reshape(initVals.ncineq,0,1);
end
if isempty(initVals.nceq)
    initVals.nceq = reshape(initVals.nceq,0,1);
end
if isempty(Aeq)
    Aeq = reshape(Aeq,0,numberOfVariables);
    Beq = reshape(Beq,0,1);
end
if isempty(A)
    A = reshape(A,0,numberOfVariables);
    B = reshape(B,0,1);    
end

non_eq = length(initVals.nceq);
non_ineq = length(initVals.ncineq);
[lin_eq,Aeqcol] = size(Aeq);
[lin_ineq,Acol] = size(A);

if Aeqcol ~= numberOfVariables
   error('optim:fminimax:InvalidSizeOfAeq', ...
       'Aeq must have %i column(s).',numberOfVariables)
end
if Acol ~= numberOfVariables
   error('optim:fminimax:InvalidSizeOfA', ...
       'A must have %i column(s).',numberOfVariables)
end

just_user_constraints = non_ineq - len_user_f - neqgoals;
OUTPUT.algorithm = 'minimax SQP, Quasi-Newton, line_search';

if diagnostics > 0
    % Do diagnostics on information so far
    diagnose('fminimax',OUTPUT,usergradflag,userhessflag,userconstflag,usergradconstflag,...
        line_search,options,defaultopt,xnew(1:end-1),non_eq,...
        just_user_constraints,lin_eq,lin_ineq,l,u,funfcn,confcn,initVals.f,initVals.g,initVals.H, ...
        initVals.ncineq(1:just_user_constraints),initVals.nceq,initVals.gnc(1:just_user_constraints,:),initVals.gnceq);
end


% Add extra column to account for extra xnew component
A = [A,zeros(lin_ineq,1)];
Aeq = [Aeq,zeros(lin_eq,1)];

% Only need to perform error checking on initial function evaluations
errCheck = false;

% Convert function handles to anonymous functions with additional arguments
% in its workspace. Even though ffun and cfun are internal functions, put fevals
% here for consistency.
ffun{3} = @(y,varargin) feval(ffun{3},y,neqgoals,funfcn,confcn,WEIGHT,GOAL,x,errCheck,varargin{:});
cfun{3} = @(y,varargin) feval(cfun{3},y,neqgoals,funfcn,confcn,WEIGHT,GOAL,x,errCheck,varargin{:});

% Problem related data is passed to nlconst in problemInfo structure
problemInfo.nHardConstraints = neqgoals;
problemInfo.weight = WEIGHT;
problemInfo.goal = GOAL;

[xnew,gamma,LAMBDA,EXITFLAG,OUTPUT]=...
   nlconst(ffun,xnew,l,u,full(A),B,full(Aeq),Beq,cfun,options,defaultopt, ...
   chckdOpts,verbosity,flags,initVals,problemInfo,varargin{:});

if ~isempty(LAMBDA)
    just_user_constraints = length(LAMBDA.ineqnonlin) - len_user_f - neqgoals;
    LAMBDA.ineqnonlin = LAMBDA.ineqnonlin(1:just_user_constraints);
end

OUTPUT.algorithm = 'minimax SQP, Quasi-Newton, line_search';  % override nlconst output

% Evaluate user objective functions, find maxfval
x(:) = xnew(1:end-1);
FVAL = feval(funfcn{3},x,varargin{:});
MAXFVAL = max(FVAL);
