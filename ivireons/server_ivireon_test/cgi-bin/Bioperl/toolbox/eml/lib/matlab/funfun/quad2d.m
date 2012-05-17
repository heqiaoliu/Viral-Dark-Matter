function [Q,errbnd] = quad2d(fun,A,B,c,d,varargin)
%Embedded MATLAB Library Function

%   Limitations:
%   1. The Embedded MATLAB version uses a fixed upper limit on internal
%   storage arrays.  The size should be sufficient but early termination
%   and warning is possible with some types of very difficult integrals.

%   Copyright 2008-2009 The MathWorks, Inc.
%#eml

if eml_ambiguous_types
    Q = 0;
    errbnd = 0;
    return
end
eml_assert(nargin >= 5, 'Not enough input arguments.');
eml_assert(isa(fun,'function_handle'), ... % 'MATLAB:quad2d:invalidIntegrand'
    'First input argument must be a function handle.');
eml_lib_assert(isfloat(A) && isscalar(A) && isfinite(A), ...
    'MATLAB:quad2d:invalidA', ...
    'A must be a finite, scalar, floating point constant.');
eml_lib_assert(isfloat(B) && isscalar(B) && isfinite(B), ...
    'MATLAB:quad2d:invalidB', ...
    'B must be a finite, scalar, floating point constant.');
eml_lib_assert(isa(c,'function_handle') || (isfloat(c) && isscalar(c) && isfinite(c)), ...
    'MATLAB:quad2d:invalidC', ...
    'C must be a finite, scalar, floating point constant or a function handle.');
eml_lib_assert(isa(d,'function_handle') || (isfloat(d) && isscalar(d) && isfinite(d)), ...
    'MATLAB:quad2d:invalidD', ...
    'D must be a finite, scalar, floating point constant or a function handle.');
ONE = ones(eml_index_class);
TWO = cast(2,eml_index_class);
QZERO = zero_of_output_type(fun,A,B,c,d);
outcls = class(QZERO);
eps100 = 100*eps(outcls);
%--------------------------------------------------------------------------
% Parse and assimilate input options.
%--------------------------------------------------------------------------
eml_prefer_const(varargin);
parms = struct( ...
    'abstol',uint32(0), ...
    'reltol',uint32(0), ...
    'singular',uint32(0), ...
    'maxfunevals',uint32(0), ...
    'failureplot',uint32(0));
popt = struct( ...
    'CaseSensitivity',false, ...
    'StructExpand',true, ...
    'PartialMatching',false);
optarg = eml_parse_parameter_inputs(parms,popt,varargin{:});
Singular = eml_get_parameter_value(optarg.singular,true,varargin{:});
eml_assert(~logical(optarg.singular) || ( ...
    islogical(Singular) && isscalar(Singular)), ...
    'MATLAB:quad2d:invalidSingular', ...
    'Singular option must be true or false.');
FailurePlot = eml_get_parameter_value(optarg.failureplot,false,varargin{:});
eml_lib_assert(~logical(optarg.failureplot) || ( ...
    islogical(FailurePlot) && isscalar(FailurePlot) && ...
    FailurePlot == false), ...
    'EmbeddedMATLAB:quad2d:invalidFailurePlot', ...
    'The FailurePlot option is not supported in Embedded MATLAB.');
MFEtmp = eml_get_parameter_value(optarg.maxfunevals, ...
    cast(2000,eml_index_class), ...
    varargin{:});
eml_assert(eml_is_const(MFEtmp),'MaxFunEvals must be a constant.');
MaxFunEvals = eml_const(cast(MFEtmp,eml_index_class));
eml_assert(~logical(optarg.maxfunevals) || ( ...
    isa(MFEtmp,'numeric') && isscalar(MFEtmp) && ...
    isreal(MFEtmp) && MFEtmp > 0 && ...
    MFEtmp == MaxFunEvals), ... % 'MATLAB:quad2d:invalidMaxFunEvals', ...
    'MaxFunEvals must be a positive integer scalar in indexing range.');
