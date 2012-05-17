function add(hMsgLog,varargin)
%ADD Add message to message log.
%   ADD(H,MSG) adds a message MSG which is a uiservices.MessageItem object.
%   ADD(H,Type,Category,Summary,Details) creates a MessageItem using the
%     string arguments and adds it to the MessageLog.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/17 22:43:38 $

if ischar(varargin{1})
    % Assume one or more string args for MessageItem
    hMsgItem = uiservices.MessageItem(varargin{:});
elseif (nargin==2) && isa(varargin{1},'uiservices.MessageItem')
    % MessageItem passed
    hMsgItem = varargin{1};
else
   error(generatemsgid('InvalidArgs'),'Invalid input arguments');
end

% Invalidate MergedLog cache, since we've just added another
% item to our own log.  (Next time someone wants the cache,
% it'll rebuild itself.)  Do this before connect-ing to the
% new item, to keep cache sync'd as continuously as possible.
% At the very least, we must do this before updating our own
% dialog, since it will want to access the cache.
%
invalidateMergedLog(hMsgLog);

% Connect message as a new child
% h is 'up' from m, must keep new object (m) as 1st arg
connect(hMsgItem,hMsgLog,'up');

% Open dialog, based on message type
showDlgForMsgItem(hMsgLog,hMsgItem.Type);

% Send event in case someone else is watching our list (such as if we're a
% LinkedLog), passing hMsgItem so recipient can react accordingly.
ev = uiservices.EventData(hMsgLog,'LogUpdated',hMsgItem);
send(hMsgLog,'LogUpdated',ev);

% [EOF]
