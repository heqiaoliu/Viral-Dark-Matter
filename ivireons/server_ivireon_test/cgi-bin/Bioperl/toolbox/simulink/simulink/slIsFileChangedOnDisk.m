function changed = slIsFileChangedOnDisk(sys)
%SLISFILECHANGEDONDISK - Determines whether a file has changed since it was loaded
%   changed = slIsFileChangedOnDisk(sys)
% Returns true if the file which contains block diagram "sys" was changed on
% disk since the block diagram was loaded.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $

h = bdroot(sys);
changed = slInternal('getMdlFileState',h);
