function doSwapDialogs(dp)
% Check to see if a swap between two docked dialogs should occur while a
% docked dialog is being dragged.  If so, swap the order of the two
% dialogs.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2010/03/31 18:39:42 $

% Get dialog index and y-coord when mouse was clicked
% (1) dragged outside x-limits of dialog panel
% (2) original bottom-y-coord of dialog (dialog panel ref frame)
% (3) original mouse position (dialog panel ref frame)
% (4) last ydelta
m = dp.MouseOverDialog;
dialog_ystart = m(2);

% Get coords of this dialog
thisDlg = dp.MouseOverDialogDlg; % handle to Dialog under mouse
hThis = thisDlg.DialogBorder.Panel;
this_pos = get(hThis,'pos'); % [x y dx dy]

% Determine new top & bottom coords of this dialog
this_bottom_y = this_pos(2);
this_dy = this_pos(4);
this_top_y = this_bottom_y+this_dy-1;

% Panel index 1 within DockedDialogs is at top of figure (highest y)
% Panel index N is on bottom of figure (lowest y)
%
% Get ID of this docked dialog
visDlgs = dp.DockedDialogs;
visIDs = getID(visDlgs); % in visible order
thisID = thisDlg.DialogContent.ID;
thisIdx = find(thisID == visIDs); % index within DockedDialogs vector

% Check for swap-up between THIS DIALOG and DIALOG ABOVE
%
% NOTE: The top dialog (eg, thisOrdIdx==1) has no panel above it
if thisIdx > 1
    % Are we moving this dialog above midpoint of next higher panel?
    aboveDlg    = visDlgs(thisIdx-1);
    above_panel = aboveDlg.DialogBorder.Panel;
    above_pos   = get(above_panel,'pos');
    above_dy    = above_pos(4); % dy of panel above this one
    above_midpt = above_pos(2)+(above_dy-1)/2; % may have 0.5 pixel
    past_above_midpt = this_top_y > above_midpt;
    
    % Did this dialog move above adjacent dialog?
    if past_above_midpt
        % If top y-coord moves above midpt of next-higher panel,
        % swap panels
        
        % Move the "above" panel to where "this" panel started
        new_above_pos = above_pos;
        new_above_pos(2) = dialog_ystart;
        set(above_panel,'pos',new_above_pos);
        
        % Set new cache info as we continue to move "this" panel
        % If we keep moving up, the next dialog should take the starting
        % pos of the panel that we just moved.  In effect, the "above"
        % panel gets moved down, and "this" panel gets moved up.
        % We reset the cache info to make "this" panel look like we just
        % started moving it from its newly-raised position
        change = above_dy + dp.DialogVerticalGutter;
        m = dp.MouseOverDialog;
        m(2:3) = m(2:3) + change; % dialog_ystart, mouse_ystart
        dp.MouseOverDialog = m;
        
        % Swap these two entries in visible dialog vector
        visDlgs([thisIdx-1 thisIdx]) = visDlgs([thisIdx thisIdx-1]);
        dp.DockedDialogs = visDlgs;
        
        return % EARLY EXIT
    end
end

% Check for swap-down between THIS DIALOG and DIALOG BELOW
%
% NOTE: dialog idx=1 is visually at the top of the panel stack,
%       while dialogs with idx>1 are lower.  So thisOrdIdx==#vis
%       means the last visible panel, which has no (visible) dialogs
%       lower than it.
%
Ndocked = numel(visDlgs); % # docked dialogs
if thisIdx < Ndocked
    % Are we moving this dialog below midpoint of next lower panel?
    belowDlg    = visDlgs(thisIdx+1);
    below_panel = belowDlg.DialogBorder.Panel;
    below_pos   = get(below_panel,'pos');
    below_dy    = below_pos(4);
    below_midpt = below_pos(2)+(below_dy-1)/2; % may have 0.5 pixel
    past_below_midpt = this_bottom_y < below_midpt;

    % Did this dialog move below adjacent dialog?
    if past_below_midpt
        % If bottom y-coord moves below midpt of next-lower panel,
        % swap panels
        %
        % The "-1" offset above provides some hysteresis
        % Without it, the system will reverse swap direction since
        % we'd be touching the OTHER boundary of this adjacent panel
        
        % Swap graphically
        new_below_pos = below_pos;
        new_below_pos(2) = dialog_ystart + this_dy-below_dy; % push to top
        set(below_panel,'pos',new_below_pos);
        
        % Set new cache info
        % If we keep moving down, the prev dialog should take the starting
        % pos of the panel that we just moved
        change = below_dy + dp.DialogVerticalGutter;
        dp.MouseOverDialog(2) = dp.MouseOverDialog(2) - change; % dialog_ystart
        dp.MouseOverDialog(3) = dp.MouseOverDialog(3) - change; % mouse_ystart
        
        % Swap these two indices in ordering vector
        % Swap these two entries in visible dialog vector
        visDlgs([thisIdx+1 thisIdx]) = visDlgs([thisIdx thisIdx+1]);
        dp.DockedDialogs = visDlgs;
    end
end

