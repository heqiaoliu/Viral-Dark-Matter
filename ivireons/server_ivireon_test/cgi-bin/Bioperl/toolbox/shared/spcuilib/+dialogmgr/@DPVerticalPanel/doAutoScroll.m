function doAutoScroll(dp,ydelta,ydir,isTimer)
% Check to see if auto-scroll should be performed
% If so, engage auto-scroll
%
% ydelta: change in mouse from initial position 
%         (adjusted for dialog swaps)
% ydir: +1/0/-1 indicating direction of mouse travel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:39 $

% Get dialog ID and y-coord when mouse was clicked
% (1) dragged outside x-limits of dialog panel
% (2) original bottom-y-coord of dialog (dialog panel ref frame)
% (3) original mouse position (dialog panel ref frame)
% (4) last ydelta
dialog_ystart = dp.MouseOverDialog(2);
mouse_ystart  = dp.MouseOverDialog(3);
pt_parent     = mouse_ystart + ydelta; % mouse, in parent ref frame

% Get current (pre-move) coords of this dialog
thisDlg = dp.MouseOverDialogDlg;
hThis = getDialogBorderPanels(dp,thisDlg); % handle to Dialog uipanel
this_pos = get(hThis,'pos'); % [x y dx dy]
this_dy = this_pos(4);

% Determine new top & bottom coords of this dialog
this_bottom_y = dialog_ystart + ydelta; % new y-pos of this dialog
%this_top_y = this_bottom_y+this_dy-1;

% Determine top and bottom of dialog panel main uipanel
dp_pos   = get(dp.hDialogPanel,'pos'); % in parent ref frame
dp_bot_y = dp_pos(2);
dp_dy    = dp_pos(4);
dp_top_y = dp_bot_y+dp_dy-1;

% Determine if auto-scroll behavior is desirable based on mouse action
scroll_up = false; % initialize
scroll_dn = false;

% Determine y-reference to compare with y-mouse
% - If mouse passes this coord, and mouse is moving in the appropriate
%   direction, we can engage auto-scroll
% - This is a necessary but not sufficient condition
%
% Up: Y-ref is where the border of the top panel would land if there
%    was no shift.  Use vertical gutter as the trigger region.  when we're
%    within "gutter" number of pixels, engage.
%
% Down: similar.
%
gutter = dp.DialogVerticalGutter;
mouseScrollUpAction = (pt_parent > dp_top_y-gutter) ...
    && (isTimer || (ydir==+1));
mouseScrollDnAction = (pt_parent < 1+gutter) ...
    && (isTimer || (ydir==-1));

% Determine if we should auto-scroll
if mouseScrollUpAction || mouseScrollDnAction
    
    % Get list of docked dialogs EXCEPT this one
    refDlgs = dp.DockedDialogs;
    refDlgs(thisDlg.DialogContent.ID == getID(refDlgs)) = [];
    NrefDlgs = numel(refDlgs);
    
    if mouseScrollUpAction
        % Determine if the topmost dialog (but not this dialog!) has
        % scrolled down to the point that enough room exists to drop this
        % dialog at the top.  If not, we can keep scrolling up.
        %
        % dp_top_y is the top coord of the multi-dialog panel area
        
        yMustBeBelow = dp_top_y-this_dy-gutter;
        
        if NrefDlgs==0
            enoughTopSpaceForThisPanel = true;
        else
            firstRefPanel = getDialogBorderPanels(dp,refDlgs(1));
            posRefPanel = get(firstRefPanel,'pos');
            topRefPanel = posRefPanel(2)+posRefPanel(4)-1;
            maxScrollUp = topRefPanel - yMustBeBelow;
            enoughTopSpaceForThisPanel = maxScrollUp < 0;
        end
        % IF user moved the mouse appropriately,
        % AND we need to make more space for the panel,
        % THEN we should auto-scroll:
        scroll_up = ~enoughTopSpaceForThisPanel;
        
    elseif mouseScrollDnAction
        % Similar steps for bottommost dialog
        % remove this panel index
        if NrefDlgs==0
            enoughBotSpaceForThisPanel = true;
        else
            % Determine y-coord of topmost pixel for necessary blank space
            % at bottom of panel area.
            %
            % dp_bot_y is the bottom of the multi-dialog panel area
            % We need this_dy vertical room, plus a vertical gutter
            yMustBeAbove = dp_bot_y+this_dy+gutter;
            
            % this is currently where the lowest panel bottom is:
            lastRefPanel = getDialogBorderPanels(dp,refDlgs(end));
            posRefPanel = get(lastRefPanel,'pos');
            botRefPanel = posRefPanel(2);
            
            maxScrollDown = yMustBeAbove - botRefPanel;
            enoughBotSpaceForThisPanel = maxScrollDown < 0;
        end
        scroll_dn = ~enoughBotSpaceForThisPanel;
    end
end

% Move selected panel up or down
%
% No need to limit motion to top/bottom of dialog panel,
% since on mouse-up we "normalize" the positions of all dialogs
this_pos(2) = this_bottom_y; % adjust y
set(hThis,'pos',this_pos);

% s=char(' ' * ones(1,randi(5)));
% if scroll_up, fprintf('%s-> scroll_up\n',s); end
% if scroll_dn, fprintf('%s-> scroll_dn\n',s); end

% Determine how we will auto-scroll
if scroll_up
    % Are dialogs scrolled to top already?
    dp.DialogShiftAction = 2;
    scrollDist = min(dp.MaxAutoScrollStepSize,maxScrollUp);
    if scrollDist>0
        doAutoScrollShift(dp,-scrollDist);
    end
elseif scroll_dn
    % Are dialogs scrolled to bottom already?
    dp.DialogShiftAction = 3;
    scrollDist = min(dp.MaxAutoScrollStepSize,maxScrollDown);
    if scrollDist>0
        doAutoScrollShift(dp,scrollDist);
    end
end

% Manage timer
updateAutoScrollTimer(dp, scroll_up||scroll_dn);

