function files = mfiles(folder,depth)
%MFILES M-Files nested within a directory.

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, depth = ''; end

files = nnfile.files(folder,depth);
files = nnpath.filter_ext(files,'m');
