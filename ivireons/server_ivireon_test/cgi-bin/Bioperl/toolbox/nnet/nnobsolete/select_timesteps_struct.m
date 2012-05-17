function x = select_timesteps_struct(x,indices,name)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

x.name = name;
% TODO - Dimension expanding NNSET
[N,Q,TS,M] = nnfast.nnsize(x.T);
for i=1:M
  nans = nan(N(i),Q);
  for ts=indices
    x.T{i,ts} = nans;
  end
end
