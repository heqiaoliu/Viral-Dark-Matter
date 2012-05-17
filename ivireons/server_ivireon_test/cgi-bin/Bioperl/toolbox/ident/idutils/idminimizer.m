function [xfinal, resnorm, J, exitflag, output] = idminimizer(costfun, x, lb, ub, option, varargin)
%IDMINIMIZER  Ident's built-in miminizer of det-criterion. 
%
%   Four search directions - 'gna', 'gn', 'grad' and 'lm' are supported.
%   By default (searchdir = 'auto'), line search begins with 'gn' and 'lm',
%   'gna', and 'grad' are tried successively until a success with line
%   search is achieved.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.10.12 $ $Date: 2009/10/16 04:56:40 $
% Written by Rajiv Singh.

% Initialize output and iteration information structures.
output  = struct('iterations', 0, 'funcCount', 0,                      ...
    'algorithm', 'Subspace Gauss-Newton', 'stepsize', [], ...
    'firstorderopt', [], 'UpdateNorm', [],                ...
    'LastImprovement', []);
IterInfo = struct('CurrentCost', [], 'PreviousCost', [],           ...
    'FirstOrd', [], 'Iteration', [], 'StepSize', [], ...
    'SearchDir', 'Gauss-Newton', 'CurrentValues', x, ...
    'PreviousValues', [], 'ActualImprovement', [],   ...
    'ExpectedImprovement', []);

% Initialize algorithm properties.
tol = option.Tolerance;
searchdir = lower(option.SearchMethod);
maxfcount = option.Advanced.MaxFunEvals;
maxiter = option.MaxIter;
gamma = option.Advanced.InitGnaTol;
gnp = option.Advanced.GnPinvConst;
maxbis = option.Advanced.MaxBisections;
minMu = option.Advanced.MinParChange;
stepred = option.Advanced.StepReduction;
relimp = option.Advanced.RelImprovement;
lmstartval = option.Advanced.LMStartValue;
lmstep = option.Advanced.LMStep;
ComputeProj = option.ComputeProjFlag;
isLinmod = option.isLinmod;
isPoly = option.isPoly;
isReal = option.isReal;
isTraceCrit = strcmpi(option.Criterion,'trace');

% Initialize search directions.
switch searchdir
    case 'auto'
        searchdir = {'gn' 'lm' 'gna' 'grad'};
        dirnstr = 'Gauss-Newton';
    case 'gn'
        searchdir = {searchdir 'grad'};
        dirnstr = 'Gauss-Newton';
    case 'gna'
        searchdir = {searchdir 'grad'};
        dirnstr = 'Adaptive Gauss-Newton';
    case 'grad'
        dirnstr = 'Gradient';
        searchdir = {searchdir};
    case 'lm'
        dirnstr = 'Levenberg-Marquardt';
        searchdir = {searchdir};
end

% Perform further initializations.
x = x(:);
lb = lb(:);
ub = ub(:);
if ~isReal
    % Complex data. The default lower bound (-Inf) must be modified so that
    % min/max comparison provides expectes results (treats lb to be
    % smaller than any complex parameter value)
    lb(isinf(lb)) = 0; % lb=Inf is not allowed
end
    
haveOutputFcn = isa(option.OutputFcn, 'function_handle');
exitflag = NaN; % NaN should not be the eventual value of exitflag.
fcount = 0; % Initialize function evaluation counter.
n = option.DataSize;

F = 1;
if isLinmod
    % N is structure dependent for linear models 
    N = option.struc.Nobs;
else
    % Sum total of data samples for nonlinear models
    % not reliable to determine from e because of QR factorization.
    N = sum(n);
end

np = length(x);

% Get initial cost, robustified prediction error and Jacobian.
[resnorm, lambda, e, J] = feval(costfun, x);
fcount = fcount+1;

% Compute normalization factor
if isPoly || isTraceCrit
    % Notes: 
    % 1. Only in IDPOLY models, weighting (in either det or trace
    % criterion) is completely ignored. Hence division by resnorm (V)
    % becomes necessary. For other structures, normalization by resnorm is
    % implicit in calculation of e and J for det-criterion only.
    %
    % 2. In case of trace criterion, resnorm (V) is multiplied by
    % Weighting W. Hence no separate division by W is required.  
    F = resnorm;
end

% Compute gradient.
grad = J'*e;

% Check initial model.
if ((isReal && ~isreal(lambda)) || ~all(all(isfinite(lambda))))
    ctrlMsgUtils.error('Ident:estimation:InvalidInitialModel')
end

% Compute initial test norm (stop criterion).
testnorm = localGetTestNorm(e,J,N,F); 

% Show initial output (before minimization begins).
if haveOutputFcn
    IterInfo = localDeal(IterInfo, resnorm, [], norm(grad, 'inf'), 0, [],...
        [], x, [], [], testnorm, []);
    isStop = feval(option.OutputFcn, IterInfo, 'init');
    if isStop
        xfinal = x;
        exitflag = -1;
        return;
    end
