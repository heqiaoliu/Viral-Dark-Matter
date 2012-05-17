function perf = perf_only(net,data,fcns)

% Copyright 2010 The MathWorks, Inc.

Y = nntraining.y_only(net,data,fcns);
performFcn = fcns.perform;
perf = performFcn.apply(net,data.T,Y,data.EW,performFcn.param);
