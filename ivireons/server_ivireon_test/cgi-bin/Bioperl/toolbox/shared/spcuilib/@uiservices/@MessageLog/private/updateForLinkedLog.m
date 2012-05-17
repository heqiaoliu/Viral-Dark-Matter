function updateForLinkedLog(hMessageLog,eventData)
%updateForLinkedLog Update message log dialog, if open, due to change
%  in a LinkedLog.  Two types of changes:
%   - content of an (external) linked log changed
%     (we're listening to change events on each linked log)
%   - list of LinkedLogs (held by this log) changed
%     (we're listening to our own property for changes)
%
% It is assumed that a set-function on LinkedLogs property is
% handling changes to the list of listeners on other LinkedLogs.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/12/04 23:20:22 $

% Main need: clear MergedLog cache so it will get rebuilt on-demand
invalidateMergedLog(hMessageLog);

if ~isempty(eventData)
    % eventData passed - either an item was added, or a log was
    % linked/unlinked
    
    % Get the data that cause a linked log to call us
    linkedLogData = eventData.Data;

    if isa(linkedLogData, 'uiservices.MessageItem')
        % A new message item was added to a linked log
        %
        % Open (or update existing) dialog depending on message type
        % linkedLogData is a hMessageItem
        changeInItem(hMessageLog,linkedLogData);
    else
        % A change to a LinkedLogs property occurred, either to this
        % MessageLog, or a linked MessageLog.
        % (This is not a reaction to a newly added MsgItem.)
        %
        % Open (or update existing) dialog depending on content of linked (merged) log
        % linkedLogData is a hMessageLog
        changeInLog(hMessageLog,linkedLogData);
    end
else
    % Empty eventData - one or more items were removed from a log
    % (this log, or a linked log)
    %
    % Pretend this was a change in our LinkedLog
    % We just want the display to update if already open
    removalFromLog(hMessageLog);
end

% Propagate the event:
send(hMessageLog,'LogUpdated',eventData);

%%
function changeInItem(hMsgLog,hMsgItem_added)
% An item was added to a log
% Either to this log, or to a linked log

% Open (or update existing) dialog depending on message type
showDlgForMsgItem(hMsgLog, hMsgItem_added.Type);

%%
function changeInLog(hMsgLog_this, hMsgLog_changed)
% A log-wide change occurred
% (Either the LinkedLog list of this log changed,
%  or the LinkedLog list of a linked log changed)

%   if a 2nd log is populated with, say, Fail messages prior to it being
%   linked to this 1st log, and the 1st log's dialog is NOT open, and then
%   the 2nd log gets linked to the 1st log, the 1st log should open its
%   dialog (based on AutoOpenMode).  We catch these cases and scan the logs
%   for msg types.
%
%   Note that we DO catch newly-added messages to linked logs (and to our
%   own log, too, of course!)  Those will cause our log to open as
%   expected (according to the AutoOpenMode rules) in changeInItem() above.
%
%   It is more efficient to add empty logs, then populate them with add().
%   It takes time to add an entire log, as we must scan it all at once.

% Scan log for "highest" message type: Fail > Warn > Info
showDlgForMsgLog(hMsgLog_this, hMsgLog_changed);

%%
function removalFromLog(hMessageLog)
% A remove operation from a log occurred
% Just update dialog if it is open

dlgAlreadyOpen = ~isempty(hMessageLog.dialog) && ishandle(hMessageLog.dialog);
if dlgAlreadyOpen
    % Open dialog if not already open
    % Force update to dialog if it is already open
    show(hMessageLog);
end

% [EOF]
