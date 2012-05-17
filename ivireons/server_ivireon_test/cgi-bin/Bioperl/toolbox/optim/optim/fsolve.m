function [x,FVAL,EXITFLAG,OUTPUT,JACOB] = fsolve(FUN,x,options,varargin)
%FSOLVE solves systems of nonlinear equations of several variables.
%
%   FSOLVE attempts to solve equations of the form:
%             
%   F(X) = 0    where F and X may be vectors or matrices.   
%
%   FSOLVE implements three different algorithms: trust region dogleg, 
%   trust region reflective, and Levenberg-Marquardt. Choose one via the 
%   option Algorithm: for instance, to choose trust region reflective, set 
%   OPTIONS = optimset('Algorithm','trust-region-reflective'), and then 
%   pass OPTIONS to FSOLVE. 
%    
%   X = FSOLVE(FUN,X0) starts at the matrix X0 and tries to solve the 
%   equations in FUN.  FUN accepts input X and returns a vector (matrix) of 
%   equation values F evaluated at X. 
%
%   X = FSOLVE(FUN,X0,OPTIONS) solves the equations with the default 
%   optimization parameters replaced by values in the structure OPTIONS, an
%   argument created with the OPTIMSET function.  See OPTIMSET for details.
%   Use the Jacobian option to specify that FUN also returns a second output 
%   argument J that is the Jacobian matrix at the point X. If FUN returns a 
%   vector F of m components when X has length n, then J is an m-by-n matrix 
%   where J(i,j) is the partial derivative of F(i) with respect to x(j). 
%   (Note that the Jacobian J is the transpose of the gradient of F.)
%
%   X = FSOLVE(PROBLEM) solves system defined in PROBLEM. PROBLEM is a
%   structure with the function FUN in PROBLEM.objective, the start point
%   in PROBLEM.x0, the options structure in PROBLEM.options, and solver
%   name 'fsolve' in PROBLEM.solver.  Use this syntax to solve at the 
%   command line a problem exported from OPTIMTOOL. The structure PROBLEM 
%   must have all the fields.
%
%   [X,FVAL] = FSOLVE(FUN,X0,...) returns the value of the equations FUN 
%   at X. 
%
%   [X,FVAL,EXITFLAG] = FSOLVE(FUN,X0,...) returns an EXITFLAG that 
%   describes the exit condition of FSOLVE. Possible values of EXITFLAG and
%   the corresponding exit conditions are listed below. See the
%   documentation for a complete description.
%
%     1  FSOLVE converged to a root.
%     2  Change in X too small.
%     3  Change in residual norm too small.
%     4  Computed search direction too small.
%     0  Too many function evaluations or iterations.
%    -1  Stopped by output/plot function.
%    -2  Converged to a point that is not a root.
%    -3  Trust region radius too small (Trust-region-dogleg) or
%        Regularization parameter too large (Levenberg-Marquardt).
%    -4  Line search failed.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = FSOLVE(FUN,X0,...) returns a structure 
%   OUTPUT with the number of iterations taken in OUTPUT.iterations, the 
%   number of function evaluations in OUTPUT.funcCount, the algorithm used 
%   in OUTPUT.algorithm, the number of CG iterations (if used) in 
%   OUTPUT.cgiterations, the first-order optimality (if used) in 
%   OUTPUT.firstorderopt, and the exit message in OUTPUT.message.
%
%   [X,FVAL,EXITFLAG,OUTPUT,JACOB] = FSOLVE(FUN,X0,...) returns the 
%   Jacobian of FUN at X.  
%
%   Examples
%     FUN can be specified using @:
%        x = fsolve(@myfun,[2 3 4],optimset('Display','iter'))
%
%   where myfun is a MATLAB function such as:
%
%       function F = myfun(x)
%       F = sin(x);
%
%   FUN can also be an anonymous function:
%
%       x = fsolve(@(x) sin(3*x),[1 4],optimset('Display','off'))
%
%   If FUN is parameterized, you can use anonymous functions to capture the 
%   problem-dependent parameters. Suppose you want to solve the system of 
%   nonlinear equations given in the function myfun, which is parameterized 
%   by its second argument c. Here myfun is a MATLAB file function such as
%     
%       function F = myfun(x,c)
%       F = [ 2*x(1) - x(2) - exp(c*x(1))
%             -x(1) + 2*x(2) - exp(c*x(2))];
%           
%   To solve the system of equations for a specific value of c, first 
%   assign the value to c. Then create a one-argument anonymous function 
%   that captures that value of c and calls myfun with two arguments. 
%   Finally, pass this anonymous function to FSOLVE:
%
%       c = -1; % define parameter first
%       x = fsolve(@(x) myfun(x,c),[-5;-5])
%
%   See also OPTIMSET, LSQNONLIN, @, INLINE.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12.2.1 $  $Date: 2010/07/06 14:40:37 $

