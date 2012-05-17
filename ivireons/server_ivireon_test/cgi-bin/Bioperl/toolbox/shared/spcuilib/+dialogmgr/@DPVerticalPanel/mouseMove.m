function handled = mouseMove(dp)
% Handle mouse motion for dialog panel

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:03 $

handled = true; % assume event is handled

% Determine mouse position
pt_parent = getMouseInParentRefFrame(dp);
pt_x = pt_parent(1);
pt_y = pt_parent(2);

% Get body panel position
bodyPos = get(dp.hBodyPanel,'pos'); % in parent ref frame
body_xmin = bodyPos(1);
body_xmax = bodyPos(1)+bodyPos(3)-1;

dlgPanelOnLeft = strcmpi(dp.DockLocation,'left');

% If auto-hide is active,
% - test if we need to show the panel
% - reset the watchdog timer
autoHide = dp.AutoHide;
if autoHide
    % Test if mouse is over dialog panel
    %
    % Dialog panel on left:
    % [<-------------------- parentWidth -------------------->]
    % 1                                                       N
    % [gutterFig][scroll][ dlgPanel ][gutterBody][  bodyPanel ]
    %                                           |<-x
    % Dialog panel on right:
    % [<-------------------- parentWidth -------------------->]
    % 1                                                       N
    % [ bodyPanel ][gutterBody][ dlgPanel  ][scroll][gutterFig]
    %           x->|
    overDialogPanel = dlgPanelOnLeft && (pt_x < body_xmin) ...
        || (pt_x > body_xmax);
    
    if dp.PanelVisible
        % Reset the watchdog timer that auto-closes the panel.
        if overDialogPanel
            if 0
                % Always reset the timer, on every mouse motion
                % This provides the ideal outcome: a consistent timeout
                % duration is observed by the user when the mouse moves
                % outside the panel.  Achieved by resetting the timer every
                % time the mouse moves.  This is costly for CPU time.
                autoHideTimerReset(dp);
            else
                if ~strcmpi(get(dp.hAutoHideTimer,'Running'),'on')
                    % If the timer isn't running, it ran down and the
                    % time-out fcn determined that the mouse was still
                    % in-bounds at that time. (otherwise the panel would be
                    % closed/invisible now!) With a recent move of the
                    % cursor, we reset the timer to invoke another
                    % mouse-position test later.
                    %
                    % If it is running, don't reset it ... just let it run
                    % down. We could reset it now, but that takes time on
                    % each mouse move event, consuming CPU cycles to
                    % frequently restart the timer.
                    autoHideTimerReset(dp);
                end
            end
        end
    else
        % Panel is not currently visible
        % If mouse is over splitter, open the panel
        if overDialogPanel
            setDialogPanelVisible(dp,true); % resets auto-hide timer
            return % EARLY RETURN
        end
    end
end

% Test if mouse is hovering over splitter bar, which is the gutter between
% Body and Panel.  If so, enable resize (regardless of panel lock - that
% issue is handled in the mousedown/drag).
%
% Allow a few pixels of slack around the splitter bar.
% That will give the user a little slack in hovering
if dlgPanelOnLeft
    % No slack to left, since it would interfere with mouse-over on dialog
    % border itself.  However, we give slack of 2 pixels to right, allowing
    % overlap of the application body just a little.
    gutterBody_xlo = body_xmin-1-dp.GutterInfoBody;
    gutterBody_xhi = body_xmin-1 + 2;
else
    gutterBody_xlo = body_xmax+1 - 2;
    gutterBody_xhi = body_xmax+1+dp.GutterInfoBody;
end

if dp.ResizePanelWidthMouseHover && ...
        ((pt_x < gutterBody_xlo) || (pt_x > gutterBody_xhi))
    % Mouse is no longer hovering over splitter
    % Disable splitter mouse action
    dp.ResizePanelWidthMouseHover = false;
    setptr(dp.hFig,'arrow');

elseif ~dp.ResizePanelWidthMouseHover && ...
        (pt_x >= gutterBody_xlo) && (pt_x <= gutterBody_xhi)
    % Mouse just began hovering over splitter
    % Enable splitter mouse action
    dp.ResizePanelWidthMouseHover = true;
    setptr(dp.hFig,'lrdrag');
end

