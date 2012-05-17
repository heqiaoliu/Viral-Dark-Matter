function [TrueCost,truelam,e,J,Eflag,Jflag] = ...
    getErrorAndJacobian(nlobj,data,parinfo,option,doJacobian)
%getErrorAndJacobian returns error and jacobian of the model at a point
%specified by parparinfo.
%
% Inputs:
%   nlsys: idnlgrey model
%   data: iddata object at whose samples the error and Jacobian are
%         returned.
%   parinfo: a struct containing parameter values and their bounds (see
%            obj2var).
%   option  : structure with optimization algorithm properties, which
%             should include the field LimitError.
%
%   doJacobian: return Jacobian (true) or not (false).
%
% Outputs:
%   TrueCost: scalar cost value that is norm of robustified error.
%   NoiseVar: noise variance estimate
%   e: error call array (1-by-ne), where each cell is a matrix of size
%      (n(k)-by-ny).
%   J: Jacobian cell array; each cell is n(k)*ny-by-np.
%   Eflag: a boolean vector with ne elements; true means failure
%   Jflag: boolean matrix of size ne-by-np; true entry at (k,i) means the
%          jacobian entry for k'th data experiment and ith parameter set
%          failed and has been replaced with zero.

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/06/13 15:23:09 $

% Author(s): Qinghua Zhang

idnlfunVecFlag = isa(nlobj,'idnlfunVector'); %idnlfunVector or idnlfun class

nlobj = setParameterVector(nlobj, parinfo.Value);

algo = option;

npar = length(parinfo.Value);
ny = numel(nlobj);

yvec = data{1};
regmat = data{2};
Nobs = size(yvec{1},1);
%nfreedom = max(1, Nobs-npar/ny);

Eflag = false;
Jflag = false;

% Failure case handling
% If any parameter value is NaN or Inf, set Eflag,Jflag to true and return.
failedIter = ~all(isfinite(parinfo.Value));

if failedIter
    Eflag = true;
    Jflag = true;
    e = inf(npar+1,1);
    J = zeros(npar+1, npar);
    truelam = inf(ny);
    TrueCost = truelam;
    return
end

lim = option.LimitError;
if lim==0
    limflag = false;
else
    limflag = true;
end

isDet = strcmpi(option.Criterion,'det');
Wt = 1; sqrWt = 1;
if ~isDet && isequal(ny,size(option.Weighting,1))
    Wt = option.Weighting;
    was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
    sqrWt = sqrtm(Wt);
    warning(was)
end

% Noise variance (truelam) estimation and TrueCost computation
e = evaluate(nlobj, regmat) - cell2mat(yvec(:)');
truelam = e'*e / Nobs;

if limflag
    la = abs(e)+eps*lim;
    regul = sqrt(min(la,lim)./la);
    el = e.*regul;
    TrueCost = el'*el / Nobs;
else
    TrueCost = truelam;
end

if ~isDet
    TrueCost = TrueCost*Wt;
end

if ~doJacobian
    e = [];
    J = [];
    return
end

%const = 1;
applySqrlam = true;
if ~isDet
    % Trace criterion
    invsqrtnv = sqrWt;
else
    noi = truelam;
    if isempty(noi) || ~isnumeric(noi) || ~all(isfinite(noi(:))) || min(eig(noi))<=0
        noi = eye(ny);
        applySqrlam = false;
        %const = sqrt(Nobs);
    end
    invsqrtnv = pinv(sqrtm(noi));
end

if isequal(invsqrtnv,eye(ny))
    applySqrlam = false; %no need to apply Sqrlam if it is unity
end

R1 = zeros(0,npar+1);
maxsize = algo.MaxSize;

M = floor(maxsize/(npar+1));  % If nobs>M do computations it in portions.
M = max(M,1);

psicell = cell(ny, 1);

for k = 1:M:Nobs
    jj = k:min(Nobs,k+M-1);   %   disp([jj(1), jj(end)])

    e = zeros(length(jj), ny);
    if idnlfunVecFlag
        for ky=1:ny
            [yhatky, psicell{ky}] = getJacobian(nlobj.ObjVector{ky}, regmat{ky}(jj,:));
            e(:,ky) = yhatky - yvec{ky}(jj,:);
        end
    else
        for ky=1:ny
            [yhatky, psicell{ky}] = getJacobian(nlobj(ky), regmat{ky}(jj,:));
            e(:,ky) = yhatky - yvec{ky}(jj,:);
        end
    end
    psi = blkdiag(psicell{:});

    if ~limflag
        el = e(:); % vectorize (vertical stacking)
    else
        la = abs(e(:))+eps*lim;
        regul = sqrt(min(la,lim)./la);
        el = e(:).*regul;

        llrder = find(regul~=1);
        regulder = regul;
        regulder(llrder) = regul(llrder)/2;

        psi = psi.* regulder(:,ones(1,npar));
    end

    if applySqrlam
        el = reshape(el, size(e));
        el = el * invsqrtnv;
        el = el(:);

        rowspsi = length(jj);
        [Nall, np] = size(psi);
        for kp=1:np
            psi(:,kp) = reshape(reshape(psi(:,kp), rowspsi,ny)*invsqrtnv, Nall,1);
        end
    %{
    elseif ~isequal(const,1)
        el = el*const;
        psi = psi*const;
    %}
    end
    mrc = min(size(R1));
    R1 = triu(qr([R1(1:mrc,:);[psi, el]]));

end %for k

mn1 = min(npar+1,min(size(R1)));
J = R1(1:mn1,1:npar);
e = R1(1:mn1,npar+1);

% FILE END
