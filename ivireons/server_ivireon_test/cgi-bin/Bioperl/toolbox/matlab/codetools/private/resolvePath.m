function [fullFile,toDelete] = resolvePath(base,src)
%resolvePath Resolve absolute paths, relative paths, and URLs.
%   [fullFile,toDelete] = resolvePath(base,src)

% Matthew J. Simoneau
% $Revision: 1.1.6.1 $  $Date: 2010/01/25 21:42:07 $
% Copyright 1984-2010 The MathWorks, Inc.

if regexp(src,'^(https?|ftp):')
    fullFile = tempname;
    urlwrite(src,fullFile);
    toDelete = fullFile;
else
    fileSrc = java.io.File(src);
    if fileSrc.isAbsolute
        fullFile = src;
    else
        fullFile = fullfile(fileparts(base),src);
    end
    toDelete = [];
end