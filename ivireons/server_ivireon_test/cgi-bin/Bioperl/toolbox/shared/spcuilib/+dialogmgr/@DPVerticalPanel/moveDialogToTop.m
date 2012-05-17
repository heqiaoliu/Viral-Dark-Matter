function moveDialogToTop(dp,thisDlg)
% Move dialog to top of panel.
% Reset dialog panel display shift back to zero (show top of panel).

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:48:59 $

% Get current display order of docked dialogs
% Move this dialog to first entry, if found
visDlgs = dp.DockedDialogs;
findIdx = thisDlg.DialogContent.ID == getID(visDlgs);
if any(findIdx)
    % Remove dialog from where it was
    visDlgs(findIdx) = [];
    
    % Add it to the top of the docked dialog display order
    dp.DockedDialogs = [thisDlg visDlgs];
    
    showDialogPanel(dp); % Rearrange dialogs in display
    resetDialogPanelShift(dp); % Shift panels to top of display
else
    % Internal message to help debugging. Not intended to be user-visible.
    warn(thisDlg,'DialogNotRegistered');
end
