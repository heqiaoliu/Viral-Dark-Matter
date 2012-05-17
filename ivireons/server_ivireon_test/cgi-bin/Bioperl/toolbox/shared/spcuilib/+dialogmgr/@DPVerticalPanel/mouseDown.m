function motionFcn = mouseDown(dp)
% Handle mouse-down event for dialog panel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:01 $

motionFcn = [];

% Check for mouse-down on splitter
%
% Don't engage motionFcn if panel is not visible
% We DO want the mouseDown/mouseUp actions, in case we're toggling the
% panel display state, however.
%
% We must define motionFcn if we're over the resize splitter,
% whether panel is visible or not.  That's because we want the caller to
% see that we've "got the ball" ... even if we're not going to engage the
% resize due to an invisible panel
if dp.ResizePanelWidthMouseHover  % && dp.PanelVisible
    % Mouse down on splitter: resize panel
    motionFcn = @(h,e)mouseResizeDialogPanelWidth(dp);
    
    return % EARLY EXIT
end

% If mouse not over panel or dialog, exit
if isempty(dp.MouseOverDialog)
    return % EARLY EXIT
end

% Mouse clicked on the main panel or a dialog
dlg = dp.MouseOverDialogDlg;
isOverDialog = ~isempty(dlg);
if isOverDialog
    dialogBorder = dlg.DialogBorder;
else
    % empty if mouse clicked over dialog presenter, but not over a dialog
    dialogBorder = [];
end

% Mouse selection type
%  normal: left click
%  alt: right click, or ctrl+click (left or right)
%  extend: shift+click (left or right)
%  open: double-click (left or right)
selType = get(dp.hFig,'SelectionType');
switch selType
    case 'alt'
        % Don't process "right-click" since dialogs support context
        % menus; it will be confusing to see menu open after a drag
        % operation
        return % EARLY EXIT
    case 'extend'
        % If shift held down, shift all dialogs together,
        % instead of moving just one dialog
        dp.DialogShiftAction = 1;
    case 'open'
        if strcmpi(selType,'open')
            % Double-click
            % If it's over a dialog, send roller-shade message
            % If it's over main panel, ignore and exit
            
            if ~isempty(dialogBorder)
                mouseOpen(dialogBorder);
                return % EARLY EXIT
            end
        end
        
    otherwise % 'normal'
        % Reorder panels only if lock turned off
        % Otherwise, shift all panels
        if dp.PanelLock
            % Optionally disable panel shift when dragging locked panel
            if dp.ScrollPanelsOnLockedPanelDrag
                dp.DialogShiftAction = 1;
            else
                dp.DialogShiftAction = -1;
            end
        end
end

if ~isOverDialog
    % Simple click over main panel, not a dialog in the panel
    %
    % Pretend shift was pressed, we engage shift of entire panel
    % If shift was pressed, we're just setting it again without harm
    %
    % Set to 1 to enable background-drag shift of all panels,
    % or -1 to disallow background-drag shift.
    %
    % Setting to -1 allows background to still be dragged for a panel dock
    % location change, but note that mouseMove() must enable overPanel
    % detection to enable both these cases.
    %
    dp.DialogShiftAction = -1;
end

switch dp.DialogShiftAction
    case -1
        % The intent is to "do nothing"
        % We don't want to change the mouse pointer
    case 1
        % shift all panels
        engageShiftOfAllPanels(dp);
    otherwise
        % Single dialog or main panel clicked
        engageShiftOfOnePanel(dp);
end

motionFcn = @(h,e)mouseDragDialog(dp);

% Set cursor to 'closedhand' if this is not a locked panel
if ~dp.PanelLock
    setptr(dp.hFig,'closedhand');
end


function engageShiftOfAllPanels(dp)
% Engage shift of all docked panels simultaneously

hPanels = getDialogBorderPanels(dp,dp.DockedDialogs);

% Highlight docked dialogs
set(hPanels,'highlight',dp.ColorUnlocked);

% Cache starting positions of all docked dialogs
% All positions are pixels, in dialog panel reference frame
dp.DialogShiftStartPos = get(hPanels,{'pos'});


function engageShiftOfOnePanel(dp)
%
% Only engage motion function, and highlight this dialog,
% if this is a dialog and not the main (background) panel

% Single dialog
% Reset current highlighted panel, if any, to white
% Do this by resetting ALL docked dialog highlighting
set(getDialogBorderPanels(dp,dp.DockedDialogs), ...
    'highlight','w');

% - set current dialog highlight
set(getDialogBorderPanels(dp,dp.MouseOverDialogDlg), ...
    'highlight',dp.ColorUnlocked);

% Clear shift-start positions, as they are irrelevant
dp.DialogShiftStartPos = {};

