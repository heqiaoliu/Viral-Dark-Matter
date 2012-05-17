function [X,resnorm,residual,exitflag,output,lambda] = lsqlin(C,d,A,b,Aeq,beq,lb,ub,X0,options,varargin)
%LSQLIN Constrained linear least squares.
%   X = LSQLIN(C,d,A,b) attempts to solve the least-squares problem
%
%           min  0.5*(NORM(C*x-d)).^2       subject to    A*x <= b
%            x
%
%   where C is m-by-n.
%
%   X = LSQLIN(C,d,A,b,Aeq,beq) solves the least-squares
%   (with equality constraints) problem:
%
%           min  0.5*(NORM(C*x-d)).^2    subject to 
%            x                               A*x <= b and Aeq*x = beq
%
%   X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB) defines a set of lower and upper
%   bounds on the design variables, X, so that the solution
%   is in the range LB <= X <= UB. Use empty matrices for 
%   LB and UB if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded 
%   below; set UB(i) = Inf if X(i) is unbounded above.
%
%   X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0) sets the starting point to X0.
%
%   X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0,OPTIONS) minimizes with the default 
%   optimization parameters replaced by values in the structure OPTIONS, an 
%   argument created with the OPTIMSET function. See OPTIMSET for details. 
%   Used options are Display, Diagnostics, TolFun, LargeScale, MaxIter, 
%   JacobMult, PrecondBandWidth, TypicalX, TolPCG, and MaxPCGIter. 
%   Currently, only 'final' and 'off' are valid values for the parameter 
%   Display ('iter' is not available).
%
%   X = LSQLIN(PROBLEM) solves the least squares problem defined in 
%   PROBLEM. PROBLEM is a structure with the matrix 'C' in PROBLEM.C, the 
%   vector 'd' in PROBLEM.d, the linear inequality constraints in 
%   PROBLEM.Aineq and PROBLEM.bineq, the linear equality constraints in 
%   PROBLEM.Aeq and PROBLEM.beq, the lower bounds in PROBLEM.lb, the upper 
%   bounds in PROBLEM.ub, the start point in PROBLEM.x0, the options 
%   structure in PROBLEM.options, and solver name 'lsqlin' in 
%   PROBLEM.solver. Use this syntax to solve at the command line a problem 
%   exported from OPTIMTOOL. The structure PROBLEM must have all the 
%   fields.
%
%   [X,RESNORM] = LSQLIN(C,d,A,b) returns the value of the squared 2-norm 
%   of the residual: norm(C*X-d)^2.
%
%   [X,RESNORM,RESIDUAL] = LSQLIN(C,d,A,b) returns the residual: C*X-d.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG] = LSQLIN(C,d,A,b) returns an EXITFLAG 
%   that describes the exit condition of LSQLIN. Possible values of 
%   EXITFLAG and the corresponding exit conditions are
%  
%     1  LSQLIN converged to a solution X.
%     3  Change in the residual smaller that the specified tolerance.
%     0  Maximum number of iterations exceeded.
%    -2  Problem is infeasible.
%    -4  Ill-conditioning prevents further optimization.
%    -7  Magnitude of search direction became too small; no further 
%         progress can be made. The problem is ill-posed or badly 
%         conditioned.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQLIN(C,d,A,b) returns a 
%   structure OUTPUT with the number of iterations taken in 
%   OUTPUT.iterations, the type of algorithm used in OUTPUT.algorithm, the 
%   number of conjugate gradient iterations (if used) in OUTPUT.cgiterations, 
%   a measure of first order optimality (large-scale algorithm only) in 
%   OUTPUT.firstorderopt, and the exit message in OUTPUT.message.
%
%   [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQLIN(C,d,A,b) returns 
%   the set of Lagrangian multipliers LAMBDA, at the solution: 
%   LAMBDA.ineqlin for the linear inequalities C, LAMBDA.eqlin for the 
%   linear equalities Ceq, LAMBDA.lower for LB, and LAMBDA.upper for UB.
%
%   See also QUADPROG.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/06 20:46:05 $

defaultopt = struct( ...
    'Diagnostics','off', ...
    'Display','final', ...
    'JacobMult',[], ...
    'LargeScale','on', ...
    'MaxIter',200, ...
    'MaxPCGIter','max(1,floor(numberOfVariables/2))', ...
    'PrecondBandWidth',0, ...
    'TolFun',100*eps, ...
    'TolPCG',0.1, ...
    'TypicalX','ones(numberOfVariables,1)' ...
);


% If just 'defaults' passed in, return the default options in X
if nargin==1 && nargout <= 1 && isequal(C,'defaults')
   X = defaultopt;
   return
end

% Handle missing arguments
if nargin < 10
    options = [];
    if nargin < 9
        X0 = [];
        if nargin < 8
            ub = [];
            if nargin < 7
                lb = [];
                if nargin < 6
                    beq = [];
                    if nargin < 5
                        Aeq = [];
                        if nargin < 4
                            b = [];
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
    if isa(C,'struct')
        [C,d,A,b,Aeq,beq,lb,ub,X0,options] = separateOptimStruct(C);
    else % Single input and non-structure.
        error('optim:lsqlin:InputArg','The input to LSQLIN should be either a structure with valid fields or consist of at least two arguments.');
    end
end

if nargin == 0 
  error('optim:lsqlin:NotEnoughInputs','LSQLIN requires at least two input arguments.')
end

% Check for non-double inputs
% SUPERIORFLOAT errors when superior input is neither single nor double;
% We use try-catch to override SUPERIORFLOAT's error message when input
% data type is integer.
try
    dataType = superiorfloat(C,d,A,b,Aeq,beq,lb,ub,X0);
catch ME
    if strcmp(ME.identifier,'MATLAB:datatypes:superiorfloat')
        dataType = 'notDouble';
    end
end

if ~strcmp(dataType,'double')
    error('optim:lsqlin:NonDoubleInput', ...
        'LSQLIN only accepts inputs of data type double.')
end

% Set up constant strings
medium =  'medium-scale: active-set';
large = 'large-scale: trust-region reflective Newton'; 
unconstrained = 'slash';
output.iterations = []; % initialize so that it will be the first field

% Options setup
largescale = isequal(optimget(options,'LargeScale',defaultopt,'fast'),'on');
diagnostics = isequal(optimget(options,'Diagnostics',defaultopt,'fast'),'on');
mtxmpy = optimget(options,'JacobMult',defaultopt,'fast');
% Check if name clash
functionNameClashCheck('JacobMult',mtxmpy,'atamult','optim:lsqlin:JacobMultNameClash');

% Use internal Jacobian-multiply function if user does not provide JacobMult function 
if isempty(mtxmpy)
    mtxmpy = @atamult;
end

switch optimget(options,'Display',defaultopt,'fast')
case {'off','none'}
   verbosity = 0;
case {'iter','iter-detailed'}
   verbosity = 2;
case {'final','final-detailed'}
   verbosity = 1;
otherwise
   verbosity = 1;
end

% Set the constraints up: defaults and check size
[nineqcstr,numberOfVariables]=size(A);
neqcstr = size(Aeq,1);
ncstr = nineqcstr + neqcstr;

if isempty(C) || isempty(d)
   error('optim:lsqlin:FirstTwoArgsEmpty', ...
         'The first two arguments to LSQLIN cannot be empty matrices.')
else
   numberOfVariables = max([size(C,2),numberOfVariables]); % In case C is empty
end

[rows,cols]=size(C);
if length(d) ~= rows
   error('optim:lsqlin:InvalidCAndD', ...
         'The number of rows in C must be equal to the length of d.')
end

if length(b) ~= size(A,1)
   error('optim:lsqlin:InvalidAAndB', ...
         'The number of rows in A must be equal to the length of b.')
end

if length(beq) ~= size(Aeq,1)
   error('optim:lsqlin:InvalidAeqAndBeq', ...
         'The number of rows in Aeq must be equal to the length of beq.')
end

if ( ~isempty(A)) && (size(A,2) ~= cols) 
    error('optim:lsqlin:CAndA', ...
          'The number of columns in C must be equal to the number of columns in A.')
end

if ( ~isempty(Aeq)) && (size(Aeq,2) ~= cols)
    error('optim:lsqlin:CAndAeq', ...
          'The number of columns in C must be equal to the number of columns in Aeq.')
end

if isempty(X0)
    % This zero-valued X0 will potentially be changed in sllsbox or qpsub.
    % (This potentially temporary zero-valued x0 needed here for backwards 
    % compatibility because it's returned in output x if early termination 
    % occurs when bounds are inconsistent.)
    X0 = zeros(numberOfVariables,1);
    params.emptyInitialPoint = true;  % parameter passed to sllsbox    
else
    params.emptyInitialPoint = false; % parameter passed to sllsbox 
end
if isempty(A)
    A = zeros(0,numberOfVariables);
end
if isempty(b)
    b = zeros(0,1); 
end
if isempty(Aeq)
    Aeq = zeros(0,numberOfVariables);
end
if isempty(beq)
    beq = zeros(0,1);
end

% Set d, b and X to be column vectors
d = d(:);
b = b(:);
beq = beq(:);
X0 = X0(:);

[X0,lb,ub,msg] = checkbounds(X0,lb,ub,numberOfVariables);
if ~isempty(msg)
   exitflag = -2;
   [resnorm,residual,lambda]=deal([]);
   output.iterations = 0;
   output.algorithm = ''; % not known at this stage
   output.firstorderopt=[];
   output.cgiterations =[];
   output.message = msg;
   X=X0; 
   if verbosity > 0
      disp(msg)
   end
   return
end

% Test if C is all zeros or empty
if norm(C,'inf')==0 || isempty(C)
   C=0; 
end

caller = 'lsqlin';

% Test for constraints
if isempty([Aeq;A]) && isempty([beq;b]) && all(isinf([lb;ub]))
    output.algorithm = unconstrained;
    % If interior-point chosen and no A,Aeq and C isn't short and fat, then call sllsbox   
elseif largescale && (isempty([A;Aeq])) && (rows >= cols)
    output.algorithm = large;
else
    if largescale 
        if (rows < cols)
            warning('optim:lsqlin:MoreColsThanRows', ...
                    ['Large-scale algorithm requires at least as many equations as variables\n' ...
                    '    in C matrix; using medium-scale algorithm instead.'])
        else % ~isempty([A;Aeq]))
            warning('optim:lsqlin:LinConstraints', ...
                    ['Large-scale algorithm can handle bound constraints only;\n' ...
                     '    using medium-scale algorithm instead.'])
        end
    end
    output.algorithm = medium;
