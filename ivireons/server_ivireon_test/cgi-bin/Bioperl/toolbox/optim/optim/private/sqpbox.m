function [x,val,csnrm,it,npcg,exitflag,LAMBDA,msg] = sqpbox(c,H,mtxmpy,l,u,xstart,options,defaultopt,...
    numberOfVariables,verb,computeLambda,varargin)
%SQPBOX Minimize box-constrained quadratic function
%
%   Locate a (local) solution to the box-constrained QP:
%
%        min { q(x) = .5x'Hx + c'x :  l <= x <= u}.
%
%   where H is sparse symmetric, c is a col vector,
%   l,u are vectors of lower and upper bounds respectively.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/05/10 17:32:13 $

% Retrieving options

% Add Preconditioner, OutputFcn and PlotFcn to defaultopt. These are not
% documented options for quadprog, and are not added to defaultopt at the
% user-facing function level.
defaultopt.Preconditioner = @hprecon;
defaultopt.OutputFcn = [];
defaultopt.PlotFcns = [];

pcmtx = optimget(options,'Preconditioner',defaultopt,'fast');
kmax = optimget(options,'MaxPCGIter',defaultopt,'fast');
typx = optimget(options,'TypicalX',defaultopt,'fast');
if ischar(kmax)
    if isequal(lower(kmax),'max(1,floor(numberofvariables/2))')
        kmax = max(1,floor(numberOfVariables/2));
    elseif isequal(lower(kmax),'numberofvariables')
        kmax = numberOfVariables;
    else
        error('optim:sqpbox:InvalidMaxPCGIter', ...
            'Option ''MaxPCGIter'' must be an integer value if not the default.')
    end
end
if ischar(typx)
    if isequal(lower(typx),'ones(numberofvariables,1)')
        typx = ones(numberOfVariables,1);
    else
        error('optim:sqpbox:InvalidTypicalX', ...
            'Option ''TypicalX'' must be a matrix (not a string) if not the default.')
    end
end
checkoptionsize('TypicalX', size(typx), numberOfVariables);
pcflags = optimget(options,'PrecondBandWidth',defaultopt,'fast') ;
tolx = optimget(options,'TolX',defaultopt,'fast') ;
tolfun = optimget(options,'TolFun',defaultopt,'fast');
pcgtol = optimget(options,'TolPCG',defaultopt,'fast') ;  % pcgtol = .1;
itb = optimget(options,'MaxIter',defaultopt,'fast') ;

% Handle the output functions
xOutputfcn = [];
outputfcn = optimget(options,'OutputFcn',defaultopt,'fast');
if isempty(outputfcn)
    haveoutputfcn = false;
else
    haveoutputfcn = true;
    xOutputfcn = xstart; % Last x passed to outputfcn; has the input x's shape
    % Parse OutputFcn which is needed to support cell array syntax for OutputFcn.
    outputfcn = createCellArrayOfFunctions(outputfcn,'OutputFcn');
end

% Handle the plot functions
plotfcns = optimget(options,'PlotFcns',defaultopt,'fast');
if isempty(plotfcns)
    haveplotfcn = false;
else
    haveplotfcn = true;
    xOutputfcn = xstart; % Last x passed to outputfcn; has the input x's shape
    % Parse PlotFcn which is needed to support cell array syntax for PlotFcn.
    plotfcns = createCellArrayOfFunctions(plotfcns,'PlotFcns');
end

%   INITIALIZATIONS
if nargin <= 1
    error('optim:sqpbox:NotEnoughInputs','sqpbox requires at least 2 arguments.')
end
n = length(c);
it = 0;
cvec = c;
nbnds = true;
header = sprintf(['\n                                Norm of      First-order \n',...
    ' Iteration        f(x)          step          optimality   CG-iterations']);
formatstr = ' %5.0f      %13.6g  %13.6g   %12.3g     %7.0f';

if n == 0
    error('optim:sqpbox:InvalidN','n must be positive.')
end
if nargin <= 2
    l = -inf*ones(n,1);
end
if nargin <= 3,
    u = inf*ones(n,1);
end
if isempty(l),
    l = -inf*ones(n,1);
end
if isempty(u),
    u = inf*ones(n,1);
end
arg = (u >= 1e10);
arg2 = (l <= -1e10);
u(arg) = inf;
l(arg2) = -inf;
if min(u-l) <= 0
    error('optim:sqpbox:InconsistentBnds','Inconsistent bounds.')
end
lvec = l; uvec = u;

