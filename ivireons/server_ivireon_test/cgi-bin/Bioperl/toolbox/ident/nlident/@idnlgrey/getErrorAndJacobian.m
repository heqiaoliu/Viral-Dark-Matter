function [V, truelam, e, jac, errflag, jacflag] = getErrorAndJacobian(nlsys, data, ...
    parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN  Returns the error and the Jacobian of the IDNLGREY
%   model at the point specified by parinfo. Low-level IDNLGREY method.
%
%   [V,TRUELAM, E, JAC, ERR, JACFLAG] = GETERRORANDJACOBIAN(NLSYS, DATA, ...
%      PARINFO, OPTION, DOJAC);
%
%   Inputs:
%      NLSYS   : IDNLGREY object.
%      DATA    : IDDATA object.
%      PARINFO : a structure with fields Value, Minimum and Maximum for a
%                combined list of free parameters and initial states. Use
%                obj2var to generate PARINFO.
%      OPTION  : structure with optimization algorithm properties, which
%                should include the field LimitError.
%                OPTION.DOSQRLAM: scale error and Jacobian by inverse of
%                square root of noise variance.
%      DOJAC   : compute Jacobian (true) or not (false).
%
%   Outputs:
%      V       : loss function (Ny-by-Ny matrix).
%      TRUELAM : true innovations based loss, a Ny-by-Ny matrix.
%      E       : a sum(N(k))*Ny-1 matrix with prediction errors, for k = 1,
%                2, ..., Ne. The data for one experiment remains together
%                in a way that errors for individual outputs are vertically
%                stacked beneath each other.
%      JAC     : a sum(N(k))*Ny-by-Nest Jacobian matrix, where Nest is the
%                number of estimated entities (parameters as well as initial
%                states).
%      ERRFLAG : boolean vector with Ne elements; true means that the
%                corresponding prediction error element could not be
%                computed.
%      JACFLAG : boolean Ne-by-Nest matrix, where Nest is the number of
%                estimated entities (parameters as well as initial states).
%                A true entry at (j, k) means that the Jacobian entry for
%                the j:th data experiment and the k:th  parameter failed to
%                be computed and has therefore been replaced by zeros.
%
%   See also IDNLGREY/PEM, IDNLGREY/OBJ2VAR, IDNLGREY/GETERROR,
%   IDNLGREY/GETSENSITIVITYREFINED, IDNLGREY/GETSENSITIVITYBASIC.

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.10.6 $ $Date: 2009/03/09 19:14:53 $

% Determine DATA sizes.
[n, ny] = size(data);
ne = size(data, 'ne');
N = sum(n);
jac = [];
jacflag = [];

% Retrieve limit error.
limerr = option.LimitError;

% Retrieve parameters and initial states.
parlist = parinfo.Value; % Structure of estimatable quantities.
np = length(parlist);
[x0, par] = var2obj(nlsys, parlist);

% Compute the prediction error.
[e, errflag] = getError(nlsys, data, x0, par);
if any(errflag)
    % If the prediction error(s) cannot be computed, then the Jacobian
    % cannot be computed, so just return.
    e = inf(N*ny, 1);
    jac = zeros(N*ny, np);
    truelam = inf(ny);
    V = truelam;
    return;
end

% Compute the noise variance.
errmat = -cat(1, e{:});
%TrueNobs = max(N-np/ny, 1);
%nv = errmat'*errmat/TrueNobs;
truelam = errmat'*errmat/N;

% Compute Jacobian.
if doJac
    grtype = nlsys.Algorithm.GradientOptions.GradientType;
    if (strncmpi(grtype, 'r' , 1) || strncmpi(grtype, 'a', 1))
        [jac, jacflag] = getSensitivityRefined(nlsys, data, parinfo);
    else
        [jac, jacflag] = getSensitivityBasic(nlsys, data, parinfo);
    end
end

% Perform regularization and Sqrlam scaling.
V = zeros(ny);
regul = repmat({1}, 1, ne);
e1 = cell(1, ne);

isDet = strcmpi(option.Criterion,'det');
Wt = 1; sqrWt = 1;
if ~isDet
    Wt = option.Weighting;
    was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
    sqrWt = sqrtm(Wt);
    warning(was)
end

% Regularize and apply sqrlam scaling.
for k = 1:ne
    ek = e{k};
    if (limerr ~= 0)
        ll = ones(n(k), 1)*limerr;
        la = abs(ek)+eps*ll;
        regul{k} = sqrt(min(la, ll)./la);
        llrder = find(abs(regul{k}-1)>sqrt(eps));
        regul{k}(llrder) = regul{k}(llrder)/2;
        e1k = ek.*regul{k};
    else
        e1k = ek;
    end
    V = V + e1k'*e1k;
    e1{k} = e1k;
end
V = V/N;
if ~isDet
    V = V*Wt; 
end

% Check if V is feasible.
ymeas = pvget(data, 'OutputData');
ymeas = cat(1, ymeas{:});
if (trace(V) > 1e6*trace(ymeas'*ymeas/N))
    e = inf(N*ny, 1);
    jac = zeros(N*ny, np);
    truelam = inf(ny);
    V = truelam;
    return;
end

if ~doJac
    % Both error and jacobian are requested together; else, V and truelam
    % are sufficient.
    return;
end

% noise-variance shows contributions of free parameters only, not states
%iFactor = max(1,N-npest/ny)/N;
if isDet
    % det criterion
    nv0 = V;
    if (isempty(nv0) || (norm(nv0-nv0') > sqrt(eps)) || min(eig(nv0))<=0 )
        nv0 = eye(ny); % todo: scaling?
    end
    sqrlam = inv(sqrtm(nv0));
else
    % trace criterion
    sqrlam = sqrWt;
end

% Apply sqrlam to error and sqrlam+regul to Jacobian.
e = cell(1, ne); % Reinitialize error array.
for k = 1:ne
    ek = e1{k}*sqrlam;
    e{k} = ek(:); % Vectorize to stack multiple outputs beneath each other.
    jack = jac{k};
    for j = 1:size(jack, 2)
        jackj = (reshape(jack(:, j), n(k), ny).*regul{k})*sqrlam;
        jac{k}(:, j) = jackj(:);
    end
end

% Note: jacflag need not be processed since the corresponding jac entries
% have been set to zero by getSensitivity.

% Concatenate data from all experiments. Note that the sign of the
% prediction error is changed here, due to the requirements of the
% optimization engine!
e = -cat(1, e{:}); % e is now a tall vector, rather than a matrix with ny columns.
%norm(e)
% Concatenate cell arrays vertically.
jac = cat(1, jac{:});