end


if diagnostics > 0
   % Do diagnostics on information so far
   gradflag = []; hessflag = []; line_search=[];
   constflag = 0; gradconstflag = 0; non_eq=0;non_ineq=0;
   lin_eq=size(Aeq,1); lin_ineq=size(A,1); XOUT=ones(numberOfVariables,1);
   funfcn{1} = [];ff=[]; GRAD=[];HESS=[];
   confcn{1}=[];c=[];ceq=[];cGRAD=[];ceqGRAD=[];
   msg = diagnose('lsqlin',output,gradflag,hessflag,constflag,gradconstflag,...
      line_search,options,defaultopt,XOUT,non_eq,...
      non_ineq,lin_eq,lin_ineq,lb,ub,funfcn,confcn,ff,GRAD,HESS,c,ceq,cGRAD,ceqGRAD);
end


switch output.algorithm;
case 'slash'
   % Disable the warnings about conditioning for singular and
   % nearly singular matrices
   warningstate1 = warning('off', 'MATLAB:nearlySingularMatrix');
   warningstate2 = warning('off', 'MATLAB:singularMatrix');
   X = C\d;
   % Restore the warning states to their original settings
   warning(warningstate1)
   warning(warningstate2)
   residual = C*X-d;
   resnorm = sum(residual.*residual);
   exitflag = 1;
   lambda.lower = [];
   lambda.upper = [];
   lambda.ineqlin = [];
   lambda.eqlin = [];
   output.iterations = 0;
   output.algorithm = unconstrained;
   output.firstorderopt=[];
   output.cgiterations =[];
   output.message = '';
