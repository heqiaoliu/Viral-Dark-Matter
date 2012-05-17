function paths =nnet_toolbox_files(root,paths)

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, root = nnpath.nnet_root; end
if nargin < 2, paths = {}; end

paths = subfunction(fullfile(root,'toolbox','nnet'),paths);
paths = sort(paths);

function paths = subfunction(root,paths)

files = dir(root);
for i=3:length(files)
  name = files(i).name;
  if files(i).isdir
    if strcmpi(name,'demosearch'), continue, end
    if strcmpi(name,'html'),continue,  end
    if strcmpi(name,'ja'), continue, end
    if strcmpi(name,'cvs'), continue, end
    if strcmpi(name,'demosearch'), continue, end
    paths = subfunction([root filesep name],paths);
  else
    if strcmp(name,'Thumbs.db'), continue, end % DELETE IN CLEANUP
    if strcmp(name,'Contents.m'), continue, end
    if strendswith(name,'.asv'), continue, end
    if strstartswith(name,'.'), continue, end
    paths = [paths; {[root filesep name]}];
  end
end
