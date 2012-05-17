function [nlobj, S, estinfo] = updatemodel(nlobj, OptimInfo, Estimator, algo, covmat)
%UPDATEMODEL  Update various properties of nlobj after estimation.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/06/13 15:23:23 $

% Author(s): Qinghua Zhang

parinfo = Estimator.Info;
x = OptimInfo.X;
% lim = Estimator.Options.LimitError;
Estimator.Info.Value = x; %have estimator carry the updated parameters

nlobj = setParameterVector(nlobj, x);

% Update NoiseVariance
z = Estimator.Data;

np = numel(getParameterVector(nlobj)); %number of true parameters of model
npest = np;
pestind = 1:np;

% Get EstimationInfo
% estinfo = pvget(nlobj,'EstimationInfo');
S = GetModelQualityInfo(nlobj,z,np,npest,pestind,parinfo,Estimator.Options, covmat);

% Set EstimationInfo
estinfo.Status = 'Estimated model (PEM)';
estinfo.Method = sprintf('PEM using SearchMethod = %s',algo.SearchMethod);
estinfo.LossFcn = S.LossFcn;
estinfo.FPE = S.FPE;
estinfo.DataName = [];
estinfo.DataLength = sum(Estimator.Options.DataSize);
estinfo.DataTs = [];
estinfo.DataDomain = 'time';
estinfo.DataInterSample = {'zoh'};
estinfo.WhyStop = Estimator.whyStop(OptimInfo.ExitFlag);
estinfo.Iterations = OptimInfo.Output.iterations;
estinfo.Warning = S.Warning;
if ~strcmpi(algo.SearchMethod,'lsqnonlin')
    % these quantities are not available when using Optim toolbox (lsqnonlin) 
    estinfo.LastImprovement = OptimInfo.Output.LastImprovement;
    estinfo.UpdateNorm = OptimInfo.Output.UpdateNorm;
end

%===================================================
function S = GetModelQualityInfo(nlobj, data, np, npest, pestind, parinfo, option, covmat)
%GETMODELQUALITYINFO  Return a struct containing: NoiseVariance, LossFcn, CovarianceMatrix, FPE, and Warning.
%
%This function is adapted from idutils/utGetModelQualityInfo
%
%   Inputs:
%       nlobj:    model whose quality is being obtained.
%       data:     data used to assess the quality.
%       np:       total number of model parameters.
%       npest:    total number of free parameters (Fixed=false).
%       pestind:  indices of free parameters in a tall vector of all
%                 parameters.
%       parinfo:  struct containing parameter values and their bounds (see
%                 obj2var).
%       option:   information about estimation procedure.

% Create output structure.
S = struct('NoiseVariance', [], 'LossFcn', [], 'CovarianceMatrix', [], 'FPE', [], 'Warning','');

lim = option.LimitError;
option.LimitError = 0; % this would corrupt cost value, but we do not need it here
%option.doSqrlam = true;
%option.Criterion = 'det';
[cost, truelam] = getErrorAndJacobian(nlobj, data, parinfo, option, false);
% Note: doJacobian=false is used because CovarianceMatrix is not estimated.
% doJacobian will be changed to true when CovarianceMatrix is estimated.
option.LimitError = lim;

n = option.DataSize;
Nobs = sum(n);
%ny = numel(nlobj);

V = real(abs(det(truelam)));
S.LossFcn = V;

Factor = Nobs/max(1, Nobs-npest);

if ~isempty(truelam) && all(isfinite(truelam(:)))
  S.NoiseVariance = truelam*Factor;
  S.FPE = (1+2*npest/Nobs)*V;
end

% Covariance matrix is not implemented in this version.

% FILE END