pcgit = 0;
tolx2 = sqrt(tolx);
tolfun2 = sqrt(tolfun);
[xstart,l,u,ds,DS,c] = shiftsc(xstart,l,u,typx,'sqpbox',mtxmpy,cvec,H,varargin{:});
dellow = 1.;
delup = 10^3;
npcg = 0;
digits = inf;
done = false;
v = zeros(n,1);
dv = ones(n,1);
del = 10*eps;
posdef = 1;
x = xstart;
y = x;
sigma = ones(n,1);
g = zeros(n,1);
oval = inf;
prev_diff = 0;
[val,g] = fquad(x,c,H,'sqpbox',mtxmpy,DS,varargin{:});
[v,dv] = definev(g,x,l,u);
csnrm = norm(v.*g,inf);
if csnrm == 0
    % If initial point is a 1st order point then randomly perturb the
    % initial point a little while keeping it feasible and reinitialize.
    dir = zeros(n,1);
    pos = u-x > x-l;
    neg = u-x <= x-l;
    dir(pos) = 1; dir(neg) = -1;
    % Get random noise, but "put it back" so we don't affect anyone
    dflt = RandStream.getDefaultStream;
    randstate = dflt.State;
    x = x + dir.*rand(n,1).*max(u-x,x-l).*1e-1;
    dflt.State = randstate;
    y = x;
    [val,g] = fquad(x,c,H,'sqpbox',mtxmpy,DS,varargin{:});
end

if ((u == inf*ones(n,1)) & (l == -inf*ones(n,1)))
    nbnds = false;
end

