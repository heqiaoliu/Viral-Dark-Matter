function handledMouseUp = mouseUp(dp)
% Handle mouse-up event for Dialog Panel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:06 $

handledMouseUp = false;

% Manage auto-scroll timer - shut it down if running
updateAutoScrollTimer(dp, false);

% Reset if a panel or dialog drag
if ~isempty(dp.MouseOverDialog)
    % One dialog was moved, or all dialogs were shifted
    setptr(dp.hFig,'arrow'); % restore pointer

    % Property is empty if main panel was clicked, and not a dialog, 
    dlg = dp.MouseOverDialogDlg;
    isMainPanel = isempty(dlg);
    
    % Clear the highlighting from the moved panel
    if dp.DialogShiftAction==1
        set(getDialogBorderPanels(dp,dp.DockedDialogs),'highlight','w');
    elseif ~isMainPanel
        set(dlg.DialogBorder.Panel,'highlight','w');
    end
    
    % Hide info panel outline if it was visible
    % Only possible to be visible if panellock is off
    if ~dp.PanelLock
        set(dp.hPanelOutline,'vis','off');
    end
    
    % Normalize y-positions of all dialogs
    updateDialogPositions(dp);
    
    % Clear dialog motion caches
    dp.DialogShiftAction = 0;
    dp.MouseOverDialog = [];  % vector during dialog swaps
    dp.MouseOverDialogDlg = [];
    dp.DialogShiftStartPos = {}; % positions of all dialogs during shift
    
    handledMouseUp = true;
    
elseif ~isempty(dp.ResizePanelWidthMouseCache)
    % Finished mouse drag on dialog panel width
    
    % Determine if there was any motion on the panel width
    % If not, declare this to be a "click" on the panel border
    %
    % .ResizePanelWidthMouseCache is initialized to the vector
    % [pt_x dp.PanelWidth] at the start of the panel-width drag operation.
    cache = dp.ResizePanelWidthMouseCache;
    
    % Technique 1
    % Determine original mouse position
    orig_x = cache(1);
    % Determine current mouse position
    pt_parent = getMouseInParentRefFrame(dp);
    pt_x = pt_parent(1);
    clicked = orig_x == pt_x;
    
    %{
    % Technique 2
    % Works best when panel is open, since drags on splitter cause panel
    % width change.  But, fails on panel closed, since drags on splitter do
    % NOT cause change in width; in this case, the user could have dragged
    % the splitter (when panel is closed) and we see this as a click.  It's
    % not really a click, it's a drag.  Seems odd to open the panel in this
    % case.  However, this is certainly simpler!
    origWidth = cache(2);
    clicked = (dp.PanelWidth == origWidth);
    %}
    
    if clicked
        % Mouse up with no change in panel width - this was a "click"
        % Toggle panel state, then update pointer
        toggleDialogPanelVisible(dp);
        setptr(dp,'arrow');
    end
    
    % Reset cache
    dp.ResizePanelWidthMouseCache = [];
    handledMouseUp = true;
end

% Perform mouseMove detection, so the cursor updates in case we remain over
% hover-enabled features of the dialog panel
mouseMove(dp);

