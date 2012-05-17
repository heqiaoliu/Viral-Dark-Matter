function f = findAll(hMessageLog)
%FINDALL Find all messages in message log.
%  findAll(H) finds all messages from log.  

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:38 $

f = find(cacheMergedLog(hMessageLog));

% [EOF]
