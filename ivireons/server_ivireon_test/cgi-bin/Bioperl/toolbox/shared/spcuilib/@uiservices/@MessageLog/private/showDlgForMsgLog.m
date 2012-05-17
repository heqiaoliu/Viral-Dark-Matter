function showDlgForMsgLog(hMsgLog_this, hMsgLog_changed)
%showDlgForMsgLog Open dialog, based on content of MessageLog and AutoOpenMode.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:56 $

dlgAlreadyOpen = ~isempty(hMsgLog_this.dialog) && ishandle(hMsgLog_this.dialog);

if dlgAlreadyOpen
    doShow = true;
else
    % Determine whether to automatically open the Message Log dialog
    % in response to the newly added message
    %
    %    ao: 1=all, 2=warn/fail, 3=fail, 4=never  (Auto-Open: enum)\
    ao = strmatch(hMsgLog_this.AutoOpenMode,...
        {'for any new messages', ...
        'for warn/fail messages', ...
        'only for fail messages', ...
        'manually'});
    
    if ao==4
        % manual - no need to scan, we are never going to open the dialog
        doShow = false;
        
    else
        % An aspect of efficiency: only need the linked log's MergedLog,
        % not ours.  Ours will be of greater/equal length, so this is more
        % efficient in general.  We only need to scan the (newly
        % linked) log, not ours.  (We've caught all incremental add's all
        % along...)
        hMergedLog = cacheMergedLog(hMsgLog_changed);

        if ao==1
            % any new messages - just see if there any any at all
            % if so, we open the dialog
            doShow = iterator.numImmediateChildren(hMergedLog)>0;
            
        else
            % Open on Fail or Warn/Fail messages
            % Scan all messages for Types
            %
            allTypes = iterator.visitImmediateChildren(hMergedLog, @(hItem)hItem.Type);

            % Should we open new (or update existing) dialog?
            % Straightforward is:
            %   anyFail = ~isempty(strmatch('fail',allTypes));
            %   anyWarn = ~isempty(strmatch('warn',allTypes));
            %   doShow = ((ao==2)&&(anyWarn||anyFail)) || ((ao==3)&&anyFail);
            % But at this point, we guarantee ao is either 2 or 3 
            % That means, find Fail for sure, maybe find Warn
            %
            % Only do the minimum "strmatch" work for what we need:
            doShow =             ~isempty(strmatch('fail',allTypes)) || ...
                    ( (ao==2) && ~isempty(strmatch('warn',allTypes))  );
        end
    end
end

if doShow
    % Open dialog if not already open
    % Force update to dialog if it is already open
    show(hMsgLog_this);
end

% [EOF]
