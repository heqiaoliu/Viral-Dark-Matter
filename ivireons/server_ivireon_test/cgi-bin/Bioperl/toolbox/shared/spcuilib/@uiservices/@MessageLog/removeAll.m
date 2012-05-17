function hMessageLog = removeAll(hMessageLog)
%REMOVEALL Remove all messages from message log.
%  removeAll(H) removes all messages from log.
%  Does not affect linked logs.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:43 $

% Changing child items (including removing them) invalidates
% the MergedLog cache:
invalidateMergedLog(hMessageLog);

% Removes all children from hMessageLog
iterator.removeChildren(hMessageLog);

% Send event in case someone else is watching our list
% (such as if we're a LinkedLog)
send(hMessageLog,'LogUpdated');

% [EOF]
