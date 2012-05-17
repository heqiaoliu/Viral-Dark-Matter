function mouseDragDialog(dp,isTimer)
% Drag a dialog in panel, manually (isTimer=false) or by calls from the
% AutoScroll facility (isTimer=true).
% Allows for a reordering of dialogs, or a change in dock location.
%
% Moves one dialog within panel which may engage auto-scroll
% and/or reorder dialogs within panel.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:02 $

if nargin<2
    isTimer=false;
end

% isPastDockLocDeadZone:
%   A small horizontal gap of pixels used as a "dead zone"
%   If the mouse is dragged beyond the horizontal limits of the dialog
%   panel, the dock-location outline is NOT made visible until a sufficient
%   drag distance is exceeded.  This is the dead zone.  This makes it easy
%   for a user to drag the dialog panel without an unintended start of a
%   change to the dock location.
[pt_panel,~,isPastDockLocDeadZone,pt_parent] = ...
    getMouseInDialogPanelRefFrame(dp);

% .MouseOverDialog: dialog index & y-coord at mouse click
% (1) dialog dragged beyond horizontal dead zone, signifying the start of a
%     change in dock location
% (2) original bottom-y-coord of dialog (in dialog panel ref frame)
% (3) original mouse y-start position (in dialog panel ref frame)
% (4) last ydelta
ydelta = pt_panel(2) - dp.MouseOverDialog(3); % change in y since click

% Only set mouse pointer when needed - that is, on a transition
%   of position from outside-to-inside the x-limits, or vice-versa
ptrBeyondDeadZone = dp.MouseOverDialog(1);

if ~ptrBeyondDeadZone && isPastDockLocDeadZone && ...
        ~dp.PanelLock && dp.DockLocationMouseDragEnable
    % Dragged mouse/dialog outside dead-zone limits of dialog panel.
    % This will begin the visualization of a panel outline, signifying a
    % change to the dock location of the dialog panel.  A change will not
    % occur unless the outline is moved most of the way toward the opposite
    % side of the hParent panel.
    %
    % Change to panel-drag pointer
    dp.MouseOverDialog(1) = true; % update user-data later
    %setptr(dp.hFig,'forbidden');
    
    moveDialogPanelOutline(dp,pt_parent);
    set(dp.hPanelOutline,'vis','on');
    
elseif ptrBeyondDeadZone && ~isPastDockLocDeadZone
    % Mouse left the dock-location change zone
    % Change back to normal drag pointer
    dp.MouseOverDialog(1) = false;  % update user-data later
    %setptr(dp.hFig,'closedhand');
    
    set(dp.hPanelOutline,'vis','off');
    
elseif ptrBeyondDeadZone
    % Continue to drag outline
    moveDialogPanelOutline(dp,pt_parent);
end

if ptrBeyondDeadZone
    % Change dock location, depending on distance of panel outline drag.
    
    % Get mouse position, and body panel size
    ptx = pt_parent(1); % x-coord of cursor, in parent ref frame
    bodyPos = get(dp.hBodyPanel,'pos');
    
    % If drag is > some fractional distance of the total body, swap dock
    % location
    %
    % NOTE: Don't be visually confused by an axis in the body or some other
    % graphics ... the drag threshold is a fraction of the way across the
    % body uipanel, and not a fraction of the way across some
    % application-specific axis display area set up by a client app.
    
    % Fraction to move panel before we change dock location must be greater
    % than width of panel, otherwise a conflict occurs and we get
    % oscillation halfway during the drag.
    %
    % The narrower the dialog panel, the larger fracMove must be to prevent
    % oscillation.
    fracMove = 0.5; % fraction of the distance across body panel
    
    if strcmpi(dp.DockLocation,'left')
        % info panel is on left, and we are dragging to the right
        % -> set threshold so cursor must cross a fraction of the total
        % body width
        swap = ptx > bodyPos(1)+bodyPos(3)*fracMove;
    else
        % info panel is on right, and we are dragging to the left
        % -> set threshold so cursor must cross (1-frac) of the total body
        % width
        swap = ptx < bodyPos(1)+bodyPos(3)*(1-fracMove);
    end
    if swap
        changeDockLocation(dp);
        return % EARLY RETURN
    end
end

% Get and update ydelta for mouse y-direction determination
ydir = sign(ydelta - dp.MouseOverDialog(4));
dp.MouseOverDialog(4) = ydelta;

% If this is a dialog drag, carry out shift or reordering operations
switch dp.DialogShiftAction
    case -1
        % do nothing
    case 1
        % shift+drag
        doShiftDialogs(dp,ydelta);
    otherwise
        isDialog = ~isempty(dp.MouseOverDialogDlg);
        if isDialog
            % Move one dialog - simple drag
            doAutoScroll(dp,ydelta,ydir,isTimer);
            doSwapDialogs(dp);
        end
end

