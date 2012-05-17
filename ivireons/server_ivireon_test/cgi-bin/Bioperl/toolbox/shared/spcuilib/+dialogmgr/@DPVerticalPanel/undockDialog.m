function undockDialog(dp,dlg)
% Undock dialog from panel.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:32 $

assertDialogListConsistency(dp,dlg); % xxx

% Make sure roller shade is not engaged on docked dialog
% Otherwise, when we copy the dialog size for the undocked dialog, 
% we'll get something unexpectedly short.
disableRollerShadeIfAvailable(dlg);

% Get current position of docked dialog
% xxx this is "panel-local" pos, need "fig-global" pos
currDockedDialogPos = dialogmgr.getAbsoluteHandlePosition( ...
    dlg.DialogBorder.Panel,'screen');

% Close dialog in DPVerticalPanel
% - hides dialog in panel display
% - removes dlg from .DockedDialogs, leaves it on .Dialogs
closeDialog(dp,dlg);

% Separate dialogContent child from its dialogBorder parent
dialogContent = dlg.DialogContent;
detach(dialogContent);

% Temporarily remove dialog from list of registered dialogs
%
% We're going to a DPSingleClient which will allocate its own Dialog, and
% may use its own DBwhatever.  So we can't keep the old Dialog object on
% the registration list.
findDlg = dlg.DialogContent.ID == getID(dp.Dialogs);
dp.Dialogs(findDlg) = [];

% Create a new DPSingleClient DialogPresenter for the standalone dialog,
% and have it be a managed dialog responding to dp.hFig
dp_Single = dialogmgr.DPSingleClient(dp,currDockedDialogPos);
set(dp_Single.hParent,'pos',[1 1 currDockedDialogPos(3:4)]);

% Re-parent dialogContent to this new dialogPresenter/dialogBorder
dlgNew = createAndRegisterDialog(dp_Single,dialogContent);

% Setup close method on new figure
% Have it dock back into primary DPVerticalPanel when it closes
% set(dp_Single.hFig,'CloseRequestFcn', ...
%     @(h,e)dockUndockedDialog(dp,dlgNew));
% Have it be invisible when it closes
set(dp_Single.hFig,'CloseRequestFcn', ...
    @(h,e)closeUndockedDialog(dp,dlgNew));

% Now that dialogContent is re-parented within dp_Single,
% we can delete the Dialog object
% - dlg is no longer being held by anyone
% - method will not delete dialogContent, since it's re-docked
% - the deletion of dialogBorder Panel parent would delete dialogContent
%   widget children if we didn't reparent the child widgets previously,
%   deletion is via finalize() on dialogBorder called within method
finalizeForUndock(dlg);

% Add new dialog to master Dialogs list
% Keep Dialogs list up to date with all Dialogs that are managed
% by DPVerticalPanel (docked or undocked).
dp.Dialogs = [dp.Dialogs dlgNew];

% Add new dialog to undocked list
dp.UndockedDialogs = [dp.UndockedDialogs dlgNew];

% Set visibility of Dialog and DialogPresenter
setVisible(dp_Single.Dialogs);
setVisible(dp_Single);

% If we undocked the last dialog in DialogPanel,
% hide the dialog panel.
if isempty(dp.DockedDialogs)
    setDialogPanelVisible(dp,false);
end

%showDialogPanel(dp);       % Change the visualizer display state
%resetDialogPanelShift(dp);

