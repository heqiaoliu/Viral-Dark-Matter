function Pd = nn_cache_delayed_inputs(net,Pc)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

if net.efficiency.cacheDelayedInputs
  Pd = nnsim.pd(net,Pc);
else
  Pd = Pc;
end
