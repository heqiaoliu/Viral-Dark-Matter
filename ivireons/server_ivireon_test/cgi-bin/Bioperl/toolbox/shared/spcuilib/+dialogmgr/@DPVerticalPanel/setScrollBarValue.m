function setScrollBarValue(dp)
% Set scroll bar value based on pixel-shift offset of dialogs within
% dialog panel.  To do this, we need to determine the fractional position
% of the dialog shift in the range [0,1]:
%  - when top of top dialog hits top of dialog panel, that's 100%
%  - when bottom of bottom dialog hits bottom of dialog panel, that's 0%
%
% Note: setDialogVerticalExtents() computes scroll active bar size.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:23 $

% Get parent panel height (same as dialog panel height)
% and total height of all dialogs when rendered (including gutters)
ppos = get(dp.hParent,'pos');
panel_y  = ppos(2);
panel_dy = ppos(4);
dialogs_dy = dp.DialogsTotalHeight;

if dialogs_dy <= panel_dy
    % Dialogs don't extend beyond panel height
    % Slider position is 1.0 by definition
    sliderPos = 1; % all the way at the top
else
    % maximum possible shift of dialogs upwards above the top of the dialog
    % panel itself
    %
    % Determine d1_pos and offset
    
    allVis = dp.DockedDialogs;
    N = numel(allVis); % # visible dialogs
    
    % idxToTrack is the index of the topmost non-dragged dialog
    %
    % We need to "hand-off" from the topmost non-dragged dialog to the
    % topmost dragged dialog, at the point when the topmost dragged
    % dialog becomes the topmost dialog.  This gives
    % continuity in tracking motion which is used to set the scroll bar
    % position.
    
    % If .MouseOverDialogDlg is empty, it means a shift of ALL dialogs
    % (i.e., no dialog is under mouse)
    % Otherwise, it means ONE dialog is being moved
    mDlg = dp.MouseOverDialogDlg;
    
    if ~isempty(mDlg) ...
            && (mDlg.DialogContent.ID == allVis(1).DialogContent.ID) ...
            && (N>1)
        % Dragged dialog (mDlg) is the top-most dialog in the panel,
        % and it is not the only dialog in the panel.
        %
        % This dialog could have been the top-most dialog all
        % along, or the dialog could have been "swapped" during
        % motion to become the top-most dialog just now.
        %
        % Distance from top of panel to top of 2nd dialog is
        % the amount of room available for new dragged panel.
        % As this amount of room approaches the height of the
        % dragged panel, the slider approaches 1.0.
        
        % We track docked dialog #2
        dlgToTrack = allVis(2);
        
        % Add the distance between panel top and 2nd panel
        % to the height of the 2nd panel
        
        % p1 is the one being dragged
        % we want to have enough room to deposit it
        % which is p1_dy
        hp1 = getDialogBorderPanels(dp,allVis(1));
        p1_pos = get(hp1,'pos');
        offset = p1_pos(4) + dp.DialogVerticalGutter;
    else
        % We track docked dialog 1
        dlgToTrack = allVis(1);
        % No need for an offset
        offset = 0;
    end
    
    % Find position of "topmost non-dragged dialog"
    % (which is either 1st or 2nd dialog, and changes dynamically
    % during the course of a drag that goes all the way to the top)
    hTopmostDlgPanel = getDialogBorderPanels(dp,dlgToTrack);
    d1_pos = get(hTopmostDlgPanel,'pos');
    
    % Maximum allowable shift of dialogs in multi-dialog panel
    max_shift = dialogs_dy-panel_dy;
    
    % y-coord of top pixel in multi-dialog panel, in DP ref frame
    % indicates the coord of the topmost pixel of highest visible dialog
    panel_top = panel_y+panel_dy-1;
    
    d1_height = d1_pos(4); % 1st dialog height
    d1_ymin = panel_top - d1_height+1; % y-coord
    d1_ymax = d1_ymin + max_shift;  % xxx -1?
    
    % y-coord of first panel
    d1_y = d1_pos(2);
    
    % This is the central calculation to make:
    %   what is the slider position, in normalized range [0,1]?
    %
    %   sliderPos = (current_position) / (total range available to move)
    %             = (y-ymin)/(ymax-ymin)
    %
    sliderPos = (d1_y-d1_ymin + offset+1)./max(1,(d1_ymax-d1_ymin));
    sliderPos = max(0,(min(1,sliderPos))); % clamp range to (0,1)
end

% Set slider position
set(dp.hScrollBar,'value',1-sliderPos);

