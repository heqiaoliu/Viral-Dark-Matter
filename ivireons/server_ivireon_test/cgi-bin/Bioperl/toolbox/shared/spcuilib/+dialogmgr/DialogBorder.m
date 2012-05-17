classdef DialogBorder < handle
    % Abstract class for constructing objects that represent dialog
    % borders.  DialogBorder provides a common look-and-feel across
    % rendering of dialogs, addressing elements such as a title bar,
    % buttons, and other graphical elements that should be in common
    % across dialogs but depicted on a per-dialog basis.
    %
    % DialogBorder instances are intended to be used with DialogContent to
    % form a complete Dialog. DialogPresenter visualizes Dialog objects.
    %
    % DialogBorder is the dialog-specific border decoration that is in
    % common across multiple dialogs within a dialog presentation.
    % For example, it may provide a title bar on top, or a title bar on
    % bottom, or no title bar, or a compact title that is integrated into
    % the content panel.  It may offer button widgets for close, lock, etc.
    %
    % DialogBorder does NOT provide a figure, or a presentation of multiple
    % dialogs.  That is the responsibility of DialogPresenter.  DP will
    % drive the selection of DialogBorder for all child dialogs within the
    % presenter.
    %
    % Subclasses must implement:
    %   - init()
    %
    % Optionally, subclasses can implement:
    %   - getDialogContentParent()
    %   - update()
    %   - resize()
    %   - mouseOpen()
    %   - hasService()
    %   - enableService()
    %
    % Services provided:
    %
    
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:05 $

    properties
        % If a subclass sets this flag, the panel height is automatically
        % computed based on all dialog widgets.
        AutoPanelHeight = false;
    end
    
    properties (SetAccess=protected)
        % Handle to top-level uipanel allocated and owned by DialogBorder.
        Panel = []  % xxx consider renaming BorderPanel for easier search
    end
    
    properties (Access=protected)
        % Handle to DialogPresenter (grandparent).
        % We do not own this allocation.
        DialogPresenter
        
        % Handle to DialogContent child.
        % We do not own this allocation.
        DialogContent
    end
    
    properties (Access=private)
        % Holds handle to listener on resize event of dialogContent panel
        ContentResizeListener
    end
    
    methods (Sealed)
        function initialize(dialogBorder,dialogPresenter)
            % Create top-level uipanel for dialogBorder
            % This is NOT visible by default, so new DialogBorder objects
            % can be created without requiring them to be visible.
            
            dialogBorder.DialogPresenter = dialogPresenter;
            [hParent,ParentWidth,ParentHeight] = getDialogPanelAndSize(dialogPresenter);
            
            % As defaults, use (1,1) as origin, height=1, and width of
            % parent panel.
            bg = get(hParent,'backgr');
            hPanel = uipanel( ...
                'parent',hParent, ...
                'background',bg, ...
                'units','pixels', ...
                'vis','off',...
                'title','', ...
                'tag','dialog_border_panel',...
                'pos',[1 1 ParentWidth ParentHeight]);
            dialogBorder.Panel = hPanel;
            
            % Call subclass override to create dialogBorder widgets
            createWidgets(dialogBorder);
            
            % Listen to changes in DialogBorder uipanel
            %
            % This could be changed by DialogPresenter, such as a panel
            % width change by DialogPanel
            %
            % xxx Note that the following "self-listener" is unusual,
            %     and we should consider removing it later.
            %
            %    we shouldn't listen to external changes made to our own
            %    widget ... consider a method that others call
            addlistener(hPanel,'SizeChange', ...
                @(h,e)resize(dialogBorder));

        end
        
        function update(dialogBorder,dialogContent)
            % Update dialog border after DialogContent has been rendered.
            % Used for services such as border name update and automatic
            % vertical height computation.
            
            dialogBorder.DialogContent = dialogContent;
            
            % Could be re-parenting an existing dialogContent to a new
            % dialogBorder, which happens when say a docked dialog undocks
            % (content re-parents to a DP_SingleClient, for example) then
            % re-docks (to a DP_VerticalPanel, for example).
            %
            % In this case, the dialogContent had a listener attached to it
            % by the former dialogBorder object.  That former dialogBorder
            % needed to delete its listener on this dialogContent before it
            % got to us here.  If it didn't, executing the updateImpl()
            % below will cause that listener to fire, and the listener will
            % contain a (bogus, or at least unintended) handle to the old
            % dialogBorder object.
            %
            % Assert that the listener is gone before now.
            assert(isempty(dialogBorder.ContentResizeListener));
            
            % dialogBorder has already created its main uipanel,
            % so this is primarily intended to perform a subclass-specific
            % border resize
            updateImpl(dialogBorder,dialogContent);
            
            % Listen to changes in size of dialogContent child panel
            % Border panel must respond similarly
            %
            % We need to retain listener because dialogContent persists
            % while dialogBorder may change on an undock/re-dock.
            %
           dialogBorder.ContentResizeListener = addlistener( ...
                dialogContent.ContentPanel,'SizeChange', ...
                @(hh,ee)resize(dialogBorder));
        end
        
        function setVisible(dialogBorder,state)
            % Show or hide dialog border widgets as well as all dialog
            % content widgets.
            %
            % Effectively hides entire dialog from view, leaving only the
            % graphical framework of the DialogPresenter; as owner of this
            % DialogBorder, the DialogPresenter takes care of its own
            % visibility.
            %
            % state may be 'on' or 'off', or true or false
            if ~ischar(state)
                state = uiservices.logicalToOnOff(state);
            end
            set(dialogBorder.Panel,'vis',state);
        end
        
        function svcsEngaged = engageServices(dialogBorder, svcList)
            % Engage possibly multiple services offered by dialog border by
            % enabling each specified service and attaching a listener to
            % the service event.
            %
            % svcList is a cell-vector of service names and associated
            % actions, specified as {svc1,act1, svc2,act2, ...}, where
            % svc1,svc2, ... are strings representing the name of the
            % service to be enabled, and act1,act2,... are function
            % handles representing actions to be performed by the
            % associated service.
            %
            % It is assumed that each service has an event with the same
            % name as the service itself.  This is not the case for all
            % events offered by all services.  However, many services
            % follow this pattern, making this method convenient in many
            % situations.
            %
            % Returns a cell-vector of service names that were successfully
            % enabled.  Some requested service names may not be supported
            % by a given DialogBorder subclass, and this is not an error.
            
            
            % Note that a given service name is returned if the service
            % could be enabled, regardless of whether a listener could be
            % created for the implied event name.  Therefore, a failure
            % mode could be providing the name of a legitimate service, but
            % the service does not support an event with the same name as
            % the service.  In this case, the service name will be returned
            % but a listener will not have been successfully created.
            
            svcsEngaged = {};
            N = numel(svcList);
            if ~iscell(svcList) || rem(N,2)~=0
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemessageid('invalidformat');
                error(errID, ['Service list must be a cell-vector with ' ...
                    'an even number of entries.']);
            end
            for i = 1:N/2
                name_i = svcList{2*i-1};
                if enableService(dialogBorder,name_i)
                    % Service was enabled
                    svcsEngaged{end+1} = name_i; %#ok<AGROW>
                    action_i = svcList{2*i};
                    if ~isempty(action_i)
                        addlistener(dialogBorder,name_i,action_i);
                    end
                end
            end
        end
        
        function svcEngaged = engageService(dialogBorder, ...
                svcName,eventActionList)
            % Enable one service offered by dialog border and attach a
            % listener to each of possibly multiple events for the service.
            %
            % Unlike engageServices(), this creates listeners associated
            % with a single service.  Therefore, svcName must be a string
            % and cannot be a cell-vector.
            %
            % eventActionList is a cell-vector of event names and
            % associated actions, specified as {ev1,act1, ev2,act2, ...},
            % where ev1,ev2, ... are strings representing event names, and
            % act1,act2,... are function handles representing actions to be
            % performed by the associated service.
            %
            % Returns a string with the service name if it was successfully
            % enabled, or an empty string otherwise.  The name is returned
            % regardless of whether a listener could be created for any of
            % the specified events.
            
            N = numel(eventActionList);
            if ~iscell(eventActionList) || rem(N,2)~=0
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, ['Event/action list must be a cell-vector with ' ...
                    'an even number of entries.']);
            end
            if enableService(dialogBorder,svcName)
                svcEngaged = svcName;
                for i = 1:N/2
                    event_i = eventActionList{2*i-1};
                    action_i = eventActionList{2*i};
                    if ~isempty(action_i) % skip empty actions
                        addlistener(dialogBorder,event_i,action_i);
                    end
                end
            else
                svcEngaged = '';
            end
        end
        
        function detachFromDialogContent(dialogBorder)
            % Remove listeners from dialogContent
            %
            % This is done prior to re-parenting of dialogContent to new
            % dialogBorder
            % Explicitly delete listener to remove it from dialogContent
            if ~isempty(dialogBorder.ContentResizeListener)
                delete(dialogBorder.ContentResizeListener);
                dialogBorder.ContentResizeListener = [];
            end
        end
        
        function finalize(dialogBorder)
            % Clean up before deleting or reusing dialogBorder object
            detachFromDialogContent(dialogBorder);
            
            % Delete panel owned by dialogBorder
            % - This will delete current children of .Panel as well
            %   so be sure dialogContent is already re-parented.
            % - If called from figure close, .Panel may already be deleted
            if ishghandle(dialogBorder.Panel)
                % xxx check on number of graphical children
                %   - should it be exactly one child?
                %   - that is, from dialogContent's .ContentPanel uipanel?
                delete(dialogBorder.Panel);
            end
            dialogBorder.Panel = [];
        end
    end
    
    methods (Access=protected)
        function createWidgets(dialogBorder) %#ok<MANU>
            % The primary responsibility of this method is to create
            % widgets that provide the look-and-feel of the DialogBorder
            % class being implemented.  A top-level uipanel is created by
            % the base class, with its handle in the .Panel property,
            % before init() is executed.
            %
            % The sealed create() method in the base class is responsible
            % for calling init(), as well as creating the .Parent uipanel
            % and other tasks.
            
            % This method intentionally left blank.
        end
        
        function updateImpl(dialogBorder,dialogContent) %#ok<INUSD,MANU>
            % Modify dialogBorder in response to the dialogContent
            
            % This method intentionally left blank.
        end
    end
    
    methods
        % A listener to resize() is automatically created on size changes
        % to the .Panel uipanel.
        %
        % This is NOT abstract, so implementations that do not need this
        % can choose not to provide an override.
        %
        function resize(dialogBorder) %#ok<MANU>
            % This method intentionally left blank.
        end
        
        function delete(dialogBorder)
            finalize(dialogBorder);
        end
        
        % Optionally respond to a double-click (open) event on dialog
        %
        % Invoked by DialogPresenter::mouseDown() method, if a given
        % DialogPresenter chooses to implement mouseDown() and if it checks
        % for a double-click event.
        function mouseOpen(dialogBorder) %#ok<MANU>
            % This method intentionally left blank.
        end
    end
    
    methods
        function y = hasService(dialogBorder,serviceName) %#ok<INUSD,MANU>
            % Respond 'true' to optional services provided
            % By default, there are no optional service in the base class
            % Subclasses will implement service sets and respond 'true' to
            % their name here.
            y = false;
        end
        
        function y = enableService(dialogBorder,serviceName,state) %#ok<INUSD,MANU>
            % Enables a list of optional services, returning TRUE if each
            % service was successfully enabled.  By default, there are no
            % optional services.
            y = false(size(serviceName));
        end
        
        function h = getDialogContentParent(dialogBorder)
            % getDialogContentParent() returns a handle to the graphical
            % parent for DialogContent widgets.  The base class
            % implementation returns the handle in .Panel, which is the
            % top-level uipanel automatically created for every
            % DialogBorder.
            %
            % Override this method when the .Panel property defined in the
            % DialogBorder base class is NOT being used as the immediate
            % parent for DialogContent widgets.
            %
            % Simpler DialogBorder classes parent all DialogContent to the
            % uipanel handle in .Panel, while more complex DialogBorder
            % classes may create a child uipanel that is used as the parent
            % for DialogContent widgets.
            
            h = dialogBorder.Panel;
        end
        
        function hAll = getAllWidgets(dialogBorder)
            % Return vector of handles to all graphical widgets in dialog,
            % including the top-level panel and all children.
            hAll = findobj(dialogBorder.Panel);
        end
        
        function bbox = findChildrenBoundingBox(db)
            % Returns a bounding box containing all child widgets defined
            % in Dialog, where the bounding box is defined as
            %     [xmin ymin width height]
            %
            % Could be empty, a scalar, or a vector
            hChild = get(db.Panel,'children');
            
            % No children? return with defaults
            N = numel(hChild);
            if N==0
                bbox = [0 0 0 0];
                return
            end
            
            % Could be empty, a vector, or a cell-vector of vectors
            % Using a cell around 'pos' guarantees a cell-vector return
            xmin = inf;
            ymin = inf;
            xmax = -inf;
            ymax = -inf;
            for i=1:N
                p_i = hgconvertunits( ...
                    ancestor(db.Panel,'figure'),...
                    get(hChild(i),'pos'), ...
                    get(hChild(i),'units'), ...
                    'pixels',db.Panel);
                xmin  = min(xmin,p_i(1));
                ymin  = min(ymin,p_i(2));
                xmax = max(xmax,p_i(1)+p_i(3)-1);
                ymax = max(ymax,p_i(2)+p_i(4)-1);
            end
            dxmax = xmax-xmin+1;
            dymax = ymax-ymin+1;
            bbox = [xmin ymin dxmax dymax];
        end
    end
end

