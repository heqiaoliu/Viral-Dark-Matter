function [perf,data,gB,gIW,gLW,gA,gradient] = perf_sig_grad(net,data,needGradient,fcns)
% Calculate perf,sig,grad from single data

% Copyright 2010 The MathWorks, Inc.

% Performance
[perf,data] = nntraining.perf_all(net,data,fcns);

% Gradient
if needGradient
  gE = cell(net.numLayers,data.TS);
  fcn = fcns.perform;
  gE(net.outputConnect,:) = fcn.dperf_de(net,data.T,data.Y,data.EW,perf,fcn.param);
  [gBy,gIWy,gLWy,gA] = nnprop.grad(net,data.P,data.Pd,data.Zb,data.Zi,data.Zl,data.N,data.Ac,...
    gE,data.Q,data.TS,fcns);
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
% TODO - reverse error calc
data.E = gsubtract(data.T,data.Y);

% TODO - Remove need for these
data.Tl = cell(net.numLayers,data.TS);
data.Tl(net.outputConnect,:) = data.T;
data.El = cell(net.numLayers,data.TS);
data.El(net.outputConnect,:) = data.E;

