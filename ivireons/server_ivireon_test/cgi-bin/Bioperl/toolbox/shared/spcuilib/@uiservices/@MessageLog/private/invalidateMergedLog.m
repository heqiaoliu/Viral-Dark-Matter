function invalidateMergedLog(hMessageLog)
%invalidateMergedLog Invalidate the MergedLog cache by resetting contents.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:54 $

hMessageLog.cache_MergedLog = handle([]);

% [EOF]
