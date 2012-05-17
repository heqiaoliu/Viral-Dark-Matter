function setDialogVisibility(dp,dlg,newVis)
% Set visibility of specified dialog.
% If newVis is true or omitted, dialog becomes docked.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:21 $

% When changing visibility, we manage .DockedDialogs and .UndockedDialogs
% lists.  This method does NOT change the .Dialogs base class registration
% list.

assertDialogListConsistency(dp,dlg); % xxx

% Find dialog in Docked and Undocked dialog lists
dlgID = dlg.DialogContent.ID;
dockIdx = find(dlgID == getID(dp.DockedDialogs));
currDocked = ~isempty(dockIdx);
undockIdx = find(dlgID == getID(dp.UndockedDialogs));
currUndocked = ~isempty(undockIdx);
currVis = currDocked || currUndocked; % Is dialog currently visible?

if currVis && ~newVis
    % Make dialog hidden
    if currDocked
        % close docked dialog
        dp.DockedDialogs(dockIdx) = [];
        showDialogPanel(dp); % Update display of docked dialogs
        
        % If we undocked the last docked dialog in DialogPanel,
        % hide the dialog panel.
        % Don't waste time in this call unless we're closing the panel
        if isempty(dp.DockedDialogs)
            setDialogPanelVisible(dp,false);
        end
    else
        % close undocked dialog
        %removeFromUndockedList(dp,dlg); % not called, just for symmetry
        dp.UndockedDialogs(undockIdx) = [];
        % Close the dp_Single figure
        hSingleFig = dp_Single.hFig;
        set(hSingleFig,'CloseReq','');
        delete(hSingleFig);
    end
    
elseif ~currVis && newVis
    % Make dialog visible
    % The only option we pursue here is to make the dialog docked
    % (We do NOT make the dialog undocked)

    % Dialog content found in registration list content
    % We can safely add it to the docked list
    dp.DockedDialogs = [dp.DockedDialogs dlg];
    showDialogPanel(dp); % Update display of docked dialogs

    % Shift view to bottom
    %drawnow; % must force update before scroll-bar
    %setPanelViewFraction(dp,1);
end
% Always update message - to enable or disable it
showNoDockedDialogsMsg(dp);

