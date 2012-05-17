function [perf,vperf,tperf,trainData,gB,gIW,gLW,gA,gradient] = ...
  perfs_sig_grad(net,trainData,valData,testData,needGradient,fcns)

% Copyright 2009-2010 The MathWorks, Inc.

% Performances
% TODO - Calculate perfs together
[perf,trainData] = nntraining.perf_all(net,trainData,fcns);
if ~isempty(valData)
  vperf = nntraining.perf_only(net,valData,fcns);
else
  vperf = NaN;
end
if ~isempty(testData)
  tperf = nntraining.perf_only(net,testData,fcns);
else
  tperf = NaN;
end

% Gradient
if needGradient
  gE = cell(net.numLayers,trainData.TS);
  fcn = fcns.perform;
  gE(net.outputConnect,:) = fcn.dperf_de(...
    net,trainData.T,trainData.Y,trainData.EW,perf,fcn.param);
  [gBy,gIWy,gLWy,gA] = nnprop.grad(net,trainData.P,trainData.Pd,...
    trainData.Zb,trainData.Zi,trainData.Zl,trainData.N,trainData.Ac,...
    gE,trainData.Q,trainData.TS,fcns);
  gWBy = formwb(net,gBy,gIWy,gLWy);
  gWBwb = fcn.dperf_dwb(net,fcn.param);
  gWB = gWBy + gWBwb;
  [gB,gIW,gLW] = separatewb(net,gWB);
  gradient= sqrt(sum(sum(gWB.^2)));
else
  gB = cell(net.numLayers,1);
  gIW = cell(net.numLayers,net.numInputs);
  gLW = cell(net.numLayers,net.numLayers);
  gA = cell(net.numLayers,1);
  gradient = NaN;
end

% Error
% TODO - support error modes
trainData.E = gsubtract(trainData.T,trainData.Y);

% TODO - Remove need for these
trainData.Tl = cell(net.numLayers,trainData.TS);
trainData.Tl(net.outputConnect,:) = trainData.T;
trainData.El = cell(net.numLayers,trainData.TS);
trainData.El(net.outputConnect,:) = trainData.E;

