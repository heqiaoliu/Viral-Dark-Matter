function toggleDockedDialogVisibility(dp,dlg)
% Toggle between showing and hiding a docked dialog.
% After the state change is made, the display state is updated.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:30 $

% To toggle the dialog visibility, we add or remove dialog
% from the DockedDialogs list

thisID = dlg.DialogContent.ID;

dockIdx = find(thisID == getID(dp.DockedDialogs));
if ~isempty(dockIdx)
    % dialog is docked
    % make it hidden
    dp.DockedDialogs(dockIdx) = [];
    showDialogPanel(dp);  % Change the display state
    % If we un-docked the last docked dialog in DialogPanel,
    % hide the dialog panel.
    if isempty(dp.DockedDialogs)
        setDialogPanelVisible(dp,false);
    end
    return % EARLY EXIT
end

if any(thisID == getID(dp.UndockedDialogs))
    % dialog is un-docked
    % make it hidden
    closeUndockedDialog(dp,dlg);
    return % EARLY EXIT
end

% dialog is hidden
% make it docked
setDialogVisibility(dp,dlg,true)

% If dialog panel is not visible, make it visible
if ~dp.PanelVisible
    setDialogPanelVisible(dp,true);
end

% Slide DPVerticalPanel panel to bottom, so it shows
% the re-docked dialog
shiftViewToBottom(dp);


