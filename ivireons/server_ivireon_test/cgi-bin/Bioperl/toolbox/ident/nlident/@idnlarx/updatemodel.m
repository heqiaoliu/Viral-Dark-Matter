function sys = updatemodel(sys, OptimInfo, Estimator)
%UPDATEMODEL  Update various properties of sys after estimation.
% Update parameters, initial states, noise variance and covariance, as well
% as estimation info.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/04/28 03:22:53 $

% Author(s): Qinghua Zhang, Rajiv Singh.


x = OptimInfo.X;
% lim = Estimator.Options.LimitError;
Estimator.Info.Value = x; %have estimator carry the updated parameters
parinfo = Estimator.Info;

sys = setParameterVector(sys, x);

% Update NoiseVariance
z = Estimator.Data;

np = numel(getParameterVector(sys)); %number of true parameters of model
npest = np;
pestind = 1:np;

% Get EstimationInfo
estinfo = pvget(sys,'EstimationInfo');
S = utGetModelQualityInfo(sys,z,np,npest,pestind,parinfo,Estimator.Options);

sys = pvset(sys,'NoiseVariance',S.NoiseVariance,'CovarianceMatrix',S.CovarianceMatrix);

% Set EstimationInfo
algo = pvget(sys, 'Algorithm');
estinfo.Method = sprintf('PEM using SearchMethod = %s',algo.SearchMethod);
estinfo.Status = 'Estimated model (PEM)';
estinfo.LossFcn = S.LossFcn;
estinfo.FPE = S.FPE;
estinfo.DataName = pvget(z, 'Name');
estinfo.DataLength = sum(Estimator.Options.DataSize);
estinfo.DataTs = z.Ts;
estinfo.DataDomain = z.Domain;
estinfo.DataInterSample = pvget(z,'InterSample');
estinfo.WhyStop = Estimator.whyStop(OptimInfo.ExitFlag);
estinfo.Iterations = OptimInfo.Output.iterations;
estinfo.Warning = S.Warning;
if ~strcmpi(algo.SearchMethod,'lsqnonlin')
    % these quantities are not available when using Optim toolbox (lsqnonlin) 
    estinfo.LastImprovement = OptimInfo.Output.LastImprovement;
    estinfo.UpdateNorm = OptimInfo.Output.UpdateNorm;
end

sys = pvset(sys,'EstimationInfo',estinfo);

% FILE END

