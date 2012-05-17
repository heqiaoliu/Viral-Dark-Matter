function dockUndockedDialog(dp_VerticalPanel,dlg)
% Dock a currently un-docked dialog.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $   $Date: 2010/05/20 03:07:29 $

% When docking, the call is received from the close request on a
% DPSingleClient. DPSingleClient has only one dialog, so we retrieve it
% directly from its dialog list.

% First, make sure dp_VerticalPanel is still valid
% It could be invalid if, for example, dp_VerticalPanel closed first, 
% then dp_Single begins to close in response to it.  In this situation,
% dp_Single is still open, but dp_VerticalPanel is no longer a valid
% handle.
if ~isvalid(dp_VerticalPanel)
    return % EARLY EXIT
end

if ~isempty(dlg)
    % Program flow here closely follows closeUndockedDialogs()
    % See more detailed comments there.
    %
    % dlg is the un-docked dialog
    
    % Extract DialogPresenter (dp_Single) from Dialog object
    dp_Single = dlg.DialogPresenter;
    old_dialogBorder = dlg.DialogBorder;
    
    dialogContent = dlg.DialogContent;
    detach(dialogContent);
    
    % Make dp_Single invisible until we delete it
    hSingleFig = dp_Single.hFig;
    set(hSingleFig,'vis','off');
    
    % Make this a docked dialog of dp_VerticalPanel
    % This will re-parent the dialogContent to dp_VerticalPanel,
    % un-attaching it from dp_Single
    
    % Remove dlg from UndockedDialogs and Dialogs registration lists
    % prior to call to createAndRegisterDialog()
    wasOnList = removeFromUndockedList(dp_VerticalPanel,dlg);
    assert(wasOnList);
    wasOnList = removeFromDialogsList(dp_VerticalPanel,dlg);
    assert(wasOnList);
    
    detachFromDialogContent(old_dialogBorder);
    
    % Make this a docked dialog of dp_VerticalPanel
    % This re-parents the dialogContent to dp_VerticalPanel,
    % un-attaching it from dp_Single
    newDlg = createAndRegisterDialog(dp_VerticalPanel,dialogContent);

    % Close the dp_Single figure
    set(hSingleFig,'CloseReq','');
    delete(hSingleFig);
    
    % If dialog panel is not visible, make it visible
    if ~dp_VerticalPanel.PanelVisible
        setDialogPanelVisible(dp_VerticalPanel,true);
    end
    setDialogVisibility(dp_VerticalPanel,newDlg,true);
    
    % Slide DPVerticalPanel panel to bottom, so it shows
    % the re-docked dialog
    shiftViewToBottom(dp_VerticalPanel);
end

