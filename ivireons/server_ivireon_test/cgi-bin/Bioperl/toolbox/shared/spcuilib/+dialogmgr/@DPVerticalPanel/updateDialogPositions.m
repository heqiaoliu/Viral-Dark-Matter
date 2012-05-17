function updateDialogPositions(dp,performRecalc)
% Reorder dialogs within docked dialog panel by adjusting vertical shifts.
% Also uniformly sets dialog widths to the current panel width.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:35 $

% "First" dialog paints at the TOP of the multi-dialog panel (or beyond the
% top), and the "Last" dialog paints at the BOTTOM of the panel (or lower
% than the bottom).  We paint dialogs from the top down, so unused space is
% at the bottom if the dialogs do not fill the vertical span of the panel.
%
% Vertical coords: lower coordinate is lower on the screen

if nargin<2 || performRecalc
    setDialogVerticalExtents(dp);
end

if dp.PanelVisible
    % Full panel is visible (not in "closed" or "hidden" state)

    % Get vertical extent of dialog panel
    % This is defined to be the same as the vertical extent of the parent
    % panel itself
    ppos = get(dp.hParent,'pos');
    panel_dy = ppos(4);
    dialogs_dy = dp.DialogsTotalHeight; % pixels
    
    % Get ordered list of handles to uipanel of each docked dialog
    % First entry is topmost docked dialog
    visDlgs = dp.DockedDialogs;
    N = numel(visDlgs);
    h = getDialogBorderPanels(dp,visDlgs);
    
    % yTop:
    % vertical pixel coordinate of the topmost pixel within the
    % topmost dialog, index=1 is the first pixel available to see in the
    % panel.  yTop can be a coordinate PAST the top of the visible
    % multi-dialog panel.
    %
    % yOverTop:
    % number of pixels that fall past the topmost visible pixel in the
    % multi-dialog panel. 0 means no dialog pixels fall past top.
    %
    % yOverBot:
    % Num "unused" pixels ABOVE the lowest visible pixel in the
    % multi-dialog panel.  That is, these pixels are ABOVE or TOWARD
    % THE TOP of the dialog, relative to the lowest visible pixel.
    % Positive means blank pixels above the bottom pixel.  Zero means
    % the lowest pixel is filled.  Negative means pixels extend BELOW
    % the first (bottommost) visible pixel in panel.
    
    % Update vertical shift of dialogs
    panelShift = dp.DialogShiftAction;
    
    if panelShift==0 || N==0
        % no mouse-shift underway
        % could be a static repaint, or a scroll wheel reaction,
        % or a slider drag reaction
        %
        % Standard resize call
        % Maintain "over top" offset but use rules to adjust
        yOverTop = dp.DialogShiftOverTop;
        % If panel_dy=10, there are 10 pixels in the multi-dialog panel,
        % and the coordinate y=10 is where the topmost pixel of the topmost
        % dialog should render --- assuming yOverTop=0.
        yTop = panel_dy + yOverTop;
        yOverBot = yOverTop + (panel_dy-dialogs_dy);
        
    elseif panelShift==1
        % shift all dialogs
        %
        pFirst = get(h(1),'pos'); % pos of first vis dialog in panel
        pLast = get(h(end),'pos'); % pos of last vis dialog in panel
        
        % yTop,yBot: vertical pixel pos of topmost/bottomost dialogs
        yTop = pFirst(2)+pFirst(4)-1; % xxx + dp.DialogVerticalGutter;
        yBot = pLast(2);
        
        % Get vertical panel offset (0=at top/bot)
        yOverBot = yBot-1; % starting y coord of bottommost panel
        yOverTop = yTop-panel_dy; % starting y coord of topmost panel
            
    elseif panelShift==2
        % shift all dialogs via dialog drag, pos motion (scroll up)
        %
        % Keep bottom dialogs positioned as-is
        % Adjust position of current and above
        % Determine yTop, yBot, and DialogShiftOverTop that
        %   allow this alignment.
        
        % Get y-pos of last/lowest dialog
        % To find y-pos of top of this set of bottom panels,
        % don't forget we keep 3 gutters at bottom of dialog
        % stack, then one gutter above each dialog
        pLast = get(h(end),'pos'); % pos of last dialog in panel
        yBot = pLast(2);
        yTop = yBot + dialogs_dy-1;
        yOverBot = yBot-1;
        yOverTop = yOverBot + (dialogs_dy-panel_dy);
        
    elseif panelShift==3
        % shift all dialogs via dialog drag, neg motion (scroll dn)
        %
        % Keep top dialogs positioned as-is
        
        pFirst = get(h(1),'pos'); % pos of fist dialog in panel
        yTop = pFirst(2)+pFirst(4)-1; % xxx + dp.DialogVerticalGutter;
        %yBot = yTop - dialogs_dy-1;
        yOverTop = yTop-panel_dy;
        yOverBot = yOverTop + (panel_dy-dialogs_dy);
    else
        % panelShift==-1
        return % EARLY EXIT
    end
    
    yshift=0; % # pixels to shift DOWNWARDS (-> neg means UPWARDS)
    if yOverTop>0
        % Top of first dialog is above top of multi-dialog panel
        % Bring it back down if yOverBot>0 -- that is, the top dialog is
        % above the top of the panel, yet there is space available at the
        % bottom of the panel.  We don't allow that, as it looks bad and
        % does not provide a consistent interaction.
        %
        %   - how far down? the smaller of yOverBot or yOverTop
        if yOverBot>0
            yshift = min(yOverBot,yOverTop);
        end
    elseif yOverTop<0
        % Top of first dialog is BELOW top of multi-dialog panel.
        % Therefore, there's blank space a the top of the panel.
        %
        % Move dialogs up - we always keep top panel pixel filled,
        % so no blank space appears at the top of the multi-dialog panel.
        yshift = yOverTop;
    end
    
    % Top of 1st dialog is a 1-based coord, relative to start of
    % multi-dialog panel (that is, it is in local coords)
    pTop = yTop-yshift;
    
    % Record for non-shift resize
    % After adjustment, how far over top of fig is topmost dialog?
    postshift = pTop-panel_dy;
    
    dp.DialogShiftOverTop = postshift;

    % Reposition vertical offset of each dialog
    panel_dx = dp.PanelWidth;
    vGutter = dp.DialogVerticalGutter;
    for i = 1:N
        % h() contains dialog uipanel handles, ordered from top to bottom
        % for display purposes.  h(1) is the handle to the topmost dialog
        % uipanel
        p_i = get(h(i),'pos');
        
        % Translate from coordinate of last pixel used by dialog,
        % to coordinate of first pixel used by dialog
        pTop = pTop-p_i(4)+1;
        
        % Option 1: change location and dialog panel width
        %  NOTE: This could compete with a resize action put in place by
        %  the DialogBorder, so changing width here may be risky.
        %
        set(h(i),'pos',[p_i(1) pTop panel_dx p_i(4)])
        %
        % Option 2: only change y-origin, not x-origin or size
        %p_i(2) = pTop+1;
        %set(h(i),'pos',p_i)
        
        % Get set for next dialog
        % pTop must be coordinate of topmost pixel of next dialog
        % Subtract one pixel to get to the topmost pixel of the next
        % dialog, and then remember there's a vertical gutter of zero or
        % more blank pixels
        pTop = pTop-1-vGutter;
    end
    
    % Update scroll bar value
    setScrollBarValue(dp);
end