end

% Initialize minimization loop.
iter = 0;
testnorm = tol+1; % Force at least one iteration.
stepsize = [];
lstop = 0; % Line search default flag (0 means do not stop iteration).
resnormold = resnorm;
xold = x;
impr = 1+relimp;
gdir = [];

% Set start value of delta for LM. lmDelta is updated based on success of
% linear search during each iteration
lmDelta = lmstartval*norm(J); 

% Minimization loop.
while ((testnorm > tol) && (iter < maxiter) && (norm(lambda) > -eps) &&...
        (fcount < maxfcount) && (impr >= relimp))
    % Initialize iteration information.
    iter = iter+1;
    xold = x;  % Cache (old) parameter vector.
    Jold = J;  % Cache (old) Jacobian.
    resnormold = resnorm; % Cache (old) resnorm.
    
    % calculate error norm
    if isPoly || isTraceCrit
        F = resnorm;
    end
    testnorm = localGetTestNorm(e,J,N,F);

    % Adjust lmDelta if it gets too large (too many bisections during
    % previous iteration)
    lmDelta = min(lmDelta, lmstartval*norm(J)); 
    
    % Find search direction and perform line search.
    [x, impr, muIter, stepsize, gdir, lstop] = localLineSearch(xold, resnormold, e, J);

    if (lstop ~= 0)
        break;
    end

    % Update prediction error, Jacobian and gradient.
    [resnorm, lambda, e, J] = feval(costfun,x);
    fcount = fcount+1;
    grad = J'*e;

    % Show iteration output.
    if haveOutputFcn
        IterInfo = localDeal(IterInfo, resnorm, resnormold, norm(grad, 'inf'),...
            iter, stepsize, muIter, x, xold, impr, testnorm, gdir);
        isStop = feval(option.OutputFcn,IterInfo, 'iter');
        if isStop
            exitflag = -1;
            break;
        end
    end
    
    % Adjust testnorm so that the maximum of expected and actual
    % improvement is minimized (in general actual improvement is less than
    % expected one)
    testnorm = max(testnorm, impr);
end

% Determine why the minimization loop was terminated.
if ((testnorm <= tol) || (norm(lambda) <= eps))
    % Near (local) minimum, (norm(g) < tol).
    exitflag = 1;
elseif (iter >= maxiter)
    % Maximum number of iterations reached.
    exitflag = 0;
elseif (fcount >= maxfcount)
    % Number of function evaluations exceeded MaxFunEvals.
    exitflag = -3;
elseif (lstop ~= 0)
    J = Jold;
    if (lstop == 2)
        % No improvement along the search direction with line search.
        exitflag = -4;
    elseif (lstop == 3)
        % Magnitude of search direction was smaller than the specified
        % tolerance.
        exitflag = 4;
    end
elseif (impr < relimp)
    % Change in cost (actual improvement %) was less than the specified tolerance.
    % Note: this condition will never be hit because line search will
    %      terminate with lstop = 2 or 3.
    exitflag = 3;
end

% Compute estimated values.
xfinal = x;

% Show termination output.
if haveOutputFcn
    IterInfo = localDeal(IterInfo, resnorm, resnormold, norm(grad, 'inf'), ...
        iter, stepsize, [], x, xold, impr, testnorm, gdir);
    feval(option.OutputFcn,IterInfo, 'done');
end

