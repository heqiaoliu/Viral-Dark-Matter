function [q,errbnd] = quadgk(fun,a,b,varargin)
%Embedded MATLAB Library Function

%   Copyright 2007-2010 The MathWorks, Inc.
%#eml

if eml_ambiguous_types
    q = 0;
    errbnd = 0;
    return
end
eml_assert(nargin >= 3, 'Not enough input arguments.');
eml_assert(isa(fun,'function_handle'), ...
    'First input argument must be a function handle.');
eml_assert( ...
    isa(a,'float') && isscalar(a) && ...
    isa(b,'float') && isscalar(b), ...
    'A and B must be scalar floats.');
% We need a prelimary indication of the output type.  We do not allow the
% Waypoints argument to force a single precision output in Embedded MATLAB
% (an error is issued in that case), but the endpoints may be real while
% the Waypoints vector is complex, and this may or may not force the type
% of y = f(x) to be complex.
ymideg = eml_scalar_eg(a,b,fun(a/2+b/2));
eml_assert(isa(ymideg,'float'), ...
    'Supported classes are ''double'' and ''single''.');
% Parse optional inputs and retrieve the Waypoints and MaxIntervalCount
% arguments, if any.
parms = struct( ...
    'abstol',uint32(0), ...
    'reltol',uint32(0), ...
    'waypoints',uint32(0), ...
    'maxintervalcount',uint32(0));
popt = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',true, ...
    'PartialMatching',false);
optarg = eml_parse_parameter_inputs(parms,popt,varargin{:});
Waypoints = eml_get_parameter_value(optarg.waypoints, ...
    eml_expand(eml_scalar_eg(a,b),[1,0]), ...
    varargin{:});
