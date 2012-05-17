function x = nn_select_samples_struct_separate(x,indices,name)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

x.name = name;
x.Q = length(indices);
x.indices = indices;
x.X = nnfast.getsamples(x.X,indices);
for i=1:numel(x.Pd)
  Pdi = x.Pd{i};
  if ~isempty(Pdi)
    x.Pd{i} = Pdi(:,indices);
  end
end
x.Xi = nnfast.getsamples(x.Xi,indices);
x.Ai = nnfast.getsamples(x.Ai,indices);
x.T = nnfast.getsamples(x.T,indices);
if nnfast.numsamples(x.EW) ~= 1
  x.EW = nnfast.getsamples(x.EW,indices);
end
x.isSeparate = true;