case 'large-scale: trust-region reflective Newton';
   params.verb = verbosity; % pack parameters together into struct
   [X,resnorm,residual,firstorderopt,iterations,cgiterations,exitflag,lambda,msg]=...
      sllsbox(C,d,lb,ub,X0,params,options,defaultopt,mtxmpy,varargin{:});
   output.iterations = iterations;
   output.algorithm = large;   
   output.firstorderopt = firstorderopt;
   output.cgiterations = cgiterations;
   output.message = msg;
case 'medium-scale: active-set'
   if largescale && ( issparse(A) || issparse(C) || issparse(Aeq) )% asked for sparse
      warning('optim:lsqlin:ConvertToFull', ...
              ['This problem formulation not yet available for sparse matrices.\n' ...
               'Converting to full to solve.'])
   end
   
   % Create options structure for qpsub
   lsqlinoptions.MaxIter = optimget(options,'MaxIter',defaultopt,'fast');
   % A fixed constraint tolerance (eps) is used for constraint
   % satisfaction; no need to specify any value
   lsqlinoptions.TolCon = [];

   [X,lambdaqp,exitflag,output,dum1,dum2,msg]= ...
      qpsub(full(C),d,[full(Aeq);full(A)],[beq;b],lb,ub,X0,neqcstr,verbosity,caller,ncstr,numberOfVariables,lsqlinoptions);
   output.algorithm = medium; % qpsub overwrites output with output.iterations 
   residual = C*X-d;
   resnorm = sum(residual.*residual);
end

if isequal(output.algorithm , medium)
   llb = length(lb); 
   lub = length(ub);
   lambda.lower = zeros(llb,1);
   lambda.upper = zeros(lub,1);
   arglb = ~isinf(lb); lenarglb = nnz(arglb);
   argub = ~isinf(ub); lenargub = nnz(argub);
   lambda.eqlin = lambdaqp(1:neqcstr,1);
   lambda.ineqlin = lambdaqp(neqcstr+1:neqcstr+nineqcstr,1);
   lambda.lower(arglb) = lambdaqp(neqcstr+nineqcstr+1:neqcstr+nineqcstr+lenarglb);
   lambda.upper(argub) = lambdaqp(neqcstr+nineqcstr+lenarglb+1:neqcstr+nineqcstr+lenarglb+lenargub);
   output.firstorderopt=[];
   output.cgiterations =[];
   output.message = msg;

   if exitflag == 1 % qpsub terminated successfully
     normalTerminationMsg = sprintf('Optimization terminated.');  
     if verbosity > 0
       disp(normalTerminationMsg)
     end
     if isempty(msg)
       output.message = normalTerminationMsg;
     else
       % append normal termination msg to current output msg
       output.message = sprintf('%s\n%s',msg,normalTerminationMsg);
     end
   else
     output.message = msg;
   end   
end
