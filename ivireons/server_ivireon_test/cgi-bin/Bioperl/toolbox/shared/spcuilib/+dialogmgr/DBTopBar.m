classdef DBTopBar < dialogmgr.DialogBorder
    % Abstract class for dialog border intended to be used with
    % DialogPresenter.
    %
    % Unlike DBCompact, this has a top bar for the dialog name, and
    % optional icons in the top bar that control actions on the dialog.
    % Caller must enable each option by explicit call such as
    % enableDialogClose(), then listen for the associated event such
    % as 'DialogClose'.
    %
    % SERVICES:
    %  hasService(DialogBorder,ServiceName) respond true to the
    %  following ServiceName strings. By default, all optional services
    %  are DISABLED; call enableService() to enable desired services.
    %
    %    ServiceName       EventName
    %    ----------------- -----------------
    %    'DialogTitle'      N/A
    %    'DialogRoller'     N/A
    %    'DialogClose'     'DialogClose'
    %    'DialogMoveToTop' 'DialogMoveToTop'
    %    'DialogUndock'    'DialogUndock'
    %    'DialogDock'      'DialogDock'
    %
    %  DialogDock and DialogUndock are mutually exclusive options.
    %
    %  enableService(DialogBorders,ServiceName,state) will enable or
    %  disable an optional service.

        
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:00 $

    events
        DialogClose % action invoked by user from border icon
        DialogMoveToTop
        DialogUndock
        DialogDock
    end
    
    properties (Constant)
        % Horiz spacing of elements in TitlePanel
        %  [sp GoToTop Roller sp Title Dock/Undock Close sp]
        %     sp: spacer
        %     GoToTop,Roller,Dock/Undock,Close: icons
        %     Title: all remaining width
        HSpace     = 3; % pixels
        IconWidth  = 12;
        IconHeight = 12;
        
        % Graphical Layout:
        %   Panel
        %      gutterTop
        %      hTitlePanel
        %         GoToTopIcon
        %         RollerIcon
        %         hTitleText
        %         Dock/UndockIcon
        %         CloseIcon
        %      gutterMid
        %      hContentPanel
        %         [many widgets]
        %      gutterBot
        GutterTop = 4;
        GutterMid = 2; % pixels
        GutterBot = 2;
        
        % Minimum contrast ratio for color selection
        % of title panel text and icons
        MinimumColorContrast = 0.25  % 25%
    end
    
    properties
        % Background color of title panel
        TitlePanelBackgroundColor = [0 0 .75]*.9 % dull blue
        
        % Color to use for Title text and icons in title panel
        %
        % 'Custom'
        %    Use color specified in property TitlePanelForegroundColor.
        % 'Auto'
        %    Use one of the following colors listed in priority order,
        %    choosing to skip a color if the contrast ratio between this
        %    color and the color specified in TitlePanelBackgroundColor
        %    is less than MinimumColorContrast.
        %      - Background color of graphical parent of DBTopBar, whose
        %        handle is specified in the .Panel property.  The title
        %        panel text and icon color will match the background,
        %        appearing as though they are transparent.
        %      - TitlePanelForegroundColor
        %      - Black or White, whichever offers higher contrast
        TitlePanelForegroundColorSource = 'Auto'
        
        % Custom foreground color for Title text and icons in title panel
        % Defaults to white
        TitlePanelForegroundColor = [1 1 1]
        
        % Initial state of rollerShade is to make dialog content visible
        % (turn off rollerShade)
        RollerShadeHide = false
    end
    
    properties (Access=private)
        % Widget handles
        hTitlePanel
        hTitleText
        
        % Unique to DBTopBar, not in base class:
        % The panel holding dialogContent widgets is not .Panel,
        % which is the top-level panel owned by a DialogBorder.
        % In DBTopBar, .Panel has the title bar in addition to an area for
        % the content widgets.
        % The panel holding dialogContent widgets is .hContentPanel.
        % This is STILL allocated/owned by DBTopBar.
        hContentPanel
        
        hCloseButton
        hMoveToTopButton
        hUndockButton
        hDockButton
        hRollerButton
        
        RollerShadeLayoutInProgress = false;
        
        % Full dialog name, used for resizing, etc
        FullName = ''
        
        % Icon bitmaps
        IconClose
        IconMoveToTop
        IconUndock
        IconDock
        IconRollerOpen
        IconRollerClosed
    end
    
    methods (Access=protected)
        function createWidgets(dialogBorder)
            % One-time initialization of DialogBorder object
            %
            % Create graphical widgets to represent this dialog border
            % DialogBorder uipanel (.Panel) is already created before this
            % is executed - see sealed create() method
            hPanel = dialogBorder.Panel;
            psiz = get(hPanel,'pos');
            ParentWidth = psiz(3);
            
            % Must wait until after .Panel is set in order to create icons,
            % since icons require .Panel to determine transparent color
            createIcons(dialogBorder);
            icon_dx = dialogBorder.IconWidth;
            icon_dy = dialogBorder.IconHeight;
            
            % all optional services that are parented to the title have
            % their visibilities turned off by default.  Caller must
            % enable services individually to make them visible.
            %
            % Summary of visibility of widgets:
            %  Title panel: on
            %      Title string: off
            %      Icons parented to Title panel: off
            %  Content panel: on
            %
            hTP = uipanel( ...
                'parent',hPanel, ...
                'BorderType','none', ...
                'background',dialogBorder.TitlePanelBackgroundColor, ...
                'units','pixels', ...
                'tag','dialog_top_bar_border_panel',...
                'pos',[1 1 ParentWidth 20]);
            dialogBorder.hTitlePanel = hTP;
            
            % Title string is invisible by default
            % No service is explicitly provided
            % Display is governed simply by setting a title string
            %
            % No name is known at create time; this is done at update.
            % 8-pt text is ~11 pixels at 96dpi
            h1 = uicontrol( ...
                'parent',hTP, ...
                'vis','off', ...
                'background',dialogBorder.TitlePanelBackgroundColor, ...
                'foreground',getTitlePanelForegroundColor(dialogBorder), ...
                'pos', [1 1 ParentWidth*0.75 10], ...
                'fontsize',8, ...
                'fontweight','bold', ...
                'enable','inactive', ...
                'style','text', ...
                'horiz','left', ...
                'tag','dialog_panel_title',...
                'string','');
            dialogBorder.hTitleText = h1;
            
            h2 = uicontrol( ...
                'parent',hTP, ...
                'vis','off', ...
                'backgr',dialogBorder.TitlePanelBackgroundColor, ...
                'style','checkbox', ...
                'tooltip','Close', ...
                'callback',@(h,e)closeDialogAction(dialogBorder), ...
                'cdata',dialogBorder.IconClose, ...
                'tag','dialog_close_action',...
                'pos',[1 1 icon_dx icon_dy]);
            dialogBorder.hCloseButton = h2;
            
            % Dock and Undock buttons must be located in the exact same
            % position as each other - they overlap, but are never enabled
            % together.
            h3a = uicontrol( ...
                'parent',hTP, ...
                'vis','off', ...
                'backgr',dialogBorder.TitlePanelBackgroundColor, ...
                'style','checkbox', ...
                'tooltip','Undock', ...
                'callback',@(h,e)undockDialogAction(dialogBorder), ...
                'cdata',dialogBorder.IconUndock, ...
                'tag','dialog_undock_action',...
                'pos',[1 1 icon_dx icon_dy]);
            dialogBorder.hUndockButton = h3a;
            
            h3b = uicontrol( ...
                'parent',hTP, ...
                'vis','off', ...
                'backgr',dialogBorder.TitlePanelBackgroundColor, ...
                'style','checkbox', ...
                'tooltip','Dock', ...
                'callback',@(h,e)dockDialogAction(dialogBorder), ...
                'cdata',dialogBorder.IconDock, ...
                'tag','dialog_dock_action',...
                'pos',[1 1 icon_dx icon_dy]);
            dialogBorder.hDockButton = h3b;
            
            h4 = uicontrol( ...
                'parent',hTP, ...
                'vis','off', ...
                'backgr',dialogBorder.TitlePanelBackgroundColor, ...
                'style','checkbox', ...
                'tooltip','Move to top', ...
                'callback',@(h,e)moveToTopDialogAction(dialogBorder), ...
                'cdata',dialogBorder.IconMoveToTop, ...
                'tag','dialog_move_to_top_action',...
                'pos',[1 1 icon_dx icon_dy]);
            dialogBorder.hMoveToTopButton = h4;
            
            % State of button will be initialized later
            h5 = uicontrol( ...
                'parent',hTP, ...
                'vis','off', ...
                'backgr',dialogBorder.TitlePanelBackgroundColor, ...
                'style','checkbox', ...
                'tooltip','Roller Shade', ...
                'callback',@(h,e)toggleRollerShade(dialogBorder), ...
                'cdata',[], ...
                'tag','dialog_roller_shade_action',...
                'pos',[1 1 icon_dx icon_dy]);
            dialogBorder.hRollerButton = h5;
            
            bg = get(hPanel,'backgr');
            h6 = uipanel( ...
                'parent',hPanel, ...
                'BorderType','none', ...
                'background',bg, ...
                'units','pixels', ...
                'tag','dialog_content_parent_panel',...
                'pos',[1 1 ParentWidth 1]);
            dialogBorder.hContentPanel = h6;
            
            % Set initial states of widgets that have state
            setRollerShade(dialogBorder);
        end
        
        function updateImpl(dialogBorder,dialogContent)
            % Reposition and update all widgets within dialog border, after
            % dialog content has been rendered.
            % Display or hide buttons in border based on options
            
            % Cache border name, so it can be clipped to fit when dialog is
            % resized for width, etc
            dialogBorder.FullName = dialogContent.Name;
            
            resize(dialogBorder);
            %setAutoContentHeight(dialogBorder);
        end
    end
    
    methods
        function set.TitlePanelForegroundColorSource(h,val)
            h.TitlePanelForegroundColorSource = ...
                sigdatatypes.checkEnum(h, ...
                'TitlePanelForegroundColorSource', ...
                val,{'Auto','Custom'});
        end
        
        function resize(dialogBorder)
            % Resize the top-level panel after a change in dialog size.
            
            if ~dialogBorder.RollerShadeLayoutInProgress
                doLayout(dialogBorder);
                
                % Layout establishes proper border width.
                % Only after that can we update the border name,
                % since it changes based on border width.
                updateBorderName(dialogBorder);
            end
        end
        
        function h = getDialogContentParent(dialogBorder)
            % Returns the handle to the panel that is the parent of all
            % widgets for this dialog.  This is a service typically called
            % by DialogContent to identify the graphics handle to use as
            % its parent.
            %
            % This is a method override from DialogBorder base class,
            % needed due to a more complex DialogBorder configuration.
            % The base class .Panel handle is NOT the parent for
            % dialogContent widgets.
            h = dialogBorder.hContentPanel;
        end
        
        function y = hasService(dialogBorder,serviceName) %#ok<MANU>
            % Responds 'true' to all optional services that are provided by
            % DBTopBar.
            %
            % serviceName may be the name of a single service, or a
            % cell-vector of service names.
            allServices = {'dialogtitle', ...
                'dialogclose', 'dialogmovetotop',  ...
                'dialogundock','dialogdock','dialogroller'};
            if ischar(serviceName)
                serviceName = {serviceName};
            end
            y = false(size(serviceName));
            N = numel(serviceName);
            for i=1:N
                if any(strcmpi(serviceName{i},allServices))
                    y(i) = true;
                end
            end
        end
        
        function y = enableService(dialogBorder,serviceName,state)
            % Show/hide action buttons in DialogBorder objects.
            % serviceName is a cell-vector of service names, or a string
            % containing one service name.
            %
            % state may be true or false, and must be the same size as
            % serviceName or a scalar.
            %
            % Useful when a DialogPresenter disables modifications of child
            % dialogs, such as when DialogPanel locks the panel.
            
            if ischar(serviceName)
                serviceName = {serviceName};
            end
            y = false(size(serviceName));
            if nargin<3
                state = true(size(serviceName));
            elseif isscalar(state)
                state = repmat(state,size(serviceName));
            end
            N = numel(serviceName);
            for i = 1:N
                y(i) = true; % assume we could enable the service
                ena = uiservices.logicalToOnOff(state(i));
                switch lower(serviceName{i})
                    case 'dialogtitle'
                        enableDialogTitle(dialogBorder,ena);
                    case 'dialogmovetotop'
                        enableDialogMoveToTop(dialogBorder,ena);
                    case 'dialogclose'
                        enableDialogClose(dialogBorder,ena);
                    case 'dialogundock'
                        enableDialogUndock(dialogBorder,ena);
                    case 'dialogdock'
                        enableDialogDock(dialogBorder,ena);
                    case 'dialogroller'
                        enableDialogRoller(dialogBorder,ena);
                    otherwise
                        y(i) = false; % Service not implemented
                end
            end
        end
        
        function mouseOpen(dialogBorder)
            % Respond to mouse open (double-click) event from
            % DialogPresenter.  This is mapped to roller-shade action.
            
            if 1 % xxx only execute if roller-shade service enabled
                toggleRollerShade(dialogBorder);
            end
        end
        
        function toggleRollerShade(dialogBorder)
            % Toggle roller-shade state
            setRollerShade(dialogBorder,~dialogBorder.RollerShadeHide);
        end
        
        function setRollerShade(dialogBorder,hide)
            % Optionally sets new rollerShade state.
            % Set hide=true to close (hide) all DialogContent
            %
            % Updates button icon to reflect current rollerShade state.
            %
            % No event is associated with this service; all its actions are
            % carried out within the class.
            
            % Optionally change state
            if nargin>1
                dialogBorder.RollerShadeHide = hide;
            end
            % React to new state
            if dialogBorder.RollerShadeHide
                icon = dialogBorder.IconRollerClosed;
            else
                icon = dialogBorder.IconRollerOpen;
            end
            set(dialogBorder.hRollerButton,'cdata',icon);
            
            dialogBorder.RollerShadeLayoutInProgress = true;
            hCP = dialogBorder.hContentPanel;
            
            if dialogBorder.RollerShadeHide
                % Hide content of visible panel
                % We take care to make things invisible in order to reduce
                % "flash" of visible elements while changing panel size.
                
                % Hide entire dialogBorder Panel until titlepanel is
                % repositioned
                hP = dialogBorder.Panel;
                set(hP,'vis','off');
                drawnow;
                
                % Hide ContentPanel as well
                set(hCP,'vis','off');
                
                % Get actual height of dialogContent's top-level panel.
                %
                % If we ask ourselves (dialogContent) for the height of our
                % ContentPanel widget, we will see it's 1 pixel high since
                % roller-shade is engaged.  We need the actual dialogContent
                % height here, however, so that won't do.
                pos = get(dialogBorder.DialogContent.ContentPanel,'pos');
                cp_dy = pos(4);
                %
                % We do NOT want to do this, as we'll see 1 pix for the
                % dialogBorder height if roller-shade is engaging
                %pos = get(hCP,'pos');
                %cp_dy = pos(4); % height of content panel
                
                % Change position of Panel to bring its bottom upward
                % toward top, effectively rolling it "up"
                pos = get(hP,'pos');
                pos(2) = pos(2)+cp_dy;
                pos(4) = pos(4)-cp_dy;
                set(hP,'pos',pos);
                
                % Move title panel downward, in pixel units, to the new top
                % of dialog.  Its coords are relative to the bottom of
                % Panel, which has now been moved up.
                %
                % See doLayout() for vertical spacing requirements.
                % Summary:
                %  -Keep GutterBot+gutterMid below TitlePanel
                %  -We are just eliminating the body content
                % We could remove the Bot and Mid gutters as well, but the
                % title bar gets a bit too short and is a bit more
                % difficult to grab.
                %
                hTP = dialogBorder.hTitlePanel;
                pos = get(hTP,'pos');
                pos(2) = 1+dialogBorder.GutterBot+dialogBorder.GutterMid;
                set(hTP,'pos',pos);
                
                % Restore visibility of Panel
                % Leave ContentPanel visibility turned off, which is the
                % expected behavior when engaging roller-shade.
                set(hP,'vis','on');
                
                % A call to doLayout is NOT needed.
                % We've done the layout update ourselves here, and this
                % produces a reasonably flash-free update.
            else
                % Show content of visible panel
                %
                % Not much we can do here to reduce flash, since
                % DialogPresenter would need to allocate additional space
                % below this dialog first, before we turn on our content.
                %
                % We rely on deferred drawnow to keep things reasonably
                % flash-free.
                
                % Change vis of DialogContent uipanel Dialog
                set(hCP,'vis','on');
                
                % update layout of dialogBorder
                % doLayout responds to the visibility of ContentPanel.
                doLayout(dialogBorder,2);
            end
            
            % Send message to parent DialogPresenter that dialogBorder
            % height has changed. DP may need to update any scroll bars,
            % etc.
            %
            % "true" flag forces the update, since the change of DB
            % content visibility is invisible to resizeChildPanels().
            resizeChildPanels(dialogBorder.DialogPresenter,true);
            
            % We are done updating roller-shade layout
            % Release the semaphore
            dialogBorder.RollerShadeLayoutInProgress = false;
        end
    end
    
    methods (Access=private)
        % Enable optional services by making buttons visible in top bar
        function enableDialogMoveToTop(dialogBorder,vis)
            set(dialogBorder.hMoveToTopButton,'vis',vis);
        end
        
        function enableDialogClose(dialogBorder,vis)
            set(dialogBorder.hCloseButton,'vis',vis);
        end
        
        function enableDialogUndock(dialogBorder,vis)
            set(dialogBorder.hUndockButton,'vis',vis);
        end
        
        function enableDialogDock(dialogBorder,vis)
            set(dialogBorder.hDockButton,'vis',vis);
        end
        
        function enableDialogRoller(dialogBorder,vis)
            set(dialogBorder.hRollerButton,'vis',vis);
        end
        
        function enableDialogTitle(dialogBorder,vis)
            set(dialogBorder.hTitleText,'vis',vis);
        end
        
        function updateBorderName(dialogBorder)
            % Trim name to fit available space in TitlePanel
            % Append '...' to name when trimming characters.
            
            % Get horizontal space available for name in title bar
            % Take all remaining width after icons, spacers, etc
            tpPos = get(dialogBorder.hTitlePanel,'pos');
            width = tpPos(3);
            targetWidth = width - 3*dialogBorder.IconWidth ...
                - 4*dialogBorder.HSpace;
            
            % Get full name and length of dialog
            hTitle = dialogBorder.hTitleText;
            fullname = dialogBorder.FullName;
            
            % Trim name to fit space, using at least 1 char of name
            name = fullname;
            Nchars = numel(name);
            trimmed = false;
            while 1
                % Determine rendered width of name
                set(hTitle,'string',name);
                tt_ext = get(hTitle,'extent');
                actualWidth = tt_ext(3);
                if (actualWidth < targetWidth) || (Nchars<2)
                    break
                end
                % Extent of title as defined exceeds available width
                % for title.  Shrink title by removing chars, and adding
                % "..." to it
                Nchars = Nchars-1;
                name = [fullname(1:Nchars) '...'];
                trimmed = true;
            end
            
            % If we trimmed name, add a tooltip to show full name
            if trimmed
                tip = fullname;
            else
                tip = '';
            end
            set(hTitle,'tooltip',tip);
        end
        
        function doLayout(dialogBorder,rollerChange)
            % Update layout of widgets in dialogBorder.
            %
            % rollerChange:
            %   0 = no change
            %   1 = hiding content
            %   2 = un-hiding content
            
            % Conceptual layout/parenting of panels in this dialogBorder
            %   Panel
            %      gutterTop
            %      hTitlePanel
            %         --sp,MoveToTopButton,RollerButton,sp,
            %           hTitleText,Dock/UndockButton,CloseButton,sp--
            %      gutterMid
            %      hContentPanel
            %         [many widgets]
            %      gutterBot
            %
            % These gutters are between the overall panel, the content,
            % and the border title.  They are NOT used within the border
            % TitlePanel itself.
            gutterTop = dialogBorder.GutterTop;
            gutterMid = dialogBorder.GutterMid;
            gutterBot = dialogBorder.GutterBot;
            
            % Within the TitlePanel, we leave some vertical gutter
            % and need to assess total vertical extent:
            %       |tpGutterTop
            %       |max(iconHeight,textHeight)
            %       |tpGutterBot
            tpGutterTop = 1; % pixels
            tpGutterBot = 1;
            
            % Horiz spacing of elements in TitlePanel:
            %  [sp MoveToTop Roller sp Title Dock/Undock Close sp]
            %     sp: spacer
            %     MoveToTop,Roller,Dock/Undock,Close: icons
            %     Title: all remaining width
            sp      = dialogBorder.HSpace; % pixels
            icon_dx = dialogBorder.IconWidth;
            icon_dy = dialogBorder.IconHeight;
            
            % If rollerChange arg is unspecified, assume we're not opening
            % a roller shade (0) and thus no change to content visibility
            % when laying out this border.
            if nargin<2
                rollerChange = 0;
            end
            
            % The top-level panel of a dialogBorder is resized by
            % DialogPresenter to proper width  - get that width:
            %
            % xxx unhappy with this
            %   - shouldn't let DP parent directly set the DB pos
            %   - we should give DP an API for changing DB width
            panelPos = get(dialogBorder.Panel,'pos');
            panelWidth = panelPos(3);
            
            % Get pixel height needed for dialog content
            %
            % If dialogBorder panel is invisible,
            %   or dialogContent is not yet allocated,
            %   or rollerChange==1 (hiding content),
            %     make this 1 pixel high.
            % Otherwise,
            %   get vertical extent of our ContentPanel
            %
            dc = dialogBorder.DialogContent; % dialogContent object
            cp = dialogBorder.hContentPanel; % dialogBorder uipanel
            borderPanelInvis = strcmpi(get(cp,'vis'),'off');
            if isempty(dc) || borderPanelInvis || (rollerChange==1)
                cp_dy = 1; % height in pixels
            else
                pos = get(dc.ContentPanel,'pos');
                cp_dy = pos(4); % height in pixels
            end
            
            % Set pos of TitleText within TitlePanel
            %
            % TitleText is positioned within TitlePanel, so its x,y
            % coords are relative to the TitlePanel ref frame
            %
            % This is a generic position, not based on the actual string
            % used for the name string displayed within the border.  That
            % is handled in another method called later.
            %
            % x-coord for Title starts after 2 sp's and 2 icons
            % Remember that 1 is the origin
            %   [sp MoveToTop Roller sp Title Dock/Undock Close sp]
            tt_x = 1 + 2*sp + 2*icon_dx;
            tt_y = 1+tpGutterBot;
            
            otherWidth = 3*sp + 4*icon_dx;
            tt_dx = panelWidth - otherWidth; % take all remaining width
            % Get title text height in pixels
            % The extent does not yield a useful result (much too large)
            % tt_ext = get(dialogBorder.hTitleText,'extent');
            % tt_dy = tt_ext(4);
            % Instead, we compute the height here
            % The "2+" is an heuristic offset for HG to fully render text
            % vertically without cutoff.  HG adds 2 more pixels "above" the
            % text than are needed.
            tt_dy = 2+ceil(get(0,'screenpixelsperinch')*get(dialogBorder.hTitleText,'fontsize')/72);
            %tt_dy = 14; % xxx title text height in pixels
            %
            % xxx the following causes title bar to flash each time a width
            % resize occurs.  If even just the width differs, flash occurs.
            set(dialogBorder.hTitleText, ...
                'pos',[tt_x tt_y tt_dx tt_dy]);
            
            % Set pos of MoveToTop icon within TitlePanel
            % Set vertically centered on text
            tb_x = 1+sp;
            % tb_y = 2;  % 1=origin, +1 for a small starting gutter
            % tb_y = tt_y + (tt_dy-icon_dy)/2; % icon y centered on text
            tb_y = tt_y + tt_dy-1 - icon_dy;
            tb_pos = [tb_x tb_y icon_dx icon_dy];
            set(dialogBorder.hMoveToTopButton,'pos',tb_pos);
            
            tb_pos(1) = 1+sp+icon_dx;
            set(dialogBorder.hRollerButton,'pos',tb_pos);
            
            % Get width of uipanel border decoration, in pixels
            gbw = dialogmgr.getGraphicalBorderWidth(dialogBorder.Panel); % 3

            % Set pos of Close icon within TitlePanel
            tb_pos(1) = panelWidth-sp-icon_dx - gbw;
            set(dialogBorder.hCloseButton,'pos',tb_pos)
            
            % Set pos of Dock and Undock icon within TitlePanel
            % Both go in the same spot, so only one of these services
            % should be enabled at a time.
            % This spot is "one more icon width" to left of close button
            tb_pos(1) = tb_pos(1)-icon_dx;
            set([dialogBorder.hUndockButton dialogBorder.hDockButton], ...
                'pos',tb_pos)
            
            % Set pos of hTitlePanel
            %
            % Only execute this if we are NOT in the midst of "hiding"
            % (roller-shade active)
            % - If we're hiding content, title panel is already in the
            %   right position, which is at the TOP of the panel
            %   location.  If we executed this code, it's not an
            %   efficiency issue --- it would move the title bar to the
            %   BOTTOM of the dialog, producing flash
            %
            % Within the TitlePanel, we leave some vertical gutter
            % and need to assess total vertical extent:
            tp_dy = tpGutterTop + max(icon_dy,tt_dy) + tpGutterBot;
            
            if rollerChange~=1
                tp_x   = 1;
                tp_y   = 1 + gutterBot + cp_dy + gutterMid;
                tp_dx  = panelWidth - 2*gbw; % subtract two panel borders
                tp_pos = [tp_x tp_y tp_dx tp_dy];
                set(dialogBorder.hTitlePanel,'pos',tp_pos);
            end
            
            % Set position of Panel
            if rollerChange~=1
                % xxx may want to put this only in init code
                p_dy = gutterBot + cp_dy + gutterMid + tp_dy + gutterTop;
                % orig pos: [1 1 cpWidth p_dy]
                ppos = [panelPos(1:3) p_dy];
            else
                % roller-shade is in the midst of hiding content
                % roll the panel UP
                
                p_dy = gutterBot + 0 + gutterMid + tp_dy + gutterTop;
                % orig pos: [1 1 cpWidth p_dy]
                ppos = [panelPos(1) 1+cp_dy panelPos(3) p_dy];
            end
            set(dialogBorder.Panel,'pos',ppos);
        end
        
        function closeDialogAction(dialogBorder)
            % Close button action
            notify(dialogBorder,'DialogClose');
        end
        
        function moveToTopDialogAction(dialogBorder)
            % Move to top button action
            notify(dialogBorder,'DialogMoveToTop');
        end
        
        function undockDialogAction(dialogBorder)
            % Undock button action
            notify(dialogBorder,'DialogUndock');
        end
        
        function dockDialogAction(dialogBorder)
            % Dock button action
            notify(dialogBorder,'DialogDock');
        end
        
        function setAutoContentHeight(dialogBorder)
            % xxx NOT YET DONE:
            
            if dialogBorder.AutoPanelHeight
                % A very basic attempt to help the subclass
                % - we reset the pixel height, plus a little room at top
                % - we do NOT touch the widget offsets, so we cannot make
                %   room for a bottom gutter
                % - more to do in the future...
                hPanel = dialogBorder.Panel;
                bbox = findChildrenBoundingBox(dialogBorder);
                ppos = get(hPanel,'pos');
                
                % Compute extra vertical height needed for
                % comfortable visual spacing
                panelTextHeight = 10; % pixels
                vertGutter = dialogBorder.ChildGutterInnerTop + ...
                    dialogBorder.ChildGutterInnerBottom;
                yExtra = panelTextHeight + vertGutter;
                
                % Reset height
                ppos(4) = bbox(4) + yExtra;
                set(hPanel,'pos',ppos);
            end
            
        end
        
        function c1 = getTitlePanelForegroundColor(dialogBorder)
            % Return color to use for foreground text of TitlePanel.
            % Returns either a "transparent" color, which is the background
            % color of the DialogBorder, or a custom color depending on
            % the color enumeration.
            
            switch lower(dialogBorder.TitlePanelForegroundColorSource)
                case 'auto'
                    % Try panel background color
                    % If contrast too low, try custom foreground color
                    % Otherwise, use better of white or black
                    
                    % Compute contrast as sum of square differences (L2)
                    %   Max is 3 (white vs black) -> scale to 1.0
                    %   Min is 0
                    %
                    % Contrast threshold, in range [0,1]
                    thresh = dialogBorder.MinimumColorContrast;
                    
                    % Try automatic color (.Panel background color)
                    c1 = get(dialogBorder.Panel,'background');
                    % Compare to title panel background, which is known
                    c2 = dialogBorder.TitlePanelBackgroundColor;
                    contrast = (c1-c2)*(c1-c2)'/3;
                    if contrast < thresh
                        % Try custom foreground color
                        c1 = dialogBorder.TitlePanelForegroundColor;
                        contrast = (c1-c2)*(c1-c2)'/3;
                        if contrast < thresh
                            % Try white
                            cw = [1 1 1]; contrastw = (cw-c2)*(cw-c2)'/3;
                            ck = [0 0 0]; contrastk = (ck-c2)*(ck-c2)'/3;
                            if contrastw < contrastk
                                % contrast with white not as good as black
                                % Choose black
                                c1 = ck;
                            else
                                % Choose white
                                c1 = cw;
                            end
                        end
                    end
                otherwise % 'custom'
                    % use specified foreground color
                    c1 = dialogBorder.TitlePanelForegroundColor;
            end
        end
        
        function createIcons(dialogBorder)
            % Create icons for use in title panel
            % All icons are created in the title panel foreground color
            
            bg = dialogBorder.TitlePanelBackgroundColor;
            fg = getTitlePanelForegroundColor(dialogBorder);
            
            % Close icon
            % - an "x" in a box, 8x8
            x = zeros(8);
            x((0:6)*8 + (1:7))=1; % diagonal
            x((1:7)*8 + (1:7))=1; % diagonal offset by 1
            x((0:6)*8 + (7:-1:1))=1; % reverse diagonal
            x((1:7)*8 + (7:-1:1))=1; % reverse diagonal offset by 1
            dialogBorder.IconClose = ...
                dialogmgr.createIconFromColorFraction(x,bg,fg);
            
            % Move to top icon
            % - this is a toggle on/off icon
            % - upward-pointing arrow with a horizontal line at top
            % - set in 2:8 x 2:8 of 9x9 square
            % - border pixels set/unset when option turned on/off
            %            x = zeros(9);
            %            x(2,2:8) = 1;      % 2nd row, no left/right edge
            %            x(2:8,5) = 1;      % middle column, no top edge
            %            x([14 22 30]) = 1; % left slant of upward arrow
            %            x([]) = 1; % right slant of upward arrow
            %            x(5:-1:2,2:5) = 1; % left slant of upward arrow
            %            x(3:5,6:8) = 1;    % right slant of upward arrow
            x =[0 9 9 9 9 9 9 9 0 ;
                0 0 0 5 9 5 0 0 0 ;
                0 0 5 9 9 9 5 0 0 ;
                0 5 9 0 9 0 9 5 0 ;
                0 9 5 0 9 0 5 9 0 ;
                0 0 0 0 9 0 0 0 0 ;
                0 0 0 0 9 0 0 0 0 ;
                0 0 0 0 9 0 0 0 0 ;
                0 0 0 0 9 0 0 0 0 ] ./ 9;
            dialogBorder.IconMoveToTop = ...
                dialogmgr.createIconFromColorFraction(x,bg,fg);
            
            % Undock icon
            x = [1 1 1 1 1 1;
                 0 0 0 1 1 1;
                 0 0 1 1 1 1;
                 0 1 1 1 0 1;
                 0 1 1 0 0 1;
                 0 1 0 0 0 1;
                 0 0 1 0 0 0];
            dialogBorder.IconUndock = ...
                dialogmgr.createIconFromColorFraction(x,bg,fg);
            
            % Dock icon
            x = [0 0 0 0 0 0 1;
                 0 1 1 1 0 0 1;
                 1 0 1 1 1 0 1;
                 0 0 0 1 1 1 1;
                 0 0 0 0 1 1 1;
                 0 1 1 1 1 1 1];
            dialogBorder.IconDock = ...
                dialogmgr.createIconFromColorFraction(x,bg,fg);
            
            % Roller shade open/close icons
            [dialogBorder.IconRollerOpen, ...
                dialogBorder.IconRollerClosed] = ...
                dialogmgr.iconsTogglePanel(bg,fg);
        end
    end
end

