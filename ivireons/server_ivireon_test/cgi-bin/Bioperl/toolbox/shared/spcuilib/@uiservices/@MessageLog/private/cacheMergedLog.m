function hMergedLog = cacheMergedLog(hMessageLog)
%cacheMergedLog Update cache for MessageLog.
%   Returns cache of MergedLog, creating it if needed.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:49 $

if isempty(hMessageLog.LinkedLogs)
    % If there are no linked logs, pass back handle to self
    hMergedLog = hMessageLog;
    
    % NOTE:
    % The list of messages in any one log are in the order in
    % which they were added, which means they are inherently
    % in time-stamp order as well.  No additional sorting needed.
    %
    % NOTE:
    % .cache_MergedLog gets cleared if LinkedLogs is changed in
    % any way (including reset), so there's no need for any checking or
    % clearing of the cache here.

elseif ~isempty(hMessageLog.cache_MergedLog)
    % Grab current MergedLog from cache and quickly return:
    hMergedLog = hMessageLog.cache_MergedLog;
    
else
    % Must rebuild MergedLog cache
    
    % Create a new MessageLog and add to it:
    % - children of current hMessageLog
    % - children of each MessageLog in each of the LinkedLogs
    %
    % Copy current MessageLog, including children, doing a "deep-copy"
    % of each item.  Connect-ed children demand a deep copy, otherwise
    % they will be disconnected from their parent log when we link
    % them here.

    % All parent log properties can be ignored
    hMergedLog = uiservices.MessageLog;
    
    % Prevent dialog from coming up
    hMergedLog.AutoOpenMode = 'manually';
    
    % Deep-copy and add all child MessageItem's from parent
    iterator.visitImmediateChildren( hMessageLog, ...
        @(hChild)add(hMergedLog,copy(hChild)));
    
    % Add all children from LinkedLogs via their MergedLog cache
    %
    % NOTES:
    %   - must ask each linked log to create its own merged log,
    %     so we properly handle an arbitrary depth of linking
    %   - still need a deep copy for each item, since the merged log itself
    %     is a connect-ed set of items, and we do not wish to destroy
    %     the cache from each of these logs.
    %
    for i = 1:numel(hMessageLog.LinkedLogs)
        iterator.visitImmediateChildren( ...
            cacheMergedLog(hMessageLog.LinkedLogs(i)), ...
            @(hChild)add(hMergedLog,copy(hChild)));
    end
    
    % Sort the merged log in terms of time stamps
    %
    time_stamps = iterator.visitImmediateChildren( ...
        hMergedLog, @(hChild)hChild.Time);
    [timeVal,timeIdx] = sort([time_stamps{:}]);
    outOfOrder = any(diff(timeIdx)-1);  % any non-zero difference?
    if outOfOrder
        % Easiest approach: (we do this)
        %   - reorder all entries
        % Better: (not done here)
        %   - make minimum disconnect/reconnects
        
        % Return each child in current order, in separate cells
        eachChild = iterator.visitImmediateChildren(hMergedLog, @(hChild)hChild);
        eachChild = eachChild(timeIdx);  % reorder according to sort
        % Disconnect each child from parent (and thus, from each other)
        % (We must hold on to them or we'll lose them!)
        for i=1:numel(eachChild)
            disconnect(eachChild{i});
        end
        % Reconnect each to parent log, in order
        for i=1:numel(eachChild)
            connect(eachChild{i},hMergedLog,'up');
        end
    end
    
    % Cache the merged log:
    hMessageLog.cache_MergedLog = hMergedLog;
end

% [EOF]
