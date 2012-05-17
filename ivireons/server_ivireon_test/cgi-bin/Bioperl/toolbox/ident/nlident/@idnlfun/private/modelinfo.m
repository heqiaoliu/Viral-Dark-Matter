function [estinfo, nv, covmat] = modelinfo(nlobj, data, option, covmat)
%MODELINFO get model information for non iteratively estimated model
%This function replaces updatemodel in absence of iterative estimation.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/12/14 14:47:49 $

% Author(s): Qinghua Zhang

Nobs = size(data{1}{1},1);

np = length(getParameterVector(nlobj));
ny = numel(nlobj);
npest = np;
nfreedom = max(1, Nobs-npest);

diffnlflag = isdifferentiable(nlobj);

if diffnlflag
  parinfo.Value = getParameterVector(nlobj);
  lim = option.LimitError;
  option.LimitError = 0; % this would corrupt cost value, but we do not need it here
  %option.doSqrlam = true;
  option.Criterion = 'det';
  [cost, truelam] = getErrorAndJacobian(nlobj, data, parinfo, option, false);
  % Note: doJacobian=false is used because CovarianceMatrix is not estimated.
  % doJacobian will be changed to true when CovarianceMatrix is estimated.
  option.LimitError = lim;
  
else
  % compute nv
  e = evaluate(nlobj, data{2}) - cell2mat(data{1}(:)');
  truelam = e'*e / Nobs;
end

V = real(abs(det(truelam)));

FPE = [];
if ~isempty(truelam) && all(isfinite(truelam(:))) %&& Nobs-npest/ny>=1
  nv = truelam*Nobs/nfreedom;
  
  if diffnlflag
    FPE =  (1+2*npest/Nobs)*V; %((Nobs+npest/ny)/(Nobs-npest/ny))*V;
  end
else
  nv = [];
end

% Covariance matrix is not implemented in this version.
covmat = [];

warnmsg = [];

% Set EstimationInfo
%estinfo.Status = 'Estimated model (PEM)';
%estinfo.Method = [];

estinfo.LossFcn = V;
estinfo.FPE = FPE;
estinfo.DataName = [];
estinfo.DataLength = Nobs;
estinfo.DataTs = [];
estinfo.DataDomain = 'time';
estinfo.DataInterSample = {'zoh'};
estinfo.WhyStop = [];
estinfo.Iterations = 0;
estinfo.Warning = warnmsg;

% FILE END