atol = cast( ...
    eml_get_parameter_value(optarg.abstol,1e-5,varargin{:}), ...
    class(QZERO));
eml_lib_assert(~logical(optarg.abstol) || ( ...
    isa(atol,'float') && isscalar(atol) &&  ...
    isreal(atol) && atol >= 0), ...
    'MATLAB:quad2d:invalidAbsTol', ...
    'Invalid AbsTol');
rtol = cast( ...
    eml_get_parameter_value(optarg.reltol,eps100,varargin{:}), ...
    class(QZERO));
eml_lib_assert(~logical(optarg.reltol) || ( ...
    isa(rtol,'float') && isscalar(rtol) && ...
    isreal(rtol) && rtol >= 0), ...
    'MATLAB:quad2d:invalidRelTol', ...
    'Invalid RelTol');
if rtol < eps100
    rtol = eps100;
    if logical(optarg.reltol)
        % Warn if user supplied this RelTol value.
        eml_warning('MATLAB:quad2d:increasedRelTol', ...
            'RelTol was increased to 100*eps(''%s'') = %g.',outcls,rtol);
    end
end
rtold8 = max(rtol/8,eps100);
atold8 = atol/8;
%--------------------------------------------------------------------------
% Define formula constants.
%--------------------------------------------------------------------------
NODES = [-0.9604912687080202, -0.7745966692414834, -0.4342437493468026, ...
    0, 0.4342437493468026, 0.7745966692414834, 0.9604912687080202];
NNODES = eml_numel(NODES);
N2 = 2*NNODES;
NARRAY = cast([NODES+1,NODES+3]/4,outcls);
WT3 = cast([0, 5/9, 0, 8/9, 0, 5/9, 0],outcls);
WT7 = cast([0.1046562260264672, 0.2684880898683334, 0.4013974147759622, ...
    0.4509165386584744, 0.4013974147759622, 0.2684880898683334, ...
    0.1046562260264672],outcls);
if Singular
    thetaL = zeros(outcls);
    thetaR = cast(pi,outcls);
    phiB = zeros(outcls);
    phiT = cast(pi,outcls);
    area = cast(pi*pi,outcls);
else
    thetaL = cast(A,outcls);
    thetaR = cast(B,outcls);
    phiB = zeros(outcls);
    phiT = ones(outcls);
    area = cast(B-A,outcls);
