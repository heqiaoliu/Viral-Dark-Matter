function x = nn_select_samples_struct(x,indices,name)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

x.name = name;
x.indices = indices;
% TODO - Dimension expanding NNSET
[N,Q,TS,M] = nnfast.nnsize(x.T);
for i=1:M
  for ts=1:TS
    x.T{i,ts}(:,indices) = NaN;
  end
end
