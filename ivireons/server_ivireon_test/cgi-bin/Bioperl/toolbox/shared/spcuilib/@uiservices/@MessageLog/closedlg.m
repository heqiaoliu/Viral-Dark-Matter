function closedlg(hMessageLog)
%CLOSEDLG Called when MessageLog dialog closes.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:33 $

% Remove cache of "selected detail"
hMessageLog.cache_SelectedDetail = '';

if ~isempty(hMessageLog.dialog)
    % Retain dialog position when closing,
    % so we can reopen it in same position
    hMessageLog.DialogPosition = hMessageLog.dialog.position; % current position
    hMessageLog.dialog.delete; % close dialog
    hMessageLog.dialog = [];   % clear dialog handle since it is now closed
end

% [EOF]