end
%--------------------------------------------------------------------------
% Initialize variables and storage lists.
%--------------------------------------------------------------------------
Q = QZERO;
errbnd = real(QZERO);
err_ok = real(QZERO);
nfe = 0;
maxrectwarn = false;
minrectwarn = false;
maxnfewarn = false;
MAXRECTS = 2500;
xreflist = zeros(MAXRECTS,1,'uint16');
adjerrlist = zeros(MAXRECTS,1,outcls);
rectlist = zeros(5,MAXRECTS,outcls);
qlist = eml_expand(QZERO,[MAXRECTS,1]);
%--------------------------------------------------------------------------
% Populate storage lists with first rectangle.
%--------------------------------------------------------------------------
adjerrlist(1) = 1;
xreflist(1) = 1;
rectlist(1,1) = 1;
rectlist(2,1) = thetaL;
rectlist(3,1) = thetaR;
rectlist(4,1) = phiB;
rectlist(5,1) = phiT;
nrects = ones(eml_index_class);
% The first time through the loop is special.  A tighter tolerance is used
% to encourage subdivision of the initial rectangles, and some additional
% input validation is performed.  Also, to accommodate degenerate input
% problems, the checks for collapsed rectangles along the boundary is not
% performed in the first iteration.
firstit = true;
%--------------------------------------------------------------------------
% Perform the integration.
%--------------------------------------------------------------------------
while nrects > 0
    %----------------------------------------------------------------------
    %  Select the next rectangle for subdivision.
    %      qlist   A list of approximate integral results kept in the same
    %              order as rectlist. Unused entries are zero.
    %   rectlist   The columns of the rectlist matrix are
    %              [esub;thetaL;thetaR;phiB;phiT]
    % adjerrlist   A list of adjusted errors kept in ascending order.
    %              Unused entries are zero.
    %   xreflist   a cross-reference list: adjerrlist(idx) corresponds
    %              to rectlist(xreflist(idx)). Unused entries are zero.
    %     nrects   is the number of active entries in each of these lists.
    %----------------------------------------------------------------------
    smallestFirst = nrects > 2000;
    if smallestFirst
        idx = xreflist(1);
        adjerr_i = adjerrlist(1);
    else
        idx = xreflist(nrects);
        adjerr_i = adjerrlist(nrects);
    end
    q_i = qlist(idx);
    esub_i = rectlist(1,idx);
    thetaL = rectlist(2,idx);
    thetaR = rectlist(3,idx);
    phiB = rectlist(4,idx);
    phiT = rectlist(5,idx);
    if idx < nrects
        % If idx doesn't correspond to the last active column of rectlist,
        % the idx column is overwritten by the last active column.
        qlist(idx) = qlist(nrects);
        rectlist(1,idx) = rectlist(1,nrects);
        rectlist(2,idx) = rectlist(2,nrects);
        rectlist(3,idx) = rectlist(3,nrects);
        rectlist(4,idx) = rectlist(4,nrects);
        rectlist(5,idx) = rectlist(5,nrects);
        for k = ONE:nrects
            if xreflist(k) == nrects
                xreflist(k) = idx;
                break
            end
        end
    end
    if smallestFirst
        % We removed the first element of the sorted lists, so we must
        % shift the others.
        for k = ONE:eml_index_minus(nrects,1)
            xreflist(k) = xreflist(k+1);
            adjerrlist(k) = adjerrlist(k+1);
        end
    end
    xreflist(nrects) = 0;
    qlist(nrects) = 0;
    adjerrlist(nrects) = 0;
    nrects = nrects - 1;
    %----------------------------------------------------------------------
    %  Map the (theta,phi) rectangle to the (x,y) plane.
    %----------------------------------------------------------------------
    dtheta = thetaR - thetaL;
    theta = thetaL + NARRAY*dtheta; % row vector
    if Singular
        x = 0.5*(B + A) + 0.5*(B - A)*cos(theta);
        % Checked for collapsed rectangles along the boundary.
        if ~firstit && (x(1) == B || x(end) == A)
            minrectwarn = true;
            err_ok = err_ok + adjerr_i;
            continue
        end
    else
        x = theta;
        % Checked for collapsed rectangles along the boundary.
        if ~firstit && (x(1) == A || x(end) == B)
            minrectwarn = true;
            err_ok = err_ok + adjerr_i;
            continue
        end
    end
    if isa(c,'function_handle')
        bottom = c(x);
    else
        bottom = c;
    end
    if isa(d,'function_handle')
        top = d(x);
    else
        top = d;
    end
    if firstit
        eml_lib_assert(~isa(c,'function_handle') || isequal(size(bottom),size(x)), ...
            'MATLAB:quad2d:CSizeMismatch', ...
            'Lower limit size mismatch: size(C(x)) does not match size(x).');
        if isscalar(bottom)
            nonfiniteflag = ~isfinite(bottom);
        else
            nonfiniteflag = false;
            for k = ONE:N2
                if ~isfinite(bottom(k))
                    nonfiniteflag = true;
                    break
                end
            end
        end
        if nonfiniteflag
            eml_error('MATLAB:quad2d:nonFiniteCx','C(x) must be a finite.');
        end
        eml_lib_assert(~isa(d,'function_handle') || isequal(size(top),size(x)), ...
            'MATLAB:quad2d:DSizeMismatch', ...
            'Upper limit size mismatch: size(D(x)) does not match size(x).');
        if isscalar(top)
            nonfiniteflag = ~isfinite(top);
        else
            nonfiniteflag = false;
            for k = ONE:N2
                if ~isfinite(top(k))
                    nonfiniteflag = true;
                    break
                end
            end
        end
        if nonfiniteflag
            eml_error('MATLAB:quad2d:nonFiniteDx','D(x) must be a finite.');
        end
    end
    dydt = top - bottom;
    dphi = phiT - phiB;
    phi = phiB + NARRAY*dphi;
    Y = eml.nullcopy(eml_expand(QZERO,[N2,N2]));
    if Singular
        % Y = repmat(bottom,N2,1) + (0.5 + 0.5*cos(phi))*dydt;
        for i = ONE:N2
            Y(i,1) = 0.5 + 0.5*cos(phi(i));
        end
        for j = TWO:N2
            bottom_j = eml_scalexp_subsref(bottom,j);
            dydt_j = eml_scalexp_subsref(dydt,j);
            for i = ONE:N2
                Y(i,j) = Y(i,1)*dydt_j + bottom_j;
            end
        end
        for i = ONE:N2
            Y(i,1) = Y(i,1)*dydt(1) + bottom(1);
        end
        if ~firstit
            % Checked for collapsed rectangles along the boundary.
            collapsed = false;
            for k = ONE:N2
                if Y(1,k) == eml_scalexp_subsref(top,k) || ...
                        Y(N2,k) == eml_scalexp_subsref(bottom,k)
                    collapsed = true;
                    break
                end
            end
            if collapsed
                minrectwarn = true;
                err_ok = err_ok + adjerr_i;
                continue
            end
        end
    else
        % Y = repmat(bottom,N2,1) + phi*dydt;
        for j = ONE:N2
            bottom_j = eml_scalexp_subsref(bottom,j);
            dydt_j = eml_scalexp_subsref(dydt,j);
            for i = ONE:N2
                Y(i,j) = bottom_j + phi(i)*dydt_j;
            end
        end
        if ~firstit
            % Checked for collapsed rectangles along the boundary.
            collapsed = false;
            for k = ONE:N2
                if Y(1,k) == eml_scalexp_subsref(bottom,k) || ...
                        Y(N2,k) == eml_scalexp_subsref(top,k)
                    collapsed = true;
                    break
                end
            end
            if collapsed
                minrectwarn = true;
                err_ok = err_ok + adjerr_i;
                continue
            end
        end
    end
    % X = repmat(x,N2,1);
    X = eml.nullcopy(Y);
    for j = ONE:N2
        for i = ONE:N2
            X(i,j) = x(j);
        end
    end
    %----------------------------------------------------------------------
    %  Evaluate the integrand.
    %----------------------------------------------------------------------
    Z = fun(X,Y);  nfe = nfe + 1;
    if firstit
        % Some indices between 1 and 4*NNODES^2.
        VTSTIDX = cast([16,74,132;27,81,124],eml_index_class);
        Z1 = fun(X(VTSTIDX),Y(VTSTIDX)); nfe = nfe + 1;
        eml_lib_assert(isequal(size(Z),size(X)) && isequal(size(Z1),size(VTSTIDX)), ...
            'MATLAB:quad2d:SizeMismatch', ...
            'Integrand output size does not match the input size.');
        Z0 = Z(VTSTIDX);
        vectfail = false;
        for k = ONE:eml_numel(VTSTIDX)
            if abs(Z1(k)-Z0(k)) > max(atol,rtol*max(abs(Z1(k)),abs(Z0(k))))
                vectfail = true;
                break
            end
        end
        if vectfail
            eml_warning('MATLAB:quad2d:FunVectorization', ...
                ['Integrand function outputs did not match to the ', ...
                'required tolerance when the same input values were ', ...
                'supplied in two separate calls with different size input ', ...
                'matrices.  Check that the function is vectorized properly.']);
        end
    end
    if Singular
        % temp = 0.25*(B - A)*sin(phi)*(dydt.*sin(theta));  Z = Z .* temp;
        phi = sin(phi);
        for j = ONE:N2
            thetaj = 0.25*(B-A)*eml_scalexp_subsref(dydt,j)*sin(theta(j));
            for i = ONE:N2
                Z(i,j) = Z(i,j)*(thetaj*phi(i));
            end
        end
    else
        for j = ONE:N2
            dydt_j = eml_scalexp_subsref(dydt,j);
            for i = ONE:N2
                Z(i,j) = Z(i,j)*dydt_j;
            end
        end
    end
    %----------------------------------------------------------------------
    %  Evaluate the quadrature formula.
    %----------------------------------------------------------------------
    qsub = eml_expand(QZERO,[4,1]);
    esub = eml_expand(QZERO,[4,1]);
    % Kronrod 7 point formula tensor product.
    for j = ONE:NNODES
        for i = ONE:NNODES
            qsub(1) = qsub(1) + WT7(i)*WT7(j)*Z(i,j);
            qsub(2) = qsub(2) + WT7(i)*WT7(j)*Z(i,j+NNODES);
            qsub(3) = qsub(3) + WT7(i)*WT7(j)*Z(i+NNODES,j);
            qsub(4) = qsub(4) + WT7(i)*WT7(j)*Z(i+NNODES,j+NNODES);
        end
    end
    % Gauss 3 point formula tensor product and difference with qsub.
    for j = TWO:TWO:NNODES
        for i = TWO:TWO:NNODES
            esub(1) = esub(1) + WT3(i)*WT3(j)*Z(i,j);
            esub(2) = esub(2) + WT3(i)*WT3(j)*Z(i,j+NNODES);
            esub(3) = esub(3) + WT3(i)*WT3(j)*Z(i+NNODES,j);
            esub(4) = esub(4) + WT3(i)*WT3(j)*Z(i+NNODES,j+NNODES);
        end
    end
    r = (dtheta/4)*(dphi/4);
    for i = ONE:4
        qsub(i) = qsub(i)*r;
        % The esub array is complex, but here the entries are made real.
        esub(i) = abs(esub(i)*r - qsub(i));
    end
    %----------------------------------------------------------------------
    %  Update Q.
    %----------------------------------------------------------------------
    sumqsub = qsub(1) + qsub(2) + qsub(3) + qsub(4);
    Q = Q + (sumqsub - q_i);
    %----------------------------------------------------------------------
    %  Compute TOL and ADJUST.  Set firstit to false.
    %----------------------------------------------------------------------
    if firstit
        TOL = eps100*abs(Q);
        ADJUST = ones(outcls);
        firstit = false;
    else
        TOL = max(atold8,rtold8*abs(Q));
        % Note that esub_i > 0 or else the rectangle would not have been
        % queued for refinement.
        ADJUST = min(ones(class(QZERO)),eml_rdivide(abs(q_i - sumqsub),esub_i));
    end
    %----------------------------------------------------------------------
    %  Save rectangles as needed in the storage lists.
    %----------------------------------------------------------------------
    dthetad2 = dtheta/2;
    thetaM = thetaL + dthetad2;
    dphid2 = dphi/2;
    phiM = phiB + dphid2;
    localtol = TOL*dthetad2*dphid2/area;
    localtol = max(abs(localtol),eps100*abs(sumqsub));
    adjerr = ADJUST*real(esub);
    theta1 = [thetaL,thetaM,thetaL,thetaM];
    theta2 = [thetaM,thetaR,thetaM,thetaR];
    phi1 = [phiB,phiB,phiM,phiM];
    phi2 = [phiM,phiM,phiT,phiT];
    for k = ONE:4
        if adjerr(k) <= localtol
            err_ok = err_ok + adjerr(k);
        elseif nrects == MAXRECTS
            maxrectwarn = true;
            err_ok = err_ok + adjerr(k);
        else
            nrects = eml_index_plus(nrects,1);
            i = nrects;
            for j = ONE:eml_index_minus(nrects,1)
                if adjerr(k) < adjerrlist(j)
                    i = j;
                    break
                end
            end
            % Insert sorted adjerr ascending into adjerrlist.
            % adjerrlist(idx+1:nrects) = adjerrlist(idx:nrects-1);
            % Insert the cross-reference index into xreflist.
            % xreflist(idx+1:nrects) = xreflist(idx:nrects-1);
            for j = nrects:-1:eml_index_plus(i,1)
                adjerrlist(j) = adjerrlist(eml_index_minus(j,1));
                xreflist(j) = xreflist(eml_index_minus(j,1));
            end
            adjerrlist(i) = adjerr(k);
            xreflist(i) = nrects;
            % Save the data in rectlist.
            qlist(nrects) = qsub(k);
            rectlist(1,nrects) = real(esub(k));
            rectlist(2,nrects) = theta1(k);
            rectlist(3,nrects) = theta2(k);
            rectlist(4,nrects) = phi1(k);
            rectlist(5,nrects) = phi2(k);
        end
    end
    %----------------------------------------------------------------------
    %  Update errbnd.
    %----------------------------------------------------------------------
    errbnd = err_ok;
    for k = ONE:nrects
        errbnd = errbnd + adjerrlist(k);
    end
    %----------------------------------------------------------------------
    %  Check termination criteria.
    %----------------------------------------------------------------------
    if nfe >= MaxFunEvals
        maxnfewarn = true;
        break
    elseif ~(errbnd > TOL) % Written to terminate if isnan(errbnd).
        break
    end
