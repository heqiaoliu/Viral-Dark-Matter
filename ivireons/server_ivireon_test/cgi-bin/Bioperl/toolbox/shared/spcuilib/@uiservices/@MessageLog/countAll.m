function y = countAll(hMessageLog, countLinkedLogs)
%COUNTALL Total number of messages in log.
%   COUNTALL(H,LINKED) counts the number of messages in message log
%   and any linked logs if LINKED is TRUE or if it is omitted.  If
%   FALSE, returns only the messages in this log, ignoring linked logs.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:34 $

% set default value for countLinkedLogs
if (nargin<2)
    countLinkedLogs = true;
end

% If countLinkedLogs
if (nargin<3) && countLinkedLogs
    hMessageLog = cacheMergedLog(hMessageLog);
end
y = iterator.numImmediateChildren(hMessageLog);

% [EOF]