% ------------Initialization----------------
defaultopt = struct(...
    'Algorithm','trust-region-dogleg',...
    'DerivativeCheck','off',...
    'Diagnostics','off',...
    'DiffMaxChange',1e-1,...
    'DiffMinChange',1e-8,...
    'Display','final',...
    'FunValCheck','off',...
    'Jacobian','off',...
    'JacobMult',[],... 
    'JacobPattern','sparse(ones(Jrows,Jcols))',...
    'LargeScale','off',...
    'LineSearchType','quadcubic',...
    'MaxFunEvals',[],...
    'MaxIter',400,...
    'MaxPCGIter','max(1,floor(numberOfVariables/2))',...
    'NonlEqnAlgorithm','dogleg',...
    'OutputFcn',[],...
    'PlotFcns',[],...
    'PrecondBandWidth',Inf,...
    'ScaleProblem','none',...
    'TolFun',1e-6,...
    'TolPCG',0.1,...
    'TolX',1e-6,...
    'TypicalX','ones(numberOfVariables,1)');

% If just 'defaults' passed in, return the default options in X
if nargin == 1 && nargout <= 1 && isequal(FUN,'defaults')
   x = defaultopt;
   return
end

if nargin < 3, options=[]; end

% Detect problem structure input
if nargin == 1
    if isa(FUN,'struct')
        [FUN,x,options] = separateOptimStruct(FUN);
    else % Single input and non-structure.
        error('optim:fsolve:InputArg',['The input to FSOLVE should be either a ' ...
            'structure with valid fields or consist of at least two arguments.']);
    end
end

if nargin == 0
  error('optim:fsolve:NotEnoughInputs','FSOLVE requires at least two input arguments.')
end

% Check for non-double inputs
if ~isa(x,'double')
  error('optim:fsolve:NonDoubleInput', ...
        'FSOLVE only accepts inputs of data type double.')
end

LB = []; UB = []; 
xstart = x(:);
numberOfVariables = length(xstart);

display = optimget(options,'Display',defaultopt,'fast');
detailedExitMsg = ~isempty(strfind(display,'detailed'));
switch display
    case {'off','none'}
        verbosity = 0;
    case {'iter','iter-detailed'}
        verbosity = 2;
    case {'final','final-detailed'}
        verbosity = 1;
    case 'testing'
        verbosity = Inf;
    otherwise
        verbosity = 1;
end
diagnostics = isequal(optimget(options,'Diagnostics',defaultopt,'fast'),'on');
gradflag =  strcmp(optimget(options,'Jacobian',defaultopt,'fast'),'on');

mediumflag = strcmp(optimget(options,'LargeScale',defaultopt,'fast'),'off');
funValCheck = strcmp(optimget(options,'FunValCheck',defaultopt,'fast'),'on');

algorithm = optimget(options,'Algorithm',defaultopt,'fast');
if ~iscell(algorithm)
    initLMparam = 0.01; % Default value
else
    initLMparam = algorithm{2}; % Initial Levenberg-Marquardt parameter
    algorithm = algorithm{1};   % Algorithm string
