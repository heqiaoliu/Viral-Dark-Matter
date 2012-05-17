function path = abs2rel(path,root)
%NN_ABS2REL_PATH Convert one or more paths from absolute to relative.

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, root = nnet_root; end

% MULTIPLE
if iscell(path)
  for i=1:length(path)
    path{i} = nnpath.abs2rel(path{i},root);
  end
  return
  
% SINGLE
else
  root = [root filesep];
  rootLength = length(root);

  if length(path) < rootLength
    nnerr.throw('Path is shorter than root path.')
  end
  if any(path(1:rootLength) ~= root)
    nnerr.throw('Path does not have correct root path.');
  end
  path = path((rootLength+1):end);
end
