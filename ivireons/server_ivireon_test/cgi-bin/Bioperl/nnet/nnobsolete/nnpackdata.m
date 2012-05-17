function [d,mode] = nnpackdata(d)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if isnumeric(d)
  d = {d};
  mode = 0;
elseif iscell(d)
  mode = 1;
else
  d = []
  mode = -1;
end