% Determine output value.
output  = struct('iterations', iter, 'funcCount', fcount,    ...
    'algorithm', dirnstr, 'stepsize', stepsize, ...
    'firstorderopt', norm(grad, 'inf'),         ...
    'UpdateNorm', testnorm, 'LastImprovement', impr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nested function.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function  [x_, impr_, Iter_, stepsize_, gdir_, lstop_] = localLineSearch(x0, resnorm0, e0, J0)
        % Perform line search.
        % The function updates gamma in the parent workspace.

        % Initializations.
        stepsize_ = 0;
        if ComputeProj
            x0 = zeros(size(x0));
        end

        x_ = x0;
        
        %lmDelta_ = lmDelta; % Start LM from a default value point.
        impr_ = 0;
        lstop_ = 0;

        % Loop over search directions.
        for kdir = 1:length(searchdir)
            thisdir = searchdir{kdir};
            lstop_ = 0;
            switch thisdir
                case 'lm'
                    % Levenberg-Marquardt search.
                    % Start LM iteration with GN direction.
                    gdir_ = -pinv(J0)*e0;
                    %lmDelta_ = lmDelta;
                    lmDelta = lmDelta/lmstep/2;
                case 'gn'
                    % Gauss-Newton search.
                    gpinvtol = gnp*eps*max(size(J0))*norm(J0);
                    gdir_ = -pinv(J0,gpinvtol)*e0;
                case 'gna'
                    % Ninness-Wills adaptive Gauss-Newton search.
                    [u, s, v] = svd(J0, 0);
                    if size(s,1)==1
                        s = s(1);
                    else
                        s = diag(s);
                    end
                    rbn = sum(s >= gamma*max(s));
                    if rbn==0 || norm(s)==0
                        gdir_ = zeros(size(J0,2),1);
                    else
                        gdir_ = -(v(:, 1:rbn)*((u(:, 1:rbn)'*e0)./s(1:rbn)));
                    end
                case 'grad'
                    % Gradient search.
                    if (norm(J0) > 0)
                        gdir_ = -J0'*e0*np/norm(J0);
                    else
                        gdir_ = -J0'*e0;
                    end
            end

            % Determine parameter update to start with.
            deltax_ = gdir_;
            x_ = x0 + deltax_;

            % Parameter bounds.
            x_ = min(max(x_, lb), ub);

            % Get new cost.
            resnorm_ = feval(costfun, x_);
            fcount = fcount+1;
            if ~isfinite(resnorm_)
                resnorm_ = resnorm0;
            end

            % Perform line search.
            Iter_ = 0; % Initialize line search #bisections counter.
            while ((resnorm_-resnorm0) >= -resnorm0*relimp)
                Iter_ = Iter_+1;
                switch thisdir
                    case 'lm'
                        lmDelta = lmDelta*lmstep;
                        J1 = [J0; lmDelta*eye(np)];
                        %gpinvtol = gnp*eps*max(size(J1))*norm(J1);
                        deltax_ = -pinv(J1)*[e0; zeros(np, 1)];
                    case {'gn' 'grad' 'gna'}
                        deltax_ = deltax_/stepred;
                end

                % New parameter update.
                x_ = x0 + deltax_;

                % Parameter bounds.
                x_ = min(max(x_, lb), ub);

                % Get new cost.
                resnorm_ = feval(costfun, x_);
                fcount = fcount+1;
                if ~isfinite(resnorm_)
                    resnorm_ = resnorm0;
                end

                % Check if line-search should be terminated.
                if (Iter_ == maxbis)
                    % Maximum number of bisections reached.
                    lstop_ = 2;
                    break;
                elseif (norm(deltax_) < minMu)
                    % Too small update size of parameters.
                    lstop_ = 3;
                    break;
                end
            end

            % GNA updates.
            if strcmp(thisdir, 'gna')
                % Update gamma (useful for searchdir = gna only).
                if (Iter_== 0)
                    % Default step itself produced enough reduction (no
                    % bisections at all). So reduce gamma s.t. more
                    % singular value are used in subsequent line searches.
                    gamma = max(gamma/(2*lmstep), sqrt(eps));
                elseif (Iter_ > 5)
                    % Increase gamma to improve performance of subsequent
                    % line searches, since this one seems to be having
                    % difficulties (took more than 5 bisections).
                    gamma = min(lmstep*gamma, 1);
                end
            end

            % If the line search in the while-loop above ended because the
            % maximum number of bisections was performed (line search
            % failure), then restore the original parameters.
            if (lstop_ ~= 0)
                % Line search failed.
                x_ = x0;
                impr_ = 0;
            else
                % Line search successful.
                if (resnorm0~=0)
                    impr_ = (resnorm0-resnorm_)*100/resnorm0;
                elseif (resnorm_==0)
                    impr_ = 0;
                else
                    impr_ = -Inf;
                end
                % Step-size is non-zero if and only if line search was
                % successful.
                stepsize_ = norm(deltax_); 
                lstop_ = 0;
                
                if ComputeProj
                    % Update projection matrix and model parameters.
                    option.ProjectionFun(x_);
                end
                
                return;
            end %if
            
        end % searchdir loop
        
    end %inner function: localLineSearch
end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions                                                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function IterInfo = localDeal(IterInfo, resnorm, resnormold, gradnrm, iter,...
    stp, muIter, x, xold, actimpr, expimpr, gdir)

IterInfo.CurrentCost = resnorm;
IterInfo.PreviousCost = resnormold;
IterInfo.FirstOrd = gradnrm; % Same as in lsqnonlin (snls).
IterInfo.Iteration = iter;
IterInfo.StepSize = stp;
IterInfo.CurrentValues = x;
IterInfo.PreviousValues = xold;
IterInfo.ActualImprovement = actimpr;
IterInfo.ExpectedImprovement = expimpr;
IterInfo.NumBisections = muIter;
IterInfo.Direction = gdir;

end

%--------------------------------------------------------------------------
function val = localGetTestNorm(e,J,N,F)
% Calculate expected improvement (percentage).
%   (test norm: abs((e'*J)*pinv(J'*J)*(J'*e)*100/N) )

[U,S] = svd(J,0); %#ok<NASGU>
if F~=0
    val = (U'*e)'*(U'*e)*100/N/F;
else
    val = 0;
end

end
