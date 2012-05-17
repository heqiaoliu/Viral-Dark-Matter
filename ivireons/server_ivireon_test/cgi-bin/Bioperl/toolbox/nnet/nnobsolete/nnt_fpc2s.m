function s = nnt_fpc2s(c,pd)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

f = fieldnames(pd);
s = struct;
for i=1:length(f)
  s=setfield(s,f{i},c{i});
end