if logical(optarg.waypoints)
    % Validate user-supplied Waypoints input.
    eml_lib_assert(isvector(Waypoints) || isequal(Waypoints,[]), ...
        'MATLAB:quadgk:invalidWaypoints', ...
        'Waypoints must be a vector.');
    eml_lib_assert(all(isfinite(Waypoints)), ...
        'MATLAB:quadgk:invalidWaypoints', ...
        'Waypoints must be finite.');
    eml_lib_assert(~isa(Waypoints,'single') || isa(ymideg,'single'), ...
        'EmbeddedMATLAB:quadgk:WaypointsTypeMismatch', ...
        ['Embedded MATLAB requires that at least one endpoint be ', ...
        '''single'' if Waypoints are ''single''.']);
end
MICtmp = eml_get_parameter_value(optarg.maxintervalcount, ...
    cast(650,eml_index_class), ...
    varargin{:});
eml_assert(eml_is_const(MICtmp),'MaxIntervalCount must be a constant.');
MaxIntervalCount = eml_const(cast(MICtmp,eml_index_class));
eml_assert(isa(MICtmp,'numeric') && isscalar(MICtmp) && ...
    isreal(MICtmp) && MICtmp > 0 && ...
    MICtmp == MaxIntervalCount, ... % 'MATLAB:quadgk:invalidMaxIntervalCount', ...
    'MaxIntervalCount must be a positive integer scalar in indexing range.');
% Determine abscissa, ordinate, and output types and complexities.
tZERO = eml_scalar_eg(a,b,Waypoints);
yZERO = eml_scalar_eg(fun(a/2+b/2+eml_scalar_eg(Waypoints)));
qZERO = eml_scalar_eg(tZERO,yZERO);
% Define default tolerance values.
if strcmp(class(qZERO),'single')
    DefaultAbsTol = single(1.e-5);
    DefaultRelTol = single(1.e-4);
else
    DefaultAbsTol = 1.e-10;
    DefaultRelTol = 1.e-6;
end
% Retrieve tolerance inputs.
AbsTol = cast( ...
    eml_get_parameter_value(optarg.abstol,DefaultAbsTol,varargin{:}), ...
    class(qZERO));
eml_lib_assert(~logical(optarg.abstol) || ( ...
    isa(AbsTol,'float') && isscalar(AbsTol) &&  ...
    isreal(AbsTol) && AbsTol >= 0), ...
    'MATLAB:quadgk:invalidAbsTol', ...
    'Invalid AbsTol');
RelTol = cast( ...
    eml_get_parameter_value(optarg.reltol,DefaultRelTol,varargin{:}), ...
    class(qZERO));
eml_lib_assert(~logical(optarg.reltol) || ( ...
    isa(RelTol,'float') && isscalar(RelTol) && ...
    isreal(RelTol) && RelTol >= 0), ...
    'MATLAB:quadgk:invalidRelTol', ...
    'Invalid RelTol');
% Make sure that RTOL >= 100*eps(outcls) except when
% using pure absolute error control (ATOL>0 && RTOL==0).
EPS100 = 100*eps(class(qZERO));
if ~(AbsTol > 0 && RelTol == 0) && RelTol < EPS100
    RelTol = EPS100;
    % Warn if user supplied this RelTol value.
    if logical(optarg.reltol)
        eml_warning('MATLAB:quadgk:increasedRelTol', ...
            'RelTol was increased to 100*eps(''%s'') = %g.',class(qZERO),RelTol);
    end
end
% Some indexing constants.
ZERO = zeros(eml_index_class);
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
% Determine the problem type, process the waypoints, and compute the
% initial interval vector.
interval = eml.nullcopy(eml_expand(tZERO,[1,MaxIntervalCount]));
if isreal(tZERO)
    % Define A and B and note the direction of integration on real axis.
    if b < a
        % Integrate left to right and change sign at the end.
        reversedir = true;
        A = b + tZERO;
        B = a + tZERO;
    else
        reversedir = false;
        A = a + tZERO;
        B = b + tZERO;
    end
    % Construct interval vector with waypoints.
    wpidx = eml_sort_idx(Waypoints,'a');
    interval(1) = A;
    nt = TWO;
    for k = ONE:eml_numel(wpidx)
        w = Waypoints(wpidx(k));
        if w > A
            if w < B
                interval(nt) = w;
                nt = eml_index_plus(nt,1);
            else
                break
            end
        end
    end
    interval(nt) = B;
    isinfA = eml_isinf(A);
    isinfB = eml_isinf(B);
    % Identify the task and perform the integration.
    if A >= B
        % Handles both finite and infinite cases.
        % Return zero or nan of the appropriate class.
        problem_type = eml_const(DEGENERATE);
    elseif ~(isinfA || isinfB)
        interval(1) = -1;
        interval(nt) = 1;
        % Analytical transformation suggested by K.L. Metlov:
        for k = TWO:eml_index_minus(nt,1)
            interval(k) = 2*sin( asin((A + B - 2*interval(k))/(A - B))/3 );
        end
        problem_type = eml_const(FINITE_A_FINITE_B);
    elseif ~isinfA && isinfB
        interval(1) = 0;
        interval(nt) = 1;
        for k = TWO:eml_index_minus(nt,1)
            interval(k) = sqrt(interval(k) - A);
        end
        for k = TWO:eml_index_minus(nt,1)
            interval(k) = interval(k) / (1 + interval(k));
        end
        problem_type = eml_const(FINITE_A_INFINITE_B);
    elseif isinfA && ~isinfB
        interval(1) = -1;
        interval(nt) = 0;
        for k = TWO:eml_index_minus(nt,1)
            interval(k) = sqrt(B - interval(k));
        end
        for k = TWO:eml_index_minus(nt,1)
            interval(k) = -interval(k) / (1 + interval(k));
        end
        problem_type = eml_const(INFINITE_A_FINITE_B);
    elseif isinfA && isinfB
        interval(1) = -1;
        interval(nt) = 1;
        % Analytical transformation suggested by K.L. Metlov:
        for k = TWO:eml_index_minus(nt,1)
            interval(k) = tanh( asinh(2*interval(k))/2 );
        end
        problem_type = eml_const(INFINITE_A_INFINITE_B);
    else % i.e., if isnan(a) || isnan(b)
        problem_type = eml_const(DEGENERATE);
    end
else
    % Handle contour integration.
    nt = eml_index_plus(eml_numel(Waypoints),2);
    interval(1) = a;
    interval(nt) = b;
    for k = TWO:eml_index_minus(nt,1);
        interval(k) = Waypoints(eml_index_minus(k,1));
    end
    for k = ONE:nt
        if ~isfinite(interval(k))
            eml_error('MATLAB:quadgk:nonFiniteContourError', ...
                'Contour endpoints and waypoints must be finite.');
        end
    end
    A = a;
    B = b;
    problem_type = eml_const(CONTOUR);
    reversedir = false;
end
% We should initialize the rest of the interval array just in case it gets
% constant-folded in some cases.
for k = eml_index_plus(nt,1):MaxIntervalCount
    interval(k) = 0;
end
% Gauss-Kronrod (7,15) pair. Use symmetry in defining nodes and weights.
q = qZERO;
errbnd = real(qZERO);
pnodes = cast([ ...
    0.2077849550078985; 0.4058451513773972; 0.5860872354676911; ...
    0.7415311855993944; 0.8648644233597691; 0.9491079123427585; ...
    0.9914553711208126 ...
    ],class(interval));
pwt = cast([ ...
    0.2044329400752989, 0.1903505780647854, 0.1690047266392679, ...
    0.1406532597155259, 0.1047900103222502, 0.06309209262997855, ...
    0.02293532201052922 ...
    ],class(qZERO));
pwt7 = cast([ ...
    0,0.3818300505051189,0,0.2797053914892767,0,0.1294849661688697,0 ...
    ],class(qZERO));
NODES = [-pnodes(end:-1:1); 0; pnodes];
NNODES = cast(eml_numel(NODES),eml_index_class);
WT = [pwt(end:-1:1), 0.2094821410847278, pwt];
EWT = WT - [pwt7(end:-1:1), 0.4179591836734694, pwt7];
% Working storage.
subs = eml.nullcopy(eml_expand(tZERO,...
    [TWO,eml_index_minus(MaxIntervalCount,1)]));
qsub = eml.nullcopy(eml_expand(qZERO, ...
    [ONE,eml_index_minus(MaxIntervalCount,1)]));
errsub = eml.nullcopy(eml_expand(qZERO, ...
    [ONE,eml_index_minus(MaxIntervalCount,1)]));
MAXNX = eml_const( ...
    eml_index_times(NNODES,eml_index_minus(MaxIntervalCount,1)));
eml.varsize('x',[1,MAXNX],[0,1]);
% Compute the path length and split interval if needed.
if problem_type == eml_const(DEGENERATE)
    pathlen = zeros(class(interval));
else
    [interval,nt,pathlen] = split(interval,nt,MaxIntervalCount);
    if ~(pathlen > 0)
        problem_type = eml_const(DEGENERATE);
    end
end
if problem_type == eml_const(DEGENERATE)
    % Test case: quadgk(@(x)x,1+1i,1+1i);
    q = midpArea(fun,A,B);
    errbnd = abs(q);
    % Account for integration direction.
    if reversedir
        q = -q;
    end
    return
end
nsubs = eml_index_minus(nt,1);
% Initialize array of subintervals of [a,b].
for k = 1:nsubs
    subs(1,k) = interval(k);
    subs(2,k) = interval(k+1);
end
% Initialize partial sums.
q_ok = qZERO;
err_ok = qZERO;
% Initialize main loop
first_iteration = true;
while true
    nx = eml_index_times(NNODES,nsubs);
    assert(nx <= MAXNX); %<HINT>
    x = eml.nullcopy(eml_expand(tZERO,[1,nx]));
    ix = ZERO;
    for k = ONE:nsubs
        midpt = (subs(1,k) + subs(2,k))/2;
        halfh = (subs(2,k) - subs(1,k))/2;
        for j = 1:NNODES
            ix = eml_index_plus(ix,1);
            x(ix) = NODES(j)*halfh + midpt;
        end
    end
    [fx,tooclose] = transfun(problem_type,fun,x,A,B,yZERO,first_iteration);
    if tooclose
        break
    end
    qsubs = qZERO;
    errsubs = qZERO;
    ix = ZERO;
    for k = ONE:nsubs
        % Quantities for subintervals.
        qsub(k) = qZERO;
        errsub(k) = real(qZERO);
        for j = ONE:NNODES
            ix = eml_index_plus(ix,1);
            qsub(k) = qsub(k) + WT(j)*fx(ix);
            errsub(k) = errsub(k) + EWT(j)*fx(ix);
        end
        halfh = (subs(2,k) - subs(1,k))/2;
        qsub(k) = qsub(k)*halfh;
        qsubs = qsubs + qsub(k);
        errsub(k) = errsub(k)*halfh;
        errsubs = errsubs + errsub(k);
    end
    % Calculate current values of q and tol.
    q = qsubs + q_ok;
    tol = max(AbsTol,RelTol*abs(q));
    tau = 2*tol/pathlen;
    errsub1norm = real(qZERO);
    nrefine = ZERO;
    for k = ONE:nsubs
        % Locate subintervals where the approximate integrals are
        % sufficiently accurate and use them to update the partial error
        % sum. Remove errsubs entries for subintervals with accurate
        % approximations.
        abserrsubk = abs(errsub(k));
        halfh = (subs(2,k) - subs(1,k))/2;
        if abserrsubk <= tau*halfh
            err_ok = err_ok + errsub(k);
            q_ok = q_ok + qsub(k);
        else
            errsub1norm = errsub1norm + abserrsubk;
            nrefine = eml_index_plus(nrefine,1);
            subs(1,nrefine) = subs(1,k);
            subs(2,nrefine) = subs(2,k);
        end
    end
    % The approximate error bound is constructed by adding the
    % approximate error bounds for the subintervals with accurate
    % approximations to the 1-norm of the approximate error bounds
    % for the remaining subintervals.  This guards against
    % excessive cancellation of the errors of the remaining
    % subintervals.
    errbnd = abs(err_ok) + errsub1norm;
    % Check for nonfinites.
    if ~(isfinite(q) && isfinite(errbnd))
        eml_warning('MATLAB:quadgk:NonFiniteValue', ...
            'Infinite or Not-a-Number value encountered.');
        break
    end
    % Test for convergence.
    if nrefine == 0 || errbnd <= tol
        break
    end
    % Split the remaining subintervals in half. Quit if splitting
    % results in too many subintervals.
    nsubs = eml_index_times(2,nrefine);
    if nsubs > MaxIntervalCount
        eml_warning('MATLAB:quadgk:MaxIntervalCountReached', ...
            ['Reached the limit on the maximum number of intervals in use.\n', ...
            'Approximate bound on error is%9.1e. The integral may not exist, or\n', ...
            'it may be difficult to approximate numerically. Increase MaxIntervalCount\n', ...
            'to %d to enable QUADGK to continue for another iteration.'], ...
            errbnd,nsubs);
        break
    end
    for k = nrefine:-1:ONE
        subs(2,2*k) = subs(2,k);
        subs(1,2*k) = (subs(1,k) + subs(2,k))/2;
        subs(2,2*k-1) = subs(1,2*k);
        subs(1,2*k-1) = subs(1,k);
    end
    first_iteration = false;
end
% Account for integration direction.
if reversedir
    q = -q;
end

%--------------------------------------------------------------------------

function q = midpArea(f,a,b)
% Return q = (b-a)*f((a+b)/2). Although formally correct as a low
% order quadrature formula, this function is only used to return
% nan or zero of the appropriate class when a == b, isnan(a), or
% isnan(b).
x = (a+b)/2;
if isfinite(a) && isfinite(b) && ~isfinite(x)
    % Treat overflow, e.g. when finite a and b > realmax/2
    x = a/2 + b/2;
end
fx = f(x);
if ~isfinite(fx)
    eml_warning('MATLAB:quadgk:NonFiniteValue', ...
        'Infinite or Not-a-Number value encountered.');
end
q = (b-a)*fx;

%--------------------------------------------------------------------------

function p = mesh_has_collapsed(x)
% Examines the mesh to determine whether any of the abscissas are too close
% in working precision.  When that occurs, it issues a warning and returns
% true.  Otherwise, it returns false.
absxk = abs(x(1));
eps100 = 100*eps(class(x));
for k = 2:size(x,2)
    absxkm1 = absxk;
    absxk = abs(x(k));
    if abs(x(k) - x(k-1)) <= eps100*max(absxkm1,absxk)
        eml_warning('MATLAB:quadgk:MinStepSize', ...
            'Minimum step size reached near x = %g; singularity possible.', ...
            x(k-1));
        p = true;
        return
    end
end
p = false;

%--------------------------------------------------------------------------

function [y,tooclose] = transfun(problem_type,f,t,A,B,yZERO,firstcall)
% Evaluate y = f(x).
% Transform the 1xn array t to the integration domain using the transform
% specified by problem_type.  A and B are the integration endpoints,
% required by some transformations.  The argument yZERO is zero of the
% output type, passed for convenience.  When firstcall is true, it does not
% perform the check to see if the abscissas are too close.
nt = size(t,2);
if ~isreal(t) % problem_type == eml_const(CONTOUR)
    % No transform.  This case will constant-fold.  It is required to
    % constant-fold because the other transformations will not compile when
    % y is real and t is complex.
    tooclose = ~firstcall && mesh_has_collapsed(t);
    if tooclose
        y = eml_expand(yZERO,[1,nt]);
    else
        y = f(t);
        if firstcall
            assert(isequal(size(t),size(y)), ...
                'MATLAB:quadgk:FxNotSameSizeAsX', ...
                'Output of the function must be the same size as the input.');
        end
    end
    return
end
x = eml.nullcopy(t);
xt = eml.nullcopy(t);
if problem_type == eml_const(FINITE_A_FINITE_B)
    % Transform to weaken singularities at both ends: [a,b] -> [-1,1]
    BmAd4 = 0.25*(B - A);
    BpAd2 = 0.5*(B + A);
    BmAtp75 = 0.75*(B - A);
    for k = 1:size(t,2)
        tk2 = t(k)*t(k);
        x(k) = BmAd4*t(k)*(3 - tk2) + BpAd2;
        xt(k) = BmAtp75*(1 - tk2);
    end
elseif problem_type == eml_const(FINITE_A_INFINITE_B)
    % Transform to weaken singularity at left end: [a,Inf) -> [0,Inf).
    % Then transform to finite interval: [0,Inf) -> [0,1].
    for k = 1:nt
        onemtk = 1 - t(k);
        tkd1mtk = t(k) / onemtk;
        x(k) = A + tkd1mtk*tkd1mtk;
        xt(k) = 2*tkd1mtk / (onemtk*onemtk);
    end
elseif problem_type == eml_const(INFINITE_A_FINITE_B)
    % Transform to weaken singularity at right end: (-Inf,b] -> (-Inf,b].
    % Then transform to finite interval: (-Inf,b] -> (-1,0].
    for k = 1:nt
        oneptk = 1 + t(k);
        tkd1ptk = t(k) / oneptk;
        x(k) = B - tkd1ptk*tkd1ptk;
        xt(k) = -2*tkd1ptk / (oneptk*oneptk);
    end
else % if problem_type == eml_const(INFINITE_A_INFINITE_B)
    % Transform to finite interval: (-Inf,Inf) -> (-1,1).
    for k = 1:nt
        tk2 = t(k).*t(k);
        onemtk2 = 1 - tk2;
        x(k) = t(k) / onemtk2;
        xt(k) = (1 + tk2) / (onemtk2*onemtk2);
    end
end
tooclose = ~firstcall && mesh_has_collapsed(x);
if tooclose
    y = eml_expand(yZERO,[1,nt]);
else
    y = f(x);
    % While the error message is not as friendly as what QUADGK gives in
    % MATLAB, using .* here instead of the assert followed by the loop
    % provides the same error checking and generates cleaner code.
    % assert(isequal(size(x),size(y)), ...
    %     'MATLAB:quadgk:FxNotSameSizeAsX', ...
    %     'Output of the function must be the same size as the input.');
    % for k = 1:nt
    %     y(k) = y(k) * xt(k);
    % end
    y = y .* xt;
end

%--------------------------------------------------------------------------

function [x,nxnew,pathlen] = split(x,nx,MaxIntervalCount)
% Split subintervals in the interval vector X so that, to working
% precision, no subinterval is longer than 1/MINSUBS times the
% total path length. Removes subintervals of zero length, except
% that the resulting X will always has at least two elements on
% return, i.e., if the total path length is zero, X will be
% collapsed into a single interval of zero length.  Also returns
% the integration path length.
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
minsubs = cast(10,eml_index_class);
if isreal(x)
    pathlen = x(nx) - x(1);
else
    pathlen = zeros(class(x));
    for k = ONE:eml_index_minus(nx,1)
        pathlen = pathlen + abs(x(eml_index_plus(k,1))-x(k));
    end
end
if pathlen > 0
    udelta = cast(minsubs,class(x))/pathlen;
    nxnew = nx;
    n = zeros(1,size(x,2)-1,eml_index_class);
    for k = ONE:eml_index_minus(nx,1)
        n(k) = ceil(abs(x(eml_index_plus(k,1))-x(k))*udelta) - 1;
        nxnew = eml_index_plus(nxnew,n(k));
    end
    assert(nxnew <= MaxIntervalCount, ...
        'EmbeddedMATLAB:quadgk:MaxIntervalCountTooSmall', ...
        'MaxIntervalCount is too small for the first iteration.');
    if nxnew > nx
        ridx = nxnew;
        for lidx = eml_index_minus(nx,1):-1:ONE
            x(ridx) = x(eml_index_plus(lidx,1));
            ridx = eml_index_minus(ridx,1);
            delta = (x(eml_index_plus(lidx,1))-x(lidx))/double(n(lidx)+1);
            % Calculate new points.
            for j = n(lidx):-1:ONE
                x(ridx) = x(lidx) + double(j)*delta;
                ridx = eml_index_minus(ridx,1);
            end
        end
    end
    nx = nxnew;
else
    nxnew = nx;
end
% Remove useless subintervals.
lidx = ONE;
for ridx = TWO:nx
    if abs(x(ridx) - x(lidx)) > 0
        lidx = eml_index_plus(lidx,1);
        x(lidx) = x(ridx);
    else
        nxnew = eml_index_minus(nxnew,1);
    end
end
if nxnew < TWO
    x(TWO) = x(nx);
    nxnew = TWO;
end

%--------------------------------------------------------------------------
%  It's more convenient and just as efficient to use constant-folded
%  functions instead of an enumeration.

function y = DEGENERATE
eml_must_inline;
y = int8(0);

function y = FINITE_A_FINITE_B
eml_must_inline;
y = int8(1);

function y = FINITE_A_INFINITE_B
eml_must_inline;
y = int8(2);

function y = INFINITE_A_FINITE_B
eml_must_inline;
y = int8(3);

function y = INFINITE_A_INFINITE_B
eml_must_inline;
y = int8(4);

function y = CONTOUR
eml_must_inline;
y = int8(5);

%--------------------------------------------------------------------------