end

switch algorithm
    case 'trust-region-dogleg'
        % The option Algorithm may or may not have been changed from the
        % default
        if mediumflag
            switch optimget(options,'NonlEqnAlgorithm',defaultopt,'fast')
                case 'dogleg'
                    algorithmflag = 2;
                case 'lm'
                    warning('optim:fsolve:AlgorithmConflict', ...
                        ['Option NonlEqnAlgorithm will be ignored in a future release. ',...
                        'Running the Levenberg-Marquardt algorithm. To run the Levenberg-Marquardt algorithm ',...
                        'without this warning, set option Algorithm to ''levenberg-marquardt'' instead.'])
                    algorithmflag = 3;
                case 'gn'
                    warning('optim:fsolve:GNremoval', ...
                        ['The Gauss-Newton algorithm may be removed in a future release. Additionally, ', ...
                        'the option NonlEqnAlgorithm will be ignored in a future release. Running the ', ...
                        'Gauss-Newton algorithm. Set option Algorithm to either ''trust-region-dogleg'',', ...
                        ' ''trust-region-reflective'', or ''levenberg-marquardt'' instead.'])
                    algorithmflag = 4;
                    options.LevenbergMarquardt = 'off';
            end
        else
            warning('optim:fsolve:LargeScaleConflict', ...
                ['Option LargeScale will be ignored in a future release. ',...
                'Running the trust-region-reflective algorithm. To run the trust-region-reflective algorithm ',...
                'without this warning, set option Algorithm to ''trust-region-reflective'' instead.'])
            algorithmflag = 1;
        end
    case 'trust-region-reflective'
        algorithmflag = 1;
    case 'levenberg-marquardt'
        algorithmflag = 3;
    case 'lm-line-search'
        % Undocumented Algorithm choice 'lm-line-search'. If it is set, run
        % the Levenberg-Marquardt with line-search code inside nlsq.m
        algorithmflag = 4;
        options.LevenbergMarquardt = 'on'; % Needed because it is used in nlsq.m
    otherwise % Invalid choice of Algorithm
        error('optim:fsolve:InvalidAlgorithm', ...
            ['Invalid choice of option Algorithm for FSOLVE. Choose either ''trust-region-dogleg'', ', ...
            '''trust-region-reflective'', or ''levenberg-marquardt''.'])
end

% Process user function
if ~isempty(FUN)  % will detect empty string, empty matrix, empty cell array
    funfcn = lsqfcnchk(FUN,'fsolve',length(varargin),funValCheck,gradflag);
else
    error('optim:fsolve:InvalidFUN', ...
        ['FUN must be a function name, valid string expression, or inline object;' ...
        ' or, FUN may be a cell array that contains these type of objects.'])
end

mtxmpy = optimget(options,'JacobMult',defaultopt,'fast');
% Check if name clash
functionNameClashCheck('JacobMult',mtxmpy,'atamult','optim:fsolve:JacobMultNameClash');

% Use internal Jacobian-multiply function if user does not provide JacobMult function 
% or options.Jacobian is off
if isempty(mtxmpy) || (~strcmpi(funfcn{1},'fungrad') && ~strcmpi(funfcn{1},'fun_then_grad'))
    mtxmpy = @atamult;
end

JAC = [];
x(:) = xstart;
switch funfcn{1}
    case 'fun'
        try
            fuser = feval(funfcn{3},x,varargin{:});
        catch userFunExcept
            optimExcept = MException('optim:fsolve:ObjectiveError', ...
               'Failure in initial user-supplied objective function evaluation. FSOLVE cannot continue.');
            userFunExcept = addCause(userFunExcept,optimExcept);
            rethrow(userFunExcept)
        end
        f = fuser(:);
        nfun = length(f);
    case 'fungrad'
        try
            [fuser,JAC] = feval(funfcn{3},x,varargin{:});
        catch userFunExcept
            optimExcept = MException('optim:fsolve:ObjectiveError', ...
                'Failure in initial user-supplied objective function evaluation. FSOLVE cannot continue.');
            userFunExcept = addCause(userFunExcept,optimExcept);
            rethrow(userFunExcept)
        end
        f = fuser(:);
        nfun = length(f);
    case 'fun_then_grad'
        try
            fuser = feval(funfcn{3},x,varargin{:});
        catch userFunExcept
            optimExcept = MException('optim:fsolve:ObjectiveError', ...
                'Failure in initial user-supplied objective function evaluation. FSOLVE cannot continue.');
            userFunExcept = addCause(userFunExcept,optimExcept);
            rethrow(userFunExcept)
        end
        f = fuser(:);
        try
            JAC = feval(funfcn{4},x,varargin{:});
        catch userFunExcept
            optimExcept = MException('optim:fsolve:JacobianError', ...
                'Failure in initial user-supplied Jacobian function evaluation. FSOLVE cannot continue.');
            userFunExcept = addCause(userFunExcept,optimExcept);
            rethrow(userFunExcept)
        end
        nfun = length(f);
    otherwise
        error('optim:fsolve:UndefinedCalltype','Undefined calltype in FSOLVE.')
end

if gradflag
    % check size of JAC
    [Jrows, Jcols] = size(JAC);
    if isempty(options.JacobMult)
        % Not using 'JacobMult' so Jacobian must be correct size
        if Jrows ~= nfun || Jcols ~= numberOfVariables
            error('optim:fsolve:InvalidJacobian', ...
                ['User-defined Jacobian is not the correct size:' ...
                ' the Jacobian matrix should be %d-by-%d.'],nfun,numberOfVariables)
        end
    end
else
    Jrows = nfun;
    Jcols = numberOfVariables;
end

caller = 'fsolve';

% Choose what algorithm to run: determine algorithmflag and check criteria
if algorithmflag == 1 && nfun < numberOfVariables
    % trust-region-reflective algorithm and not enough equations - switch
    % to levenberg-marquardt algorithm
    warning('optim:fsolve:FewerFunsThanVars', ...
        ['Trust-region-reflective algorithm requires at least as many equations ' ...
        'as variables; using Levenberg-Marquardt algorithm instead.'])
    algorithmflag = 3;
elseif algorithmflag == 2 && nfun ~= numberOfVariables
    warning('optim:fsolve:NonSquareSystem', ...
        ['Trust-region-dogleg algorithm of FSOLVE cannot handle ', ...
        'non-square systems; using Levenberg-Marquardt algorithm instead.']);
    algorithmflag = 3;
end

if diagnostics > 0
    % Do diagnostics on information so far
    constflag = 0; gradconstflag = 0; non_eq = 0;non_ineq = 0;lin_eq = 0;lin_ineq = 0;
    confcn{1} = [];c = [];ceq = [];cGRAD = [];ceqGRAD = [];
    hessflag = 0; HESS = [];
    % Set OUTPUT.algorithm for diagnostics
     switch algorithmflag
         case 1
             OUTPUT.algorithm = 'trust-region-reflective';
         case 2
             OUTPUT.algorithm = 'trust-region-dogleg';
         case 3
             OUTPUT.algorithm = 'Levenberg-Marquardt';
         case 4
             OUTPUT.algorithm = 'medium-scale: line-search';
    end
    diagnose('fsolve',OUTPUT,gradflag,hessflag,constflag,gradconstflag,...
        mediumflag,options,defaultopt,xstart,non_eq,...
        non_ineq,lin_eq,lin_ineq,LB,UB,funfcn,confcn,f,JAC,HESS,c,ceq,cGRAD,ceqGRAD);
end

% Prepare strings to give feedback to users on options they have or have not set.
% These are used in the exit messages.
optionFeedback = createOptionFeedback(options);

% Execute algorithm
if algorithmflag == 1   % trust-region reflective
    if ~gradflag
        Jstr = optimget(options,'JacobPattern',defaultopt,'fast');
        if ischar(Jstr)
            % options.JacobPattern is the default: 'sparse(ones(jrows,jcols))'
            Jstr = sparse(ones(Jrows,Jcols));
        end
        checkoptionsize('JacobPattern', size(Jstr), Jcols, Jrows);
    else
        Jstr = [];
    end
    computeLambda = 0;
    % Set MaxFunEvals appropriately for trust-region-reflective
    defaultopt.MaxFunEvals = '100*numberOfVariables';
    
    [x,FVAL,LAMBDA,JACOB,EXITFLAG,OUTPUT,msgData]=...
        snls(funfcn,x,LB,UB,verbosity,options,defaultopt,f,JAC,caller,...
        Jstr,computeLambda,mtxmpy,detailedExitMsg,optionFeedback,varargin{:});
elseif algorithmflag == 2   % trust-region dogleg
    % Set MaxFunEvals appropriately for trust-region-dogleg
    defaultopt.MaxFunEvals = '100*numberOfVariables';
    
    [x,FVAL,JACOB,EXITFLAG,OUTPUT,msgData]=...
        trustnleqn(funfcn,x,verbosity,gradflag,options,defaultopt,f,JAC,...
        detailedExitMsg,optionFeedback,varargin{:});
elseif algorithmflag == 3   % Levenberg-Marquardt
    % Set MaxFunEvals appropriately for LM
    defaultopt.MaxFunEvals = '200*numberOfVariables';
    
    [x,FVAL,JACOB,EXITFLAG,OUTPUT,msgData] = ...
        levenbergMarquardt(funfcn,x,verbosity,options,defaultopt,f,JAC, ...
        caller,initLMparam,detailedExitMsg,optionFeedback,varargin{:});
else % algorithmflag = 4, Gauss-Newton or Levenberg-Marquardt line-search
    % Set MaxFunEvals appropriately for Gauss-Newton
    defaultopt.MaxFunEvals = '100*numberOfVariables';
    
    [x,FVAL,JACOB,EXITFLAG,OUTPUT,msgData] = ...
        nlsq(funfcn,x,verbosity,options,defaultopt,f,JAC,caller,varargin{:});
end

Resnorm = FVAL'*FVAL;  % assumes FVAL still a vector
sqrtTolFun = sqrt(optimget(options,'TolFun',defaultopt,'fast'));
if EXITFLAG > 0 % if we think we converged:
     % Call createExitMsg with appended additional information on the closeness 
     % to a root.
     if Resnorm > sqrtTolFun
         if algorithmflag < 4 % nlsq wasn't called
             % Change internal exitflag to unique identifier -21,-22, or -23 by
             % negating the exitflag and adding to -20.
             msgData{2} = -20 - EXITFLAG;
             OUTPUT.message = createExitMsg(msgData{:},Resnorm,optionFeedback.TolFun,sqrtTolFun);
         else % nlsq was called
             OUTPUT.message = sprintf(['Optimizer appears to be converging to a minimum that is not a root:\n', ...
                 'Sum of squares of the function values exceeds the square root of \n', ...
                 'options.TolFun. Try again with a new starting point.']);
             if verbosity > 0
                 disp(OUTPUT.message);
             end
         end
         EXITFLAG = -2;
     else
        if algorithmflag < 4 % nlsq wasn't called
            OUTPUT.message = createExitMsg(msgData{:},Resnorm,optionFeedback.TolFun,sqrtTolFun);
        else % nlsq was called
            OUTPUT.message = msgData;
            if verbosity > 0
                disp(OUTPUT.message);
            end
        end
    end
else
    if algorithmflag < 4 % nlsq wasn't called
        OUTPUT.message = createExitMsg(msgData{:});
    else % nlsq was called
        OUTPUT.message = msgData;
        if verbosity > 0
            disp(OUTPUT.message);
        end
    end
end

% Reset FVAL to shape of the user-function output, fuser
FVAL = reshape(FVAL,size(fuser));

