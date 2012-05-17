function x = nn_select_all_struct(x,indices,name)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

x.name = name;
[T,i,j] = nncell2mat(x.T);
T(indices) = NaN;
x.T = mat2cell(T,i,j);
