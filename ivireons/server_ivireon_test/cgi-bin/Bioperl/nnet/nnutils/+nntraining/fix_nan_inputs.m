function [Pc,T] = fix_nan_inputs(net,Pc,Ai,T,Q,TS)

% Copyright 2010 The MathWorks, Inc.


data.Q = Q;
data.TS = TS;
data.P = Pc;
data.Pd = [];
data.Ai = Ai;
fcns = nn.subfcns(net);

Y = nntraining.y_only(net,data,fcns);

% Ensure that NaN inputs are associated with NaN targets
for i=1:numel(Y)
  yi = Y{i};
  T{i}(isnan(yi)) = NaN;
end

% Set NaN inputs to zero for safe gradient calculations
for i=1:numel(Pc)
  pci = Pc{i};
  pci(isnan(pci)) = 0;
  Pc{i} = pci;
end
