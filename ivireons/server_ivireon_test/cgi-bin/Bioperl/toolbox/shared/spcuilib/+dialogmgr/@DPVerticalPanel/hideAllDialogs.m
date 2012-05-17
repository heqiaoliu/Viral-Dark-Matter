function hideAllDialogs(dp)
% Close all open dialogs
% Close main panel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $   $Date: 2010/04/21 21:48:56 $

% Close docked dialogs by removing them from dialog list
dp.DockedDialogs = dialogmgr.Dialog.empty;
showDialogPanel(dp); % Change the visualizer display state

% Close undocked dialogs
warnID = 'Spcuilib:dialogmgr:CloseUndockedDialogs';
warning(warnID, DAStudio.message(warnID));

