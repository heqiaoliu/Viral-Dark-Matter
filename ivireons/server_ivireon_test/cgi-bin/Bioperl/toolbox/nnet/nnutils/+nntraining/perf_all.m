function [perf,data] = perf_all(net,data,fcns)

% Copyright 2010 The MathWorks, Inc.

data = nntraining.y_all(net,data,fcns);
fcn = fcns.perform;
perf = fcn.apply(net,data.T,data.Y,data.EW,fcn.param);
data.perf = perf;
