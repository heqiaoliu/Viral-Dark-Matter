function err = nncheckp(p,pname)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if nargin < 2, pname = 'P'; end

err = [];

if isnumeric(p)
  if length(size(p)) > 2
    err = [pname ' has more than 2 dimensions.'];
    return;
  end
  return;
end

if iscell(p)
  [R,TS] = size(p);
  for i=1:R
    for j=1:S
      if ~isnumeric(p{i,j}), nnerr.throw([pname ' is not a matrix or cell array of matrices.']); end
      if length(size(p)) > 2, nnerr.throw([pname ' has more than 2 dimensions.']), end
      Q = size(p{1,1},2);
      ri = size(p{i,1});
      if (size(p{i,j},2) ~= Q), nnerr.throw([pname '{1,1} and ' pname '{' num2str(i) ',' num2str(j) '} have different number of columns.']); end
      if (size(p{i,j},1) ~= ri), nnerr.throw([pname '{1,' num2str(j) '} and ' pname '{' num2str(i) ',' num2str(j) '} have different number of rows.']); end
    end
  end
end

err = [pname ' is not a matrix or cell array of matrices.'];
