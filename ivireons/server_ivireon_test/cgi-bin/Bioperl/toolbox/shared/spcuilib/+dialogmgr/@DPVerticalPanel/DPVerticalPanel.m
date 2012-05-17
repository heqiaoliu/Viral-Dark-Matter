classdef DPVerticalPanel < dialogmgr.DialogPresenter
    % Create a DPVerticalPanel object, which presents a visual framework
    % for presenting multiple Dialog objects to a user in a vertical
    % scrolling format.

        
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2010/03/31 18:39:24 $

    properties
        % Enable auto-hide of panel, which causes it to close when mouse
        % is no longer hovering over it.
        % True: use AutoHide hovering to open/close panel
        % False: use explicit open/close click for panel
        AutoHide = false
        
        % Specify optional minimum dimension of body panel
        % If body panel gets smaller than this size, the body content is
        % hidden and a message is shown.  Message takes an optional name of
        % the application, "Too small to show <application>".
        % Set minimum width and height to 0 to disable minimum size.
        BodyMinWidth     = 0 % minimum body width, in pixels
        BodyMinHeight    = 0 % minimum body height, in pixels
        BodyMinSizeTitle = 'application' % name for body size message

        % Dialog outline colors, used when mouse events are visualized
        ColorLocked   = [.6 .6 .6] % gray
        % ColorUnlocked = [ 0 .7  0] % green
        ColorUnlocked = [ 0 0 .75]*0.9 % blue
        
        % Highlight the current dialog when hovering over it
        DialogHoverHighlight = false
        
        % Number of vertical pixels to leave between dialogs in panel
        DialogVerticalGutter = 8
        
        % Location of hParent panel to render DialogPanel
        % Choices are 'left' or 'right'
        DockLocation = 'right'
        
        % Enable changes to dock location after initialization
        DockLocationMouseDragEnable = true
        
        % Number of pixels beyond the dialog panel horizontal limits,
        % beyond which a dialog must be dragged, in order to signal the
        % start of a change in dialog panel dock location.
        DockLocationMouseDragDeadZone = 24
        
        % Pixel size of info/body and info/fig gutters
        % gutter between dialogpanel and bodypanel, in pixels
        %   (this is also where the splitter widget is located)
        GutterInfoBody = 6
        % gutter between dialogpanel and figure edge, in pixels
        GutterInfoFig  = 3
        
        % Lock dialog panel to prevent changes to width, dock location,
        % and dialog ordering
        PanelLock = false
        
        % Dialog panel width, for resizing
        PanelMinWidth = 200 % pixels
        PanelMaxWidth = 400 % pixels
        PanelWidth    = 200 % initial pixel width
        
        % Thickness of line used to represent panel when dragging panel to
        % a new dock location
        PanelOutlineLineThickness = 3
        
        % Pixel width of vertical scroll bar
        % Appears to one side of Dialog Panel whenever dialogs fall above
        % or below limits of vertical panel extent.
        ScrollGutter = 4   % pixel gutter between dialog and scroll bar
        ScrollWidth  = 18  % pixel width of scroll bar widget
        % max step for auto-scroll behavior, in pixels
        MaxAutoScrollStepSize = 10
        
        % Engage scroll on drag for a locked panel
        ScrollPanelsOnLockedPanelDrag = false
        
        % Pixel size of splitter bar icon
        SplitterBarSize = [4 40];  % for dialog panel Auto-hide
        SplitterArrowCount = 5;    % for dialog panel Open/close
        
        % Application-defined data
        UserData
        
        % Ordered list of names of initial docked dialogs in panel
        DockedDialogNamesInit = {}
    end
    
    properties (SetAccess=private)
        % DialogPresenter base class has one top-level uipanel (hParent)
        % For DPVerticalPanel, there are two more primary uipanel objects
        % hBodyPanel and hDialogPanel
        %
        % hBodyPanel: handle to uipanel for use by application
        hBodyPanel
    end
    
    properties (Access=protected)
        % State for highlighting the current dialog when hovering
        DialogHoverHighlightLast = []
    end
    
    properties (Access=private)
        % Vector containing the visible subset of handles in Dialogs
        DockedDialogs = dialogmgr.Dialog.empty
        UndockedDialogs = dialogmgr.Dialog.empty

        % hDialogPanel: handle to uipanel for use by dialog panel
        hDialogPanel
        
        hBodySplitter % handle to uicontrol frame
        
        % True if panel is visible
        % Controlled by auto-hide feature
        PanelVisible = true
        
        % Handle to "body too small" text
        hBodyTooSmallTxt
        
        % Handle to "No docked dialogs" text
        hNoDockedDialogs
        
        % Cell-vector of DialogBorder service names that were successfully
        % enabled by the register() method.
        %
        % This list is needed so we can subsequently disable and re-enable
        % services in enableDialogBorderServices() based on the one list of
        % desired services listed in register().
        %
        % Filled in after dialog registration.
        % Order may differ from DialogBorderServiceNamesDesired
        DialogBorderServiceNamesActual = {}
        
        % Maximum set of DialogBorder services requested when dialogs are
        % registered.
        %
        % NOTE: This list MUST correspond to the services engaged in
        %       the register() method (order doesn't matter).
        %       Do NOT change one list without changing the other!
        %
        DialogBorderServiceNamesDesired = {'DialogTitle', ...
            'DialogClose',  'DialogMoveToTop', ...
            'DialogUndock', 'DialogRoller'}

        % Subset of DialogBorderServiceNames that are desired for use
        % when the dialog panel is unlocked and locked.  Order must
        % match service names listed in DialogBorderServiceNamesDesired.
        DialogBorderServiceUnlockedDesired = true(1,5)
        DialogBorderServiceLockedDesired = [true false false false true]
        
        % Computed intersection of Desired and Actual enables
        DialogBorderServiceUnlockedActual = []
        DialogBorderServiceLockedActual = []
        
        % True if mouse is hovering over dialog/body panel splitter
        ResizePanelWidthMouseHover = false
        ResizePanelWidthMouseCache = []
        
        % Mouse-drag dialog shift action
        % -1 = ignore (do not move or shift)
        %  0 = move/reorder one dialog
        %  1 = shift all dialogs
        %  2 = pos shift on dialog drag
        %  3 = neg shift on dialog drag
        DialogShiftAction = 0
        
        % Used only when dragging panel of dialogs (shift+click+drag, etc)
        % Cell-vector of position rectangles for visible dialogs
        DialogShiftStartPos = {}
        
        % Number of pixels past top of panel
        DialogShiftOverTop = 0
        
        hScrollBar       % Handle to uicontrol slider
        hScrollBarAction % Listener to react to slider changes
        hAutoScrollTimer % Timer object for auto-scroll
        hAutoHideTimer   % Timer for auto-hide time out
        
        % Create drag-able outline of info panel
        % Use for when the info panel is dragged to the other side
        % in order to change its location (left/right)
        hPanelOutline
        
        % Function handle to client (application) context menu handler
        % This must be empty or a function handle with the signature:
        %    myHandler(hParent)
        BodyContextMenuHandler = []
        
        % Used for tracking mouse motion over dialog region
        % (1) UNUSED (was: dialog_idx)
        % (2) original bottom-y-coord of dialog (dialog panel ref frame)
        % (3) original mouse position (dialog panel ref frame)
        % (4) last ydelta
        % (5) dragged outside x-limits of dialog panel
        MouseOverDialog = [] % [(0,unused) (a) (b) (c) (d)]
        
        % handle to Dialog under mouse, empty if mouse not over dialog
        MouseOverDialogDlg
        
        % Sum of all dialog vertical extents plus gutters, in pixels
        DialogsTotalHeight = 0
        
        % fractional height of active bar within scroll
        ScrollFraction = 0
        
        % true when scroll bar becomes visible, which is when the scroll
        % fraction is first reduced to less than 100%
        ScrollFractionNewlyVisible = false
    end
    
    methods
        function dp = DPVerticalPanel(hUser)
            % Construct a DPVerticalPanel object.
            %
            % hUser must be a uipanel or uicontainer in which the
            % DPVerticalPanel is rendered.
            %
            % To retrieve this object in an application, use:
            %   dp = dialogmgr.findDialogPresenter(gcf)
            
            % DPVerticalPanel prefers a DBTopBar DialogBorder style
            dp.DialogBorderFactory = @dialogmgr.DBTopBar;
            %dp.DialogBorderFactory = @dialogmgr.DBCompact;
            %dp.DialogBorderFactory = @dialogmgr.DBNoTitle;
            %dp.DialogBorderFactory = @dialogmgr.DBInvisible;
            
            if nargin>0
                init(dp,hUser);
            end
        end
    end
    
    methods
        %
        % Public property set-functions
        %
        function set.AutoHide(dp,val)
            sigdatatypes.checkLogicalScalar(dp,'AutoHide',val);
            dp.AutoHide = val;
        end
        function set.BodyMinWidth(dp,val)
            sigdatatypes.checkFiniteNonNegIntScalar(dp, ...
                'BodyMinWidth',val);
            dp.BodyMinWidth = val;
        end
        function set.BodyMinHeight(dp,val)
            sigdatatypes.checkFiniteNonNegIntScalar(dp, ...
                'BodyMinHeight',val);
            dp.BodyMinHeight = val;
        end
        function set.BodyMinSizeTitle(dp,val)
            sigdatatypes.checkString(dp,'BodyMinSizeTitle',val);
            dp.BodyMinSizeTitle = val;
        end
        function set.ColorLocked(dp,val)
            dialogmgr.checkIsRGBVector(val);
            dp.ColorLocked = val;
        end
        function set.ColorUnlocked(dp,val)
            dialogmgr.checkIsRGBVector(val);
            dp.ColorUnlocked = val;
        end
        function set.DialogVerticalGutter(dp,val)
            sigdatatypes.checkFiniteNonNegIntScalar(dp, ...
                'DialogVerticalGutter',val);
            dp.DialogVerticalGutter = val;
        end
        function set.DockLocation(dp,val)
            dp.DockLocation = sigdatatypes.checkEnum(dp, ...
                'DockLocation',val,{'right','left'});
        end
        function set.DockLocationMouseDragEnable(dp,val)
            sigdatatypes.checkLogicalScalar(dp, ...
                'DockLocationMouseDragEnable',val);
            dp.DockLocationMouseDragEnable = val;
        end
    end
    
    methods (Access=protected)
        buildDialogContextMenu(dp,dp2)
        buildClientContextMenu(dp)
    end
    
    methods (Access=private)
        % Declare private methods
        
        autoHideTimerReset(dp)
        autoHideTimerTimeOut(dp)
        changeDockLocation(dp,newLoc)
        createDialogPanelOutline(dp)
        doAutoScroll(dp,ydelta,ydir,isTimer)
        doAutoScrollShift(dp,shiftPix)
        doShiftDialogs(dp,ydelta)
        doSwapDialogs(dp)
        [pt_panel,isInside,isPastDeadZone,pt_parent] = ...
            getMouseInDialogPanelRefFrame(dp)
        scroll = getScrollWidth(dp)
        names = getDockedDialogNames(dp)
        hideAllDialogs(dp)
        init(dp,hUser)
        moveDialogPanelOutline(dp,currPt)
        resetDialogPanelShift(dp)
        resizeBodySplitter(dp)
        resizeParentPanel(dp)
        resizeScrollBar(dp)
        scrollBarSliderAction(dp)
        setDialogVerticalExtents(dp)
        setptr(dp,style)
        setScrollBarValue(dp)
        updateAutoScrollTimer(dp,timerShouldRun)
        dockAllHiddenDialogs(dp)
        toggleDockedDialogVisibility(dp,dlg)
        togglePanelLock(dp)
    end
end

