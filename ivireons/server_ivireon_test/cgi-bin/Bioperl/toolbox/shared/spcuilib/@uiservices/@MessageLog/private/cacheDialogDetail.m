function cacheDialogDetail(hMessageLog)
%cacheDialogDetail Cache detail of selected dialog message.
%  Prepends summary info to start of message,
%  such as time stamp.

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2010/01/25 22:48:06 $

% Get 0-based index corresponding to selected row of
% summary listbox in dialog, 0=last, 1=2nd to last, etc
%
% Note: summary list may be "filtered", that is, it may only
% contain SOME of the message (say, only "info", etc)
% The dialog UserData contains the index of each entry which
% corresponds to the full message log list, 0=last, 1=2nd to last, etc
% This will allow us to recall the detail from the proper entry in
% the master (unfiltered) list
%

d = hMessageLog.Dialog;
if isempty(d)
    [~, ~, unfilteredIndices] = getDialogSummaryList(hMessageLog);
else
    unfilteredIndices = d.getUserData('summary');
end

% If there are no shown indices, return early, there is no message to be
% shown.
if isempty(unfilteredIndices) 
    idx = [];
else
    thisFilteredIndex = hMessageLog.SelectedSummary;
    idx = unfilteredIndices(1+thisFilteredIndex);
end

if isempty(idx)
    % Nothing selected - reset detail cache:
    hMessageLog.cache_SelectedDetail = '';
else
    % Get message
    
    hMergedLog = cacheMergedLog(hMessageLog);
    
    % Get idx'th message from end of list
    % (The summary list is in reverse chronological order,
    %  so we count from the end of the list)
    m = getMsgByIdx(hMergedLog,idx);
    
    switch lower(m.Type)
        case 'info', clr='blue';
        case 'warn', clr='orange';
        otherwise, clr='red'; % case 'fail'
    end

    % Formulate "message detail" string
    % This is HTML, and has the format:
    %
    %   [Date] Type:Category
    %   Summary
    %   (horizontal line)
    %   Details
    %
    % The first line is bold, second italic and bold
    %
    % NOTE: For milliseconds, append '.FFF' to date string format below
    header = sprintf(['[%s] %s:%s<br>' ...
                     '<font color=' clr '><b><i>%s</i></b></font><br><hr>'], ...
        datestr(m.Time,'dd-mmm-yyyy HH:MM:SS'), ...
        capital(m.Type),m.Category, ...
        m.Summary);
    str = [header m.Detail];
    
    % Copy this to the "detail cache" of the original message log
    % for property dialog updates:
    hMessageLog.cache_SelectedDetail = str;
end

% -------------------------------------------------------------------------
function m = getMsgByIdx(hMessageLog,idx)
% Return idx'th message from end of list.
%  - idx=0 returns last message,
%  - idx=1 returns 2nd to last message, etc.

m = hMessageLog.down('last');
for i=1:idx % if idx=0, we stay at last msg
    m=m.left;
end

% [EOF]
