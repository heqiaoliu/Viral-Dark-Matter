classdef DialogPresenter < handle
    % Base class for graphical frameworks that offer a visual presentation
    % of a Dialog to a user.   Examples include DialogPanel and
    % DialogTester.
    %
    % To retrieve the DialogPresenter object in an application, use:
    %   dp = get(hParent,'userdata')
    % or
    %   dp = dialogmgr.findDialogPresenter(hfig)

        
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $   $Date: 2010/04/21 21:48:51 $

    properties (SetAccess=private)
        hFig      % handle to app figure (not owned by DialogPresenter)
        hFigPanel % handle to app panel (not owned by DialogPresenter)
        hParent   % handle to top-level uipanel (owned by DialogPresenter)
    end
    
    properties (SetAccess=protected)
        % Dialog object handles
        % Can be empty, a scalar, or a vector of Dialog objects
        %
        % Initialize to empty list of Dialog objects, so we can reference
        % properties, etc, of the empty list without error.
        Dialogs = dialogmgr.Dialog.empty
    end
    
    properties
        % Function handle to a DialogBorder constructor
        % Overwritten by a DialogPresenter subclass as appropriate.
        
        % Default is to use the simplest Compact dialog border style
        DialogBorderFactory = @dialogmgr.DBCompact;
        %DialogBorderFactory = @dialogmgr.DBTopBar;
        %DialogBorderFactory = @dialogmgr.DBNoTitle;
        %DialogBorderFactory = @dialogmgr.DBInvisible;
        
        % Must be public so applications can reuse this
        hContextMenu % handle to reused context menu
    end
    
    properties (GetAccess=protected, Constant)
        % Define name of the AppData field that stores the Dialog handle
        % for use by the DialogPresenter context menu handler
        WidgetContextMenuAppDataName = 'DialogPresenter_ContextMenuHandler';
    end
    
    methods (Sealed)
        function setVisible(dp,state)
            % Change DialogPresenter visibility
            %
            % setVisible(dp) makes the dialog presenter visible.
            %
            % setVisible(dp,tf) makes the presenter visible if flag
            %     tf=true, or invisible if tf=false.
            %
            % setVisible(dp,oo) makes the dialog visible if string oo='on',
            %     or invisible if oo='off'.
            
            if nargin<2
                state = 'on';
            elseif ~ischar(state)
                state = uiservices.logicalToOnOff(state);
            end
            set(dp.hParent,'vis',state);
        end
        
        function initDialogSpecificContextMenuHandler(dp,dlg)
            % Initialize the context menu handler for all widgets created
            % for the specified Dialog object dlg.
            
            widgets = getAllWidgets(dlg.DialogBorder);
            set(widgets,'uicontextmenu',dp.hContextMenu);
            
            % setappdata only takes scalar handles, so we loop:
            for i=1:numel(widgets)
                setappdata(widgets(i),dp.WidgetContextMenuAppDataName, ...
                    dlg.DialogContent);
            end
        end
        
        function initDialogGenericContextMenuHandler(dp,dlg)
            % Initialize the context menu handler for all widgets created
            % for the specified Dialog object dlg.
            
            widgets = getAllWidgets(dlg.DialogBorder);
            set(widgets,'uicontextmenu',dp.hContextMenu);
            
            % setappdata only takes scalar handles, so we loop:
            for i=1:numel(widgets)
                setappdata(widgets(i),dp.WidgetContextMenuAppDataName, ...
                    dp);
            end
        end
        
        function setContextMenuHandler(dp,widget,obj)
            % Unlike initDialogcontexTMenuHandler(), this sets up the
            % context menu for ONE handle object.  Intended to be used to
            % specify context menus for DialogPresenter infrastructure
            % widgets.
            set(widget,'uicontextmenu',dp.hContextMenu);
            setappdata(widget,dp.WidgetContextMenuAppDataName,obj);
        end
        
        function buildContextMenu(dp)
            % Context menu handler for DialogPresenter
            % May be overridden in subclasses
            
            % Dynamically build context menu
            %
            % Assumes "gco" is set to the current graphical object
            % responsible for invoking the context menu.
            %
            % Invoked in response to a right-click within the hParent panel,
            % meaning both the DialogPanel and the BodyPanel
            
            hWidget = gco; % cache the current object handle
            
            % We reuse one context menu for the Dialog Presenter.
            %
            % So our first step must be to clear out any context menu
            % children created from last context menu construction:
            delete(get(dp.hContextMenu,'children'));
            
            % Get object that will handle context menu creation for this
            % widget.
            %
            % Could be a DialogContent object, a DialogPresenter object, or
            % empty.  We will NOT have a DialogBorder or a Dialog, since
            % those can be changed dynamically and the widget is not going
            % to change its use of handles.  So we rule those out.
            %
            % DC,DP: Invoke method provided by these, with 2 args
            % Empty: Invoke method on DP, no 2nd arg
            %        Implies
            % DP:
            % Empty:
            handlerObj = getappdata(hWidget, ...
                dp.WidgetContextMenuAppDataName);
            
            if isempty(handlerObj)
                % Invoke DialogPresenter method for client-app specific
                % context menu invocation.
                buildClientContextMenu(dp);
            else
                % handlerObj is usually a dialogContent object, so an
                % override of buildDialogContextMenu() on a dialogContent
                % object is often invoked.
                %
                % handlerObj may be a DialogPresenter object, when a
                % generic, non-dialog specific context menu is requested.
                buildDialogContextMenu(handlerObj,dp);
            end
        end
    end
    
    methods
        function register(dp,thisDialog) %#ok<INUSD,MANU>
            % Register a Dialog with the DialogPresenter.
            %
            % Overridden by subclasses that need to take action when one
            % or more dialogs register with the presenter.
        end
        
        function dlg = createAndRegisterDialog(dp,dialogContent)
            % Wraps dialogContent with a new instance of a Dialog,
            % containing a new DialogPresenter-specific DialogBorder
            % instance.
            %
            % Dialog visibility is set to OFF by default
            % Be sure to call setVisible(dlg,'on').
            %
            % This is a convenience method for application developers,
            % making it easy to hand off a DialogContent object and have
            % the DialogPresenter take care of the remaining steps to
            % construct and register a dialog.
            
            dlg = dialogmgr.Dialog(dialogContent, makeDialogBorder(dp));
            initialize(dlg,dp);
                
            % Determine which object will handle context menu generation
            % for widgets in the DialogPresenter
            %
            % Get specific handler, typically specified by DialogContent
            if dialogContent.CustomContextHandler
                initDialogSpecificContextMenuHandler(dp,dlg);
            else
                initDialogGenericContextMenuHandler(dp,dlg);
            end
        end
        
        function dlg = getDialog(dp,dc)
            % Return Dialog object child from a DialogPresenter whose ID
            % matches the ID specified in DialogContent object dc.
            %
            % DialogPresenter may have zero, one, or multiple Dialog
            % children. If no matching Dialog object is found, empty is
            % returned.
            
            allIDs = getID(dp.Dialogs);
            dlg = dp.Dialogs(allIDs == dc.ID);
        end
        
        function [hParentForDB,width,height] = getDialogPanelAndSize(dp)
            % Return handle to uipanel that will contain DialogBorder.
            % This may be the DialogPresenter .Panel handle for simple
            % DialogPresenter systems such as DPSingleClient, but is
            % overridden for more complex presenters such as
            % DPVerticalPanel.
            %
            % Optionally return width and height of dialog panel, in pixels.
            
            hParentForDB = dp.hParent;
            if nargout > 1
                ppos = get(hParentForDB,'pos'); % pixels
                width = ppos(3);
                height = ppos(4);
            end
        end
        

        function createBaseContext(dp,dc) %#ok<INUSD,MANU>
            % Create the base DP context menu for the main panel or for a
            % dialog of a DialogPresenter.
            %
            % Intentionally left blank.
        end
        
        function y = isDialogVisible(dp,dialogName) %#ok<INUSD,MANU>
            % True if named dialog is visible
            y = true;
        end
        
        function updatedDialogs = resizeChildPanels(dp,forceUpdate) %#ok<MANU,INUSD>
            % Resize DialogPresenter uipanels responsible for high-level
            % layout management, such as in DPVertPanel, where the dialog
            % panel is embedded within a multi-panel layout.
            %
            % This is NOT intended to resize the dialogs themselves.
            % This gets called, for example, when a roller-shade feature is
            % invoked, or a re-docking of a multi-dialog panel occurs.
            
            % Indicate that there was nothing to do:
            updatedDialogs = false;
        end
    end
    
    methods
        % Mouse methods
        %
        % These need to be public in order to allow these to be directly
        % called by figure mouse event callbacks.
        
        function handled = mouseMove(dp) %#ok<MANU>
            % Returns true if mouse-up event was handled by override.
            %
            % Optionally overridden by subclass.
            handled = false;
        end
        
        function dragFcn = mouseDown(dp) %#ok<MANU>
            % Returns handle to mouse-drag function used to process mouse
            % motion while button is down.  If mouse-down event is not
            % handled, return empty to let caller know that caller should
            % handle event.
            %
            % Optionally overridden by subclass.
            
            dragFcn = [];
        end
        
        function handled = mouseUp(dp) %#ok<MANU>
            % Returns true if mouse-up event was handled by override.
            %
            % Optionally overridden by subclass.
            handled = false;
        end
        
        function handled = mouseScrollWheel(dp,ev) %#ok<INUSD,MANU>
            % Returns true if mouse-up event was handled by override.
            %
            % Optionally overridden by subclass.
            handled = false;
        end
    end
    
    methods (Access=protected)
        function dialogBorder = makeDialogBorder(dp)
            % Create a new instance of a DialogBorder object, used during
            % creation of new Dialog objects for use by DialogPresenter.
            %
            % See createAndRegisterDialog() for typical use.
            
            % This is a "factory" method
            dialogBorder = dp.DialogBorderFactory();
        end
        
        function initPresenter(dp,hUser)
            % First-time initialization DialogPresenter object with a new
            % graphical application context.
            
            % Establish the application parent handle
            [dp.hFigPanel,dp.hFig] = local_verifyHGContext(hUser);
            
            % Create top-level context menu, with no menu items
            %  - Must be the child of a figure
            % Set context menu of parent uipanel
            %
            % This context can be attached to DP widgets that need
            % context menu support
            dp.hContextMenu = uicontextmenu( ...
                'parent',dp.hFig, ...
                'callback',@(h,e)buildContextMenu(dp));
            
            % Create master uipanel that is owned by DialogPresenter and
            % cached in hParent property.
            %
            % hFig is not owned by DialogPresenter, neither is hFigPanel.
            % These are supplied by a client such as a scope framework.
            %
            % Tag of parent uipanel is set so we can find it in
            % situations where we only have a handle to the top-level
            % figure
            %
            % Panel is created INVISIBLE by intention; use setVisible()
            % after all dialogs are added to make it visible.
            %
            % Use static method "dp = findDialogPanel(gcf)" to retrieve
            % the DialogPanel object from a figure handle.
            %   - DialogPanel object is stored in hParent userdata to
            %     support that retrieval
            %
            bg = get(dp.hFigPanel,'backgr');
            dp.hParent = uipanel( ...
                'parent',dp.hFigPanel, ...
                'bordertype','none', ...
                'units','norm', ...
                'backgr',bg, ...
                'vis','off', ...
                'units','pix', ...
                'userdata',dp, ...
                'tag','DialogPresenterParent'); %#ok<*PROP>
            setContextMenuHandler(dp,dp.hParent,dp); % set context menu

            % We must flush this change through HG
            % The invisibility of the panel is important, to suppress the
            % incremental display of graphical elements until they're all
            % ready to be rendered.  Without the flush, the invisible state
            % isn't always fully respected, and some widgets bleed through
            % before an implicit drawnow occurs.  So we flush this now.
            %
            % NOTE: this cannot be a "drawnow expose", it must be a full
            %       "drawnow" flush event for the panel to flush properly.
            drawnow;
        end
        
        function buildDialogContextMenu(dp,~) %#ok<MANU>
            % Optional subclass override for DP to add a context menu.
            %
            % Implementation intentionally blank in base class.
        end

        function buildClientContextMenu(dp) %#ok<MANU>
            % Optional subclass override for DP to add a context menu.
            %
            % Implementation intentionally blank in base class.
        end
        
        function [pt,parentPos] = getPointerLocationInParentRefFrame(dp)
            % Return screen PointerLocation in hParent panel reference
            % frame, in units of pixels.  This position is always updated
            % and is therefore always correct, unlike pointer positions in
            % figures which are incorrect when the cursor is outside the
            % figure.
            %
            % Optionally returns parent position.
            
            % Get mouse position, which is always updated,
            % in pixel units relative to screen reference frame
            % NOTE: hgconvertunits won't work for root units conversion
            root_units = get(0,'units');
            if strcmpi(root_units,'pixels')
                globalPtr = get(0,'pointerlocation');
            else
                set(0,'units','pix');
                globalPtr = get(0,'pointerlocation');
                set(0,'units',root_units);
            end
            
            % Translate cursor point into parent ref frame
            %
            % Get fig and figpanel pos, in pixels units, in fig ref frame
            figPos = getFigPosPixels(dp);
            figPanelPos = getFigPanelPosPixels(dp);
            % Get parent pos, in pixels units, in figpanel ref frame
            parentPos = get(dp.hParent,'pos');
            
            % Translate cursor position
            %
            % We must use an offset of [1,1] for each reference frame
            % subtraction to re-establish the origin
            % Ex: if fig orig = (1,1) and figpanel orig is (1,1),
            %     we don't want (0,0) as the subtraction - we want (1,1)
            %     ... so we must add back [1,1] for figpanel subtraction,
            %     and once again for the parent subtraction.
            pt = globalPtr - figPos(1:2) - figPanelPos(1:2) ...
                - parentPos(1:2) + [3 3];
        end
        
        function pos = getFigPosPixels(dp)
            hf = dp.hFig;
            pos = hgconvertunits(hf, get(hf,'pos'), ...
                get(hf,'units'), 'pixels', hf);
        end
        
        function pt = getFigCurrentPointPixels(dp)
            % Return current point in figure as [x,y] coords, in pixels.
            
            hf = dp.hFig;
            pt = hgconvertunits(hf, [get(hf,'CurrentPoint') 0 0], ...
                get(hf,'units'),'pixels',0);
            pt = pt(1:2);
        end
        
        function pos = getFigPanelPosPixels(dp)
            % Return current hFigPanel position in units of pixels,
            % in LOCAL PARENT ref frame
            
            hFigPanel = dp.hFigPanel;
            pos = hgconvertunits(dp.hFig, get(hFigPanel,'pos'), ...
                get(hFigPanel,'units'),'pixels',get(hFigPanel,'parent'));
        end
        
        function pt = getMouseInParentRefFrame(dp)
            % Return mouse coords in hParent panel reference frame
            % in pixels units.
            %
            % Layout: each indent has new coords relative to its parent
            %
            %  Screen
            %     Figure
            %       (arbitrary lineage)
            %          FigurePanel  (assume no other offsets to fig)
            %          ------------
            %          Parent panel (owned by DialogPresenter)
            %             (children)
            
            % Get mouse (x,y) coords relative to parent container
            
            % Cursor pos, in figure reference frame
            pt_fig = getFigCurrentPointPixels(dp);
            
            % Get figpanel, in pixel units, in LOCAL ref frame
            % xxx BUG: This needs to be in the FIGURE ref frame!
            figpanel_pos = getFigPanelPosPixels(dp);
            
            % Get parent pos, in figpanel ref frame
            parent_pos = get(dp.hParent,'pos'); % in pixels
            
            % Translate cursor point, in parent ref frame
            % We must use an offset of [1,1] for each reference frame
            % subtraction to reestablish the (1,1) origin
            %
            % Ex: if fig orig = (1,1) and figpanel orig is (1,1),
            %     we don't want (0,0) as the subtraction - we want (1,1)
            %     ... so we must add back [1,1] for figpanel subtraction,
            %     and once again for the parent subtraction
            pt = pt_fig-figpanel_pos(1:2)-parent_pos(1:2)+[2 2];
        end
        
        function verifyDialogType(dp,thisDialog) %#ok<MANU>
            % Confirm that a dialog argument to a DialogPresenter method is
            % a valid Dialog handle.
            
            dtype = 'dialogmgr.Dialog';
            if ~isa(thisDialog,dtype)
                % Internal message to help debugging. Not intended to be user-visible.
                error(generatemsgid('InvalidDialogType'), ...
                    'Dialogs must be of type "%s".',dtype);
            end
        end
    end
end

function [hFigPanel,hFig] = local_verifyHGContext(hUser)
% Confirm valid graphical context for DialogPanel system.
%
% hUser must be a handle to a uipanel or uicontainer
% If empty matrix is passed, creates figure and uipanel
% Returns handle to uipanel within figure
%
% Changes figure renderer to zbuffer.

% User specified parent handle
%
% Can be a uipanel or uicontainer
if isempty(hUser) || ~ishghandle(hUser)
    % Internal message to help debugging. Not intended to be user-visible.
    error(generatemsgid('InvalidHandle'), ...
        'Must specify an HG handle as the graphical parent');
end
if ~any(strcmpi(get(hUser,'type'),{'uipanel','uicontainer'}))
    % Internal message to help debugging. Not intended to be user-visible.
    error(generatemsgid('InvalidHandle'), ...
        'HG handle must be a uipanel or a uicontainer');
end
hFigPanel = hUser;
hFig = ancestor(hFigPanel,'figure');

end

