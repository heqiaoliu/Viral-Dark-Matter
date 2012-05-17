function closeUndockedDialog(dp_VerticalPanel,dlg)
% Close an undocked dialog, making it a hidden dialog of dp_VerticalPanel.
%
% xxx NOTE: This causes the dialog to briefly render in DPVerticalPanel.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:35 $

if ~isempty(dlg)
    assertDialogListConsistency(dp_VerticalPanel,dlg); % xxx
    
    % Extract DialogPresenter (dp_Single) from Dialog object
    dp_Single = dlg.DialogPresenter;
    old_dialogBorder = dlg.DialogBorder;
    
    dialogContent = dlg.DialogContent;
    detach(dialogContent);
    
    % Make dp_Single invisible until we delete it
    hSingleFig = dp_Single.hFig;
    set(hSingleFig,'vis','off');
    
    % Begin transition from undocked to hidden
    wasOnList = removeFromUndockedList(dp_VerticalPanel,dlg);
    assert(wasOnList);
    
    % Dialog dlg still has the old dialogBorder in it.
    % That old dialogBorder has a listener on the current dialogContent
    % that will fire during createAndRegisterDialog for the NEW dialog.
    %
    % Chain of events:
    %   (a) the dialogContent remains intact,
    %   (b) the OLD dialogBorder still points to this dialogContent,
    %       and has a resize listener on dialogContent.ContentPanel uipanel
    %       that will call dialogBorder.resize()
    %   (c) the dialogContent will reparent its graphical children to the
    %       new dialogBorder panel during the createAndRegisterDialog call
    %   (d) the graphical re-parenting will throw a resize event on the
    %       dialogContent.ContentPanel widget
    %   (e) the old dialogBorder listener callback fires, which calls the
    %       older dialogBorder object resize which attempts to get the
    %       position of the old dialogBorder.Panel widget
    %
    % We cannot DELETE the old dialogBorder yet, because that would delete
    % dialogBorder.Panel, to which the contentDialog widgets are parented.
    % Instead, we keep dialogBorder intact until dialogContent widgets are
    % graphically re-parented in the NEW dialogBorder.
    %
    % We remove the old listener from the old dialogBorder, however.
    % This listener is retained on dialogContent.
    % dialogContent needs to remove this listener.
    detachFromDialogContent(old_dialogBorder);
    
    % Temporarily remove dialog from list of registered dialogs
    %
    % We're going to a register below, which will allocate its own Dialog,
    % and may use its own DBwhatever.  So we can't keep the old Dialog
    % object on the registration list.
    findDlg = dlg.DialogContent.ID == getID(dp_VerticalPanel.Dialogs);
    dp_VerticalPanel.Dialogs(findDlg) = [];
    
    % Two ways to go
    if 1
        % Use whatever DPVerticalPanel wants for a DialogBorder
        % which will be a standard DBTopBar
        %
        % Adds a new dialog to master .Dialogs list
        % Keeps dialog hidden (eg, not placed on .DockedDialogs list)
        createAndRegisterDialog(dp_VerticalPanel,dialogContent);
    else
        % Here we can make whatever DialogBorder we want
        dialogBorder = dialogmgr.DBOffscreen;
        dlg = dialogmgr.Dialog(dialogContent, dialogBorder);
        initialize(dlg,dp_VerticalPanel);
    end
    
    % Can explicitly delete old_dialogBorder now, which deletes the
    % graphical dialogBorder.Panel.
    %
    % Probably unnecessary as dialogBorder gets removed automatically when
    % last reference goes away, and dialogBorder.Panel gets deleted once
    % the old dp_Single figure is deleted below.
    finalize(old_dialogBorder);
    
    % Do NOT setDialogVisibility of newDlg
    % (that would be dockUndockedDialog())
    
    % Close the dp_Single figure
    set(hSingleFig,'CloseReq','');
    delete(hSingleFig);
end

