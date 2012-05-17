function split = split_data(data,indices)

% Copyright 2010 The MathWorks, Inc.

if isempty(data.P)
  split.P = [];
else
  split.P = nnfast.getsamples(data.P,indices);
end
if isempty(data.Pd)
  split.Pd = [];
else
  split.Pd = nnfast.getsamples(data.Pd,indices);
end
split.Ai = nnfast.getsamples(data.Ai,indices);
split.T = nnfast.getsamples(data.T,indices);
if nnfast.numsamples(data.EW) == 1
  split.EW = data.EW;
else
  split.EW = nnfast.getsamples(data.EW,indices);
end
if islogical(indices)
  split.Q = sum(indices);
else
  split.Q = length(indices);
end
split.TS = data.TS;

split.train.masked = data.train.masked;
if split.train.masked
  split.train.mask = nnfast.getsamples(data.train.mask,indices);
end
split.val.enabled = data.val.enabled;
if split.val.enabled
  split.val.mask = nnfast.getsamples(data.val.mask,indices);
end
split.test.enabled = data.test.enabled;
if split.test.enabled
  split.test.mask = nnfast.getsamples(data.test.mask,indices);
end