% Initialize the output function.
if haveoutputfcn || haveplotfcn
    [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,...
        'init',it,val,g,[],pcgit,[],[],[],itb,tolfun,[],nbnds,[],l,u,varargin{:});
    if stop
        [x,val,csnrm,it,npcg,exitflag,LAMBDA,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
        if verb > 0
            disp(msg)
        end
        return;
    end
end
%
%   MAIN LOOP: GENERATE FEAS. SEQ.  x(it) S.T. q(x(it)) IS DECREASING.
while ~done
    it = it + 1;
    %     Update and display
    [v,dv] = definev(g,x,l,u);
    csnrm = norm(v.*g,inf);
    r = abs(min(u-x,x-l));
    degen = min(r + abs(g));
    if ((u == inf*ones(n,1)) & (l == -inf*ones(n,1)))
        degen = -1;
    end
    bndfeas = min(min(x-l,u-x));
    
    delta = max(dellow,norm(v));
    delta = min(delta,delup);

    % OutputFcn call
    if haveoutputfcn || haveplotfcn      
        [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,...
            'iter',it,val,g,csnrm,pcgit,posdef,degen,delta,itb,tolfun,bndfeas,nbnds,npcg,l,u,varargin{:});
        if stop
            [x,val,csnrm,it,npcg,exitflag,LAMBDA,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
            if verb > 0
                disp(msg)
            end
            return;
        end
    end

    %
    %     TEST FOR CONVERGENCE
    diff = abs(oval-val);
    if it > 1,
        digits = (prev_diff)/max(diff,eps);
    end
    prev_diff = diff;
    oval = val;
    if diff < tolfun*(1+abs(oval)),
        exitflag = 3; done = true;
        msg = sprintf(['Optimization terminated: relative function value changing by\n' ...
            ' less than OPTIONS.TolFun.']);
        if verb > 0
            disp(msg)
        end
    elseif ((diff < tolfun2*(1+abs(oval))) & (digits < 3.5)) & posdef,
        exitflag = 3; done = true;
        msg = sprintf(['Optimization terminated: relative function value changing by less\n' ...
            ' than sqrt(OPTIONS.TolFun), no negative curvature detected in current\n' ...
            ' trust region model and the rate of progress (change in f(x)) is slow.']);
        if verb > 0
            disp(msg)
        end
    elseif ((csnrm < tolfun) & posdef & it > 1),
        exitflag = 1; done = true;
        msg = sprintf(['Optimization terminated: no negative curvature detected in current\n' ...
            ' trust region model and first order optimality measure < OPTIONS.TolFun.']);
        if verb > 0
            disp(msg)
        end
    end
    %
    if ~done
        if haveoutputfcn % Call output functions (we don't call plot functions with 'interrupt' flag)
            [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,...
                'interrupt',it,val,g,csnrm,pcgit,posdef,degen,delta,itb,tolfun,bndfeas,nbnds,npcg,...
                l,u,varargin{:});
            if stop
                [x,val,csnrm,it,npcg,exitflag,LAMBDA,msg] = cleanUpInterrupt(xOutputfcn,optimValues);
                if verb > 0
                    disp(msg)
                end
                return;
            end
        end                   
        %       DETERMINE THE SEARCH DIRECTION
        dd = abs(v);
        D = sparse(1:n,1:n,full(sqrt(dd).*sigma));
        grad = D*g;
        normg = norm(grad);     

        [s,posdef,pcgit] = drqpbox(D,DS,grad,delta,g,dv,mtxmpy,...
            pcmtx,pcflags,pcgtol,H,0,kmax,varargin{:});

        npcg = npcg + pcgit;
        %
        %       DO A REFLECTIVE (BISECTION) LINE SEARCH. UPDATE x,y,sigma.
        strg= s'*(sigma.*g);
        ox = x;
        osig = sigma;
        ostrg = strg;
        if strg >= 0,
            exitflag = -2; done = true;
            msg = sprintf(['Optimization terminated: loss of feasibility with respect to the\n' ...
                ' constraints detected.']);
            if verb > 0
                disp(msg);
            end
        else
            [x,sigma,alpha] = biqpbox(s,c,ostrg,ox,y,osig,l,u,oval,posdef,...
                normg,DS,mtxmpy,H,0,varargin{:});
            if alpha == 0,
                exitflag = -4; done = true;
                msg = sprintf(['Optimization terminated: current direction not descent direction;\n' ...
                    ' the problem may be ill-conditioned.']);
                if verb > 0
                    disp(msg)
                end

            end
            y = y + alpha*s;
            %
            %          PERTURB x AND y ?
            [pert,x,y] = perturb(x,l,u,del,y,sigma);
            %
            %          EVALUATE NEW FUNCTION VALUE, GRADIENT.
            [val,g] = fquad(x,c,H,'sqpbox',mtxmpy,DS,varargin{:});
        end
        if it >= itb,
            exitflag = 0; done = true;
            msg = sprintf('Maximum number of iterations exceeded; increase options.MaxIter');
            if verb > 0
                disp(msg)
            end
        end
    end
end

if haveoutputfcn || haveplotfcn
    [xOutputfcn, optimValues] = callOutputAndPlotFcns(outputfcn,plotfcns,x,xOutputfcn,...
        'done',it,val,g,csnrm,pcgit,posdef,degen,delta,itb,tolfun,bndfeas,nbnds,npcg,...
        l,u,varargin{:});
    % Do not check value of 'stop' as we are done with the optimization
    % already.
end

%
%   RESCALE, UNSHIFT, AND EXIT.
x = unshsca(x,lvec,uvec,DS);
% unscaled so leave out DS
[val,g] = fquad(x,cvec,H,'sqpbox',mtxmpy,[],varargin{:});

if computeLambda
    LAMBDA.lower = zeros(length(lvec),1);
    LAMBDA.upper = zeros(length(uvec),1);
    active_tol = sqrt(eps);
    argl = logical(abs(x-lvec) < active_tol);
    argu = logical(abs(x-uvec) < active_tol);

    g = full(g);
    LAMBDA.lower(argl) = abs(g(argl));
    LAMBDA.upper(argu) = -abs(g(argu));
else
    LAMBDA=[];
end

%--------------------------------------------------------------------------
function [xOutputfcn, optimValues, stop] = callOutputAndPlotFcns(outputfcn,plotfcns,...
    xvec,xOutputfcn,state,iter,val,g,csnrm,pcgit,posdef,degen,delta,maxiter,tolfun,...
    bndfeas,nbnds,npcg,lbounds,ubounds,varargin)
% CALLOUTPUTANDPLOTFCNS assigns values to the struct OptimValues and then calls the
% outputfcn/plotfcns.
%
% The input STATE can have the values 'init','iter','interrupt', or 'done'.
%
% For the 'done' state we do not check the value of 'stop' because the
% optimization is already done.

optimValues.iteration = iter;
optimValues.fval = val;
optimValues.gradient = g;
optimValues.firstorderopt = csnrm;
optimValues.cgiterations = pcgit;
optimValues.positivedefinite = posdef;
optimValues.degenerate = min(degen,1);
optimValues.trustregionradius = delta;
optimValues.maxiterations = maxiter;
optimValues.fnctolerance = tolfun;
optimValues.boundfeasibility = bndfeas;
optimValues.boundsexist = nbnds;
optimValues.cumcgiterations = npcg;
optimValues.lowerbounds = lbounds;
optimValues.upperbounds = ubounds;

% Note that this xvec is scaled and shifted.
xOutputfcn(:) = xvec;

stop = false;
if ~isempty(outputfcn)
    switch state
        case {'iter','init','interrupt'}
            stop = callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:}) || stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,xOutputfcn,optimValues,state,varargin{:});
        otherwise
            error('optim:sqpbox:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
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
            error('optim:sqpbox:UnknownStateInCALLOUTPUTANDPLOTFCNS','Unknown state in CALLOUTPUTANDPLOTFCNS.')
    end
end
%--------------------------------------------------------------------------
function [x,val,csnrm,it,npcg,exitflag,LAMBDA,msg] = cleanUpInterrupt(xOutputfcn,optimValues)
% CLEANUPINTERRUPT updates or sets all the output arguments of SQPBOX when the optimization
% is interrupted.

x = xOutputfcn;
val = optimValues.fval;
csnrm = optimValues.firstorderopt;
it = optimValues.iteration;
npcg = optimValues.cumcgiterations;
exitflag = -1;
LAMBDA = []; % May be in an inconsistent state
msg = 'Optimization terminated prematurely by user.';

