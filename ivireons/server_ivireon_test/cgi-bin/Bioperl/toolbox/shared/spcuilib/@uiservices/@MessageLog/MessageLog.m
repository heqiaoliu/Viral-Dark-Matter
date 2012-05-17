function hMessageLog = MessageLog(titlePrefix,hAppInst)
%MessageLog Constructor for uiservices.MessageLog
%  MessageLog(Name,hAppInst) creates a log of MessageInfo items, having a
%  dialog with title Name.  The log is multi-instance managed by
%  DialogBase if hAppInst is a handle.  This instance of the Log will have
%  its dialog named and closed automatically.
%
%  MessageLog(Name) without an hAppInst argument (or with empty hAppInst)
%  creates a log of MessageInfo items with an unmanaged dialog.  That is,
%  the dialog title will not be updated automatically, nor will it be
%  closed automatically when the parent application closes.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:31 $

hMessageLog = uiservices.MessageLog;

% Initialize DialogBase properties
%
% hAppInst:
%   handle -> Managed (Multi-instance log)
%   empty  -> Unmanaged (Non-multi-instance log)
%
if nargin<1, titlePrefix='Message Log'; end
if nargin<2, hAppInst=[]; end
hMessageLog.init(titlePrefix,hAppInst);

% Setup post-set listener on LinkedLogs property
%
% NOTE: There is a set-function that manages listener lists,
% which are needed pre-set time so we can delete old listeners,
% etc.  But we need to manage a listener that listens for post-set,
% so we can force a dialog update after everything is setup.
%
% The event data that will get sent with this event signifies
% that the message did not correspond to a "new message item
% added" event.  Rather, this event is thrown whenever a change to the
% linkedLog property occurs - that is, a new set of linked logs.
%
eventData = uiservices.EventData(hMessageLog,'LogUpdated',hMessageLog);
hMessageLog.listen_prop_LinkedLogs = handle.listener( ...
    hMessageLog, hMessageLog.findprop('LinkedLogs'), ...
    'PropertyPostSet', @(hh,ev)updateForLinkedLog(hMessageLog,eventData));

% [EOF]
