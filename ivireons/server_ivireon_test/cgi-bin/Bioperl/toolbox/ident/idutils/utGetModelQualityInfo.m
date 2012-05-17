function S = utGetModelQualityInfo(sys, data, np, npest, pestind, parinfo, option)
%UTGETMODELQUALITYINFO  Return a struct containing: NoiseVariance, LossFcn,
%   CovarianceMatrix, FPE, and Warning.
%
%   Inputs:
%       sys:    model whose quality is being obtained.
%       data:     data used to assess the quality.
%       np:       total number of model parameters (fixed+free).
%       npest:    total number of free parameters (Fixed=false).
%       pestind:  indices of free parameters in a tall vector of all
%                 parameters.
%       parinfo:  struct containing parameter values and their bounds (see
%                 obj2var).
%       option:   information about estimation procedure.

% Rajiv Singh
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.18 $ $Date: 2009/10/16 04:56:44 $

%% Create output structure.
S = struct('NoiseVariance', [], 'LossFcn', [], 'CovarianceMatrix', ...
    pvget(sys, 'CovarianceMatrix'), 'FPE', [], 'Warning','','TrueLam',[]);

% Return J scaled by true innovations covariance (truelam) regardless of cost
option.LimitError = 0; % this would corrupt cost value, but we do not need it here
%option.doSqrlam = true;
[~, truelam, ~, J] = getErrorAndJacobian(sys, data, parinfo, option, true);

S.TrueLam = truelam;

ny = size(sys, 'ny');
n = option.DataSize;

if isa(sys,'idnlmodel')
    Nobs = sum(n);
    Factor = Nobs/max(1,Nobs-npest);
else
    % linear model; truelam is already scaled
    Nobs = option.struc.Nobs;
    Factor = 1;
end

%% Loss Function and FPE.
%   Note: LossFcn should always be det(e'*e) even if the minimization
%   criterion used is different (LossFcn is post-estimation user info that
%   should be uniformally reported, regardless of criterion used).

V = real(abs(det(truelam)));
if isa(sys,'idnlmodel')
    % truelam is already scaled by 1/Nobs
    S.LossFcn = V;
else
    % truelam scaling needs to be compensated for
    S.LossFcn = V*((Nobs-np)/Nobs)^ny;
end

% FPE is function of Er the residual error (no LimitError adj.)
S.FPE = S.LossFcn *(1+2*npest/Nobs);

%% Covariance Matrix.
%  Covariance formula:
%   inv(Psi*W*Psi')*(PsiF*W*Lambda0*W*PsiF')*inv(Psi*W*Psi')
%   Lambda0 is the variance of the true innovations e (not v=He).
%   PsiF is Psi filtered through the H-filter backwards (H estimated
%   separately using N4SID if model is OE). When calling
%   getErrorAndJacobian with oeflag = 1, the returned psi (=J) is such that
%   psi*psi' = PsiF*W*Lambda0*W*PsiF' for this correct Lambda0. W is
%   inv(Lambda) for det criterion, and is option.Weighting for trace
%   criterion. 
isDet = strcmpi(option.Criterion,'det');
applyOE = isa(sys,'idmodel') && option.struc.oeflag;
ssFreePar = isa(sys,'idss') && strcmpi(sys.SSParameterization,'Free');
if ~strcmpi(pvget(sys, 'CovarianceMatrix'), 'none') && ~isempty(pestind) && ~ssFreePar
    warn = ctrlMsgUtils.SuspendWarnings('MATLAB:singularMatrix',...
        'MATLAB:nearlySingularMatrix', 'MATLAB:divideByZero');

    try
        % Update the covariance matrix.
        covmat = zeros(np);  % "parameters" only (not initial states)
        [~,r1] = qr(J(:, 1:npest),0); %Note: J is already its R factor for linear models
        r1inv = eye(size(r1))/r1;
        J1inv = r1inv*r1inv';

        if applyOE
            % Redefine truelam and update covariance
            % (call getErrorAndJacobian with last input as oeflag)
            [~, truelam, ~, J2] = getErrorAndJacobian(sys, data, parinfo, option, true, true);
            J2 = J2(:, 1:npest); % remove initial state var contribution
            [~,r2] = qr(J2,0);
            
            %Covariance := (J1'*J1)\(J2'*J2)/(J1'*J1)
            covChol = J1inv*r2';
            cov = covChol*covChol';
        else
            if isDet || ny==1
                cov = J1inv;
            else
                % Calculate J2 = Psi*W*Lambda*W*Psi'
                % Note: J2'J2 is functionally equivalent to J1'*truelam*J1,
                % but J1 would need to be reshaped to extract per-output
                % contribution (it is easier to compute jacobian again,
                % which is what is implemented).
                
                Wt = option.Weighting;
                option.Weighting = Wt*truelam*Wt;
                [~, ~, ~, J2] = getErrorAndJacobian(sys, data, parinfo, option, true);
                J2 = J2(:, 1:npest);
                %cov =  (J1'*J1)\(J2'*J2)/(J1'*J1);
                [~,r2] = qr(J2,0);
                covChol = J1inv*r2';
                cov = covChol*covChol';
            end
        end

        % apply normalization correction (for nonlinear models)
        cov = cov*Factor;

        if (rcond(cov) < eps*5)
            S.Warning = 'Covariance matrix estimate may be unreliable.';
        end

        covmat(pestind, pestind) = cov;
        covmat = real((covmat'+covmat)/2);
        illCond = ( any(any(~isfinite(cov))) || any(eig(cov)<0) );
    catch E
        fprintf('\nCovariance calculation error: %s\n',E.message)
        illCond = true;
    end

    delete(warn)
    
    if illCond
        % indefinite cov mat -> unreliable computation
        S.Warning = ctrlMsgUtils.message('Ident:estimation:illConditionedCovar2');
        ctrlMsgUtils.warning('Ident:estimation:illConditionedCovar2');
        covmat = [];
    end

    S.CovarianceMatrix = covmat;
end

%% Noise variance
if (~isempty(truelam) && all(isfinite(truelam(:))))
    S.NoiseVariance = truelam*Factor;
end