% Assume mouse is NOT over a dialog (we'll update this later as needed)
% This affects mouseUp processing, so reset it before possible early-exit
% for panel-width action
dp.MouseOverDialog = [];

% Test for hover over panel width resizing
%
if dp.ResizePanelWidthMouseHover
    % Cache original coords for mouse drag of panel width
    % Items to cache:
    %   - orig mouse x-coord
    %   - orig panel width
    %   - orig panel x-coord
    if isempty(dp.DockedDialogs)
        % No docked dialogs in dialogpanel
        dialog_x0 = 1; % doesn't matter, it goes unused
    else
        % Get x-coord for any docked dialog - use the first:
        h = getDialogBorderPanels(dp,dp.DockedDialogs(1));
        p = get(h,'pos');
        dialog_x0 = p(1);
    end
    dp.ResizePanelWidthMouseCache = [pt_x dp.PanelWidth dialog_x0];

    % Reset graphical display of hover over a dialog
    if ~isempty(dp.DialogHoverHighlightLast)
        db = dp.DialogHoverHighlightLast.DialogBorder;
        if ~isempty(db)
            set(db.Panel,'HighlightColor','w');
        end
        dp.DialogHoverHighlightLast = [];
    end
    
    return % EARLY EXIT
end

% Test if mouse is over main panel or a dialog
%
% Get info panel position
dp_pos = get(dp.hDialogPanel,'pos'); % dialog panel, in parent ref frame
dp_xmin = dp_pos(1);
dp_xmax = dp_pos(1)+dp_pos(3)-1; % last pixel in panel

% Check for hover over dialog versus panel 
overPanel = dp.PanelVisible && (pt_x >= dp_xmin) && (pt_x <= dp_xmax);
overDialog = false; % initial guess
if overPanel
    % dialog panel is visible, and mouse is over dialog area
    
    % Determine y coords of dialogs, in dialog panel ref frame
    % Must use a [1,1] offset - see comments in getMouseInParentRefFrame()
    pt_dp = pt_parent-dp_pos(1:2)+[1,1]; % cursor, in dialog ref frame
    pt_y = pt_dp(2);
    
    % xxx get this from DialogBorder
    %     only DialogBorder should know about any graphical offsets for its
    %     own content
    %
    % Dialogs have a top edge and a title/name
    % The name might extends above the graphical top edge of the dialog
    % such as DBCompact.  We want to graphically REDUCE the vertical
    % extent of the dialog (top edge specifically) in these cases, to make
    % the click selection appear to respect the top edge of the content and
    % not the title that may extends beyond the content edge.
    % DBCompact: 8
    % DBTitleBar: 2
    dialogMouseOverVerticalOffset = 2; % pixels to reduce top extent
    
    dockedDlgs = dp.DockedDialogs;
    highlightDialog = dp.DialogHoverHighlight;
    Ndocked = numel(dockedDlgs);
    for i = 1:Ndocked
        % Are we over a docked dialog?
        thisDlg = dockedDlgs(i);
        thisDlgPanel = thisDlg.DialogBorder.Panel;
        psub = get(thisDlgPanel,'pos'); % dialog, dialog ref frame
        
        % Determine y-start of dialog
        py1 = psub(2);  % subtract 1 here for panel origin
        py2 = psub(2)+psub(4)-dialogMouseOverVerticalOffset;
        overDialog = (pt_y>=py1) && (pt_y<py2);
        
        if overDialog
            % Store:
            %  1:dragged outside x-limits of dialog panel (T/F)
            %  2:original bottom-y-coord of dialog 
            %    (dialog panel ref frame)
            %  3:original mouse y-position
            %    (dialog panel ref frame)
            %  4:original mouse y-position unadjusted
            %    (dialog panel ref frame)
            dp.MouseOverDialog = [0 py1 pt_y 0];
            dp.MouseOverDialogDlg = thisDlg;

            if highlightDialog
                % hovering over i'th dialog
                % Reset graphical display of hover over last dialog
                if ~isempty(dp.DialogHoverHighlightLast)
                    db = dp.DialogHoverHighlightLast.DialogBorder;
                    if ~isempty(db)
                        set(db.Panel,'HighlightColor','w');
                    end
                end
                dp.DialogHoverHighlightLast = thisDlg;
                set(thisDlgPanel,'HighlightColor',dp.ColorUnlocked);
            end
            break % stop searching for dialog!
        end
    end
end

if ~overDialog
    % Check for dialog highlight
    if ~isempty(dp.DialogHoverHighlightLast)
        db = dp.DialogHoverHighlightLast.DialogBorder;
        if ~isempty(db)
            set(db.Panel,'HighlightColor','w');
        end
    end
    
    % Provide ability to shift all dialogs in the panel by dragging the
    % background of the panel display area.
    if overPanel
        % Reuse MouseOverDialog state vector to indicate a main panel drag
        
        % Cache main panel coords
        ipos = get(dp.hDialogPanel,'pos');
        py1 = ipos(2);
        dp.MouseOverDialog = [0 py1 pt_y 0];
        
        % empty denotes mouse is over MAIN PANEL, not a dialog
        dp.MouseOverDialogDlg = [];
    end
end

if overDialog || overPanel
    % We're over a dialog - nothing more to test
    return % EARLY RETURN
end

% Mouse not handled by dialog panel
handled = false;

