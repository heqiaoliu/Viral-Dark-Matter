function [TrueCost,truelam,e,J,Eflag,Jflag] = ...
    getErrorAndJacobian(sys,data,parinfo,option,doJacobian)
%getErrorAndJacobian returns error and jacobian of the model at a point
%specified by parinfo.
%
%   Inputs:
%   nlsys: idnlgrey model
%   data: iddata object at whose samples the error and Jacobian are
%         returned.
%   parinfo: a struct containing parameter values and their bounds (see
%            obj2var).
%   option  : structure with optimization algorithm properties, which
%             should include the field LimitError.
%             option.dosqrlam: scale error and Jacobian by inverse of
%             square root of noise variance.
%   doJacobian: return Jacobian (true) or not (false).
%
%   Outputs:
%   TrueCost: loss function (Ny-by-Ny matrix).
%   NoiseVar: noise variance estimate
%   e: error call array (1-by-ne), where each cell is a matrix of size
%      (n(k)*ny-by-1), with data from all outputs stacked beneath each
%      other for each experiment (i.e. data for one exp remains together).
%   J: Jacobian cell array; each cell is n(k)*ny-by-np.
%   Eflag: a boolean vector with ne elements; true means failure
%   Jflag: boolean matrix of size ne-by-np; true entry at (k,i) means the
%          jacobian entry for k'th data experiment and ith parameter set
%          failed and has been replaced with zero.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/05/23 08:02:41 $

% Author(s): Qinghua Zhang, Rajiv Singh.

sys = setParameterVector(sys, parinfo.Value);

algo = sys.Algorithm;
npar = length(parinfo.Value);
ny = size(sys, 1);
nex = size(data, 'ne');
Nobs = size(data,1);
sumNobs = sum(Nobs);

dataUD = data.UserData;
allParamNums = dataUD.allParamNums;

e = [];
J = [];
Eflag = false;
Jflag = false;

% Failure case handling
% If any parameter value is NaN or Inf, or if |poles|>=1,
% set Eflag,Jflag to true and return.
failedIter = ~all(isfinite(parinfo.Value));
if ~failedIter
    allpoles = cellfun(@roots, pvget(sys, 'f'), 'UniformOutput', false);
%     failedIter = any(abs(cell2mat(allpoles(:)))>1);
    failedIter = any(abs(cell2mat(allpoles(:)))>1+sqrt(eps));
end
if failedIter
    Eflag = true(nex, 1);
    Jflag = true(nex, npar);
    truelam = inf(ny);
    TrueCost = truelam;
    e = inf(npar+1,1);
    J = zeros(npar+1,npar);

    return
end

% Preparation for initial state estimation
initEstimate = ~isempty(pvget(sys, 'InitialState'));
if initEstimate
  userdata = struct( 'kex', 0, 'FirstSample', 0);
end

lim = option.LimitError;
if lim==0
    limflag = false;
else
    limflag = true;
end

% truelam estimation and TrueCost computation
truelam = zeros(ny);
TrueCost = zeros(ny);

isDet = strcmpi(option.Criterion,'det');
Wt = 1; sqrWt = 1;
if ~isDet
    Wt = option.Weighting;
    was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
    sqrWt = sqrtm(Wt);
    warning(was)
end

for kex = 1:nex
    datakex = getexp(data,kex);
    
    if initEstimate
      userdata.kex = kex;
      userdata.FirstSample = 1; % The index of the first sample in the block.
      datakex.UserData = userdata;
      % Note: setting datakex.UserData does not affect data.UserData
      % carrying DB and DF.
    end
    
    e = outputJacobian(sys, datakex, [], allParamNums) - datakex.y;
    truelam = truelam + e'*e;

    if limflag
        la = abs(e)+eps*lim;
        regul = sqrt(min(la,lim)./la);
        el = e.*regul;
        TrueCost = TrueCost + el'*el;
    else
        TrueCost = truelam;
    end
end

truelam = truelam/sumNobs;
TrueCost = TrueCost/sumNobs;
if ~isDet
    TrueCost = TrueCost*Wt;
end

if ~doJacobian
    return;
end

% DB and DF were computed in pem/IterEstimation
DB = dataUD.DB;
DF = dataUD.DF;

%const = 1;
applySqrlam = true;
if ~isDet
    % trace criterion
    invsqrtnv = sqrWt;
else
    noi = truelam;
    if isempty(noi) || ~isnumeric(noi) || ~all(isfinite(noi(:))) || min(eig(noi))<=0
        noi = eye(ny); %/sumNobs;
        applySqrlam = false;
        %const = sqrt(sumNobs);
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

for kex = 1:nex  % Loop over experiments data
    datakex = getexp(data,kex);
    nobs = size(datakex,1);
    initFilt = [];

    for k = 1:M:nobs
        jj = k:min(nobs,k+M-1);   % disp([jj(1), jj(end)])

        if initEstimate
          userdata.kex = kex;
          userdata.FirstSample = k; % The index of the first sample in the block.
          datakex.UserData = userdata;
          % Note: setting datakex.UserData does not affect data.UserData
          % carrying DB and DF.
        end
            
        [yhat, initFilt, psi] = outputJacobian(sys, datakex(jj), initFilt, allParamNums, DB, DF);
        psi = cell2mat(psi(:));
        e = yhat - datakex(jj).y;

        if ~limflag
            el = e(:);
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
        end

        mrc = min(size(R1));
        R1 = triu(qr([R1(1:mrc,:);[psi, el]]));
    end %for k
end %for kex

mn1 = min(npar+1,min(size(R1)));
J = R1(1:mn1,1:npar);
e = R1(1:mn1,npar+1);
Eflag = false(nex, 1);
Jflag = false(nex, npar);

% FILE END