end % while
%--------------------------------------------------------------------------
%  Issue warnings as needed and return.
%--------------------------------------------------------------------------
if ~(isfinite(Q) && isfinite(errbnd))
    eml_warning('MATLAB:quad2d:nonFiniteResult', ...
        'Non-finite result. The integration was unsuccessful. Singularity likely.');
elseif maxnfewarn
    if errbnd > max(atol,rtol*abs(Q))
        eml_warning('MATLAB:quad2d:maxFunEvalsFail', ...
            ['Reached the maximum number of function evaluations (%d). ', ...
            'The result fails the global error test.'],MaxFunEvals);
    else
        eml_warning('MATLAB:quad2d:maxFunEvalsPass', ...
            ['Reached the maximum number of function evaluations (%d). ', ...
            'The result passes the global error test.'],MaxFunEvals);
    end
elseif minrectwarn
    if errbnd > max(atol,rtol*abs(Q))
        eml_warning('MATLAB:quad2d:minRectSizeFail', ...
            'Reached the minimum rectangle size. The result fails the global error test.');
    else
        eml_warning('MATLAB:quad2d:minRectSizePass', ...
            'Reached the minimum rectangle size. The result passes the global error test.');
    end
elseif maxrectwarn
    if errbnd > max(atol,rtol*abs(Q))
        eml_warning('MATLAB:quad2d:maxRectanglesFail', ...
            'Exceeded the maximum number of rectangles queued for refinement. The result fails the global error test.');
    else
        eml_warning('MATLAB:quad2d:maxRectanglesPass', ...
            'Exceeded the maximum number of rectangles queued for refinement. The result passes the global error test.');
    end
end

%--------------------------------------------------------------------------

function z = zero_of_output_type(fun,a,b,c,d)
% Return zero of the correct class and complexness for the output.
eml_must_inline;
xmid = a/2 + b/2;
if isa(c,'function_handle')
    bottom = c(xmid);
else
    bottom = c;
end
if isa(d,'function_handle')
    ymid = bottom/2 + d(xmid)/2;
else
    ymid = bottom/2 + d/2;
end
z = eml_scalar_eg(fun(xmid,ymid),xmid,ymid);

%--------------------------------------------------------------------------
