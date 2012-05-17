function y = nn_flatten_time_struct(net,x)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

if (x.TS>1) && (net.numLayerDelays == 0) && ...
  ((net.numInputDelays == 0) || net.efficiencyFlags.cacheDelayedInputs) && ...
  (~strcmp(net.trainFcn,'trains'));

  % TODO - replace loop with explicit fieldnames
  fns = fieldnames(x);
  for i=1:length(fns)
    fn = fns{i};
    if strcmp(fn,'Q')
      y.Q = x.Q * x.TS;
    elseif strcmp(fn,'TS')
      y.TS = 1;
    elseif strcmp(fn,'TSunflat')
      y.TSunflat = x.TS;
    elseif strcmp(fn,'name')
      y.name = x.name;
    elseif strcmp(fn,'indices')
      y.indices = x.indices;
    elseif strcmp(fn,'isFlattened')
      y.isFlattened = true;
    else
      y.(fn) = seq2con(x.(fn));
    end
  end
else
  y = x;
end
