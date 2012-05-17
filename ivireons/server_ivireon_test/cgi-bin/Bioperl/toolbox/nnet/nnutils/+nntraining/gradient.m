function gWB = gradient(net,data,fcns)

% Copyright 2010 The MathWorks, Inc.

fcn = fcns.perform;
gWB_direct = fcn.dperf_dwb(net,data.T,data.Y,data.EW,data.perf,fcn.param);
fcn = fcns.derivFcn;
gWB_indirect = fcn.gradient(net,data,fcns);
gWB = gWB_direct + gWB_indirect;
