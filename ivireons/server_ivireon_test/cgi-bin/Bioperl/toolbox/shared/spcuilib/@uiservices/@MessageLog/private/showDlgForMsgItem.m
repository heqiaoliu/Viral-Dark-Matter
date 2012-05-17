function showDlgForMsgItem(hMessageLog,msgType)
%showDlgForMsgItem Open dialog, based on MessageItem type and AutoOpenMode.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:55 $

dlgAlreadyOpen = ~isempty(hMessageLog.dialog) && ishandle(hMessageLog.dialog);

if dlgAlreadyOpen
    doShow = true;
else
    % Determine whether to automatically open the Message Log dialog
    % in response to the newly added message
    %
    % .Type: 'info','warn','fail'
    %    mt:   1      2      3  (Message Type: index)
    mt = strmatch(msgType,{'info','warn','fail'}); % 1-based
    %    ao: 1=all, 2=warn/fail, 3=fail, 4=never  (Auto-Open: enum)
    ao = strmatch(hMessageLog.AutoOpenMode,...
        {'for any new messages', ...
        'for warn/fail messages', ...
        'only for fail messages', ...
        'manually'});

    % Should we open new (or update existing) dialog?
    doShow = (ao==1) || ((ao==2)&&(mt>1)) || ((ao==3)&&(mt==3));
end

if doShow
    % Open dialog if not already open
    % Force update to dialog if it is already open
    show(hMessageLog);
end

% [EOF]
