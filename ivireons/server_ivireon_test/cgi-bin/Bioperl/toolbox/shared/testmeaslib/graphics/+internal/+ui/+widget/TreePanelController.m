classdef TreePanelController < handle
    %TreePanelCONTROLLER A controller for creating trees     
    %
    % How to use TreePanelController:
    % -- TO be Written
    %
    
    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $ $Date: 2010/05/10 17:38:24 $
    
    properties(SetAccess='private', GetAccess='private')
        % The java TreePanel object containing the table.
        TreePanel = [];
        
        % Array of listeners to callbacks. The listeners are put in this
        % Array to prevent them from being deleted when they go out of
        % scope.
        WidgetListeners = [];
    end
    
    properties (Constant)
        % In order to add a separator to the context menu item, this
        % constant string should be passed in as an argument to
        % setMenuItems.
        MENU_SEPARATOR = 'TreePanelController.Separator';
        
        % In order to add a Cut,Copy,Paste items to the context menu item,
        % this constant string should be passed in as an argument to
        % setMenuItems. The ClipboardRequested event is posted each time
        % user selects the cut,copy,paste menu items.
        CUT_COPY_PASTE = 'TreePanelController.CutCopyPaste';
    end
    
    events
        % The event data for all these events is an object of class
        % systest.event.GenericEventData . The event data is a structure
        % contained in the Data field of the class. The fields of the
        % structure depend on the event.
        
        % This event is posted each time user selects a new node in the tree.
        % The event data is structure containing following fields -
        % SelectedNodes - cell array of fully-qualified paths of the nodes
        % selected in the tree. A fully qualified path of the node in the
        % tree contains the names of ancestor nodes separated by '.' period
        % characters.
        NodesSelected;
        
        % This event is posted each time user edits a node in the tree.
        % The event data is structure containing following fields -
        % NodePath - fully qualified path of the node. A fully qualified
        % path of the node in the tree contains the names of ancestor nodes
        % separated by '.' period characters.
        % OldName - old name of the node. This name is contained in the
        % NodePath field as well.
        % NewName - new name of the node.
        NodeEdited;
                
        % This event is posted each time user selects a menu item. If user
        % selects cut, copy or paste from the menu, a ClipboardRequested
        % event is sent instead of MenuSelected event. 
        % The event data is structure containing following fields -
        % SelectedMenuName - Name of the selected menu item. If the
        % selected menu item is a cascading menu(i.e. added using
        % addCascadingMenyu) then the selected menu name is the name of the
        % parent menu concatenated to the name of the sub-menu separated by
        % a period.
        MenuSelected;
        
        % This event is posted each time user presses delete key
        % The event data is structure containing following fields -
        % NodePath - fully qualified path of the node. A fully qualified
        % path of the node in the tree contains the names of ancestor nodes
        % separated by '.' period characters
        NodeDeletionRequested;
        
        % This event is posted each time user presses a key while the
        % tree has focus
        % The event data is structure containing following fields -
        % NodePath - fully qualified path of the node. A fully qualified
        % path of the node in the tree contains the names of ancestor nodes
        % separated by '.' period characters.
        % KeyChar - character of the key pressed, e.g. 'a', 'e' etc.
        % KeyText - a friendly description of the keys, e.g. 'Delete' for
        % delete etc.
        % Modifiers - contains string if modifier is selected as part of key
        % event - 'Alt', 'Ctrl', 'Shift' etc.
        KeyPressed;
        
        
        % This event is posted each time user presses the key combination
        % for cut, copy, paste or selects cut, copy, paste menu item from
        % context menu(when present).
        % The event data is structure containing following fields -
        % NodePath -  fully qualified path of the node.
        % Type - a string 'Cut', 'Copy' or 'Paste' indicating the action
        % invoked by the user.
        ClipboardRequested;
    end
    % ---------------------------------------------------------------------
    methods(Access = 'public')
        function obj = TreePanelController(rootNode, componentName)
            % OBJ = TREEPANELCONTROLLER(ROOTNODE, COMPONENTNAME)
            %  creates a tree rooted at ROOTNODE
            %
            % ROOTNODE the node at the root of the tree, each node inside
            % rootnode is added to the tree. If the name of the rootNode is
            % empty, then the root node is not visible.
            %
            % COMPONENTNAME is a string used to name java components. The
            % panel and tree will be given the following suffix -
            %        JavaComponent = [componentName '.panel']
            %        Tree          = [componentName '.tree']
            
            assert(isa(rootNode, 'internal.ui.widget.TreeNode'),...
                    'rootNode must be a object of internal.ui.widget.TreeNode class.');
                
            assert(ischar(componentName) , 'componentName must be string.');
            
            % convert to java node.
            javaRootNode =  obj.createJavaNode(rootNode, []); % obj.createJavaRootNode(rootNode);
            
            % create the java object.
            obj.TreePanel = com.mathworks.toolbox.testmeas.tmswing.tree.TreePanel(javaRootNode, componentName);
            
            % register listeners to events of the java tree so that it can
            % be converted to matlab events.
            callback = handle(obj.TreePanel.getNodeSelectedCallback());
            listener = handle.listener(callback, 'delayed', @(src, data) handleNodeSelected(obj, data.JavaEvent));
            obj.WidgetListeners = listener;
            
            callback = handle(obj.TreePanel.getNodeEditedCallback());
            listener = handle.listener(callback, 'delayed', @(src, data) handleNodeEdited(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
            
            callback = handle(obj.TreePanel.getKeyPressedCallback());
            listener = handle.listener(callback, 'delayed', @(src, data) handleKeyPressed(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
            
            callback = handle(obj.TreePanel.getMenuSelectedCallback());
            listener = handle.listener(callback, 'delayed', @(src, data) handleMenuSelected(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
            
            callback = handle(obj.TreePanel.getClipboardCallback());
            listener = handle.listener(callback, 'delayed', @(src, data) handleClipboardRequested(obj, data.JavaEvent));
            obj.WidgetListeners(end + 1) = listener;
        end
        
        function javaComponent = getJavaComponent(obj)
            % JAVACOMPONENT GETJAVACOMPONENT - returns the java component
            % containing the tree object.
            
            javaComponent = obj.TreePanel.getPanel();
        end
        
        function setMenuNames(obj, menuNames)
            % SETMENUNAMES(MENUNAMES) adds a right-click menu to the tree
            % for each string in MENUNAMES. A MenuSelectedEvent is
            % posted each time a menu is selected
            %
            % In order to add a seperator, use the constant MENU_SEPERATOR
            % in the list of MENUNAMES.
            %
            % MENUNAMES a cell array of menu strings
            
            assert(iscellstr(menuNames), 'menuNames must be a cell array of strings.');
            
            menuJList = java.util.ArrayList;
            
            for idx = 1 : length(menuNames)
                menuJList.add(menuNames{idx});
            end
            
            % tell the tree panel to create the menu
            obj.TreePanel.setMenuNames(menuJList,...
                internal.ui.widget.TreePanelController.MENU_SEPARATOR,...
                internal.ui.widget.TreePanelController.CUT_COPY_PASTE);
        end
        
        function addCascadingMenu(obj, parentMenuName, subMenuNames)
            % ADDCASCADINGMENU(OBJ, PARENTMENUNAME, SUBMENUNAMES) adds
            % submenus to the menu item with name PARENTMENUNAME
            %
            % PARENTMENUNAME the name of the menu item to which sub-menu
            % should be added
            %
            % SUBMENUNAMES is the cell array of sub-menu names.
            
            assert(ischar(parentMenuName), 'parentMenuName must be a string.');
            assert(iscellstr(subMenuNames), 'subMenuNames must be a cell array of strings.');
            
            menuJList = java.util.ArrayList;
            
            for idx = 1 : length(subMenuNames)
                menuJList.add(subMenuNames{idx});
            end
            
            % tell the tree panel to add the sub-menu
            obj.TreePanel.addCascadingMenu(parentMenuName, menuJList);
        end
        
        function enableMenu(obj, menuNames, isEnabled)
            % ENABLEMENU(OBJ, MENUNAMES, ISENABLED) enable or disables
            % all the right-click menu items with name in MENUNAMES item
            % When a menu is disabled, it cannot be selected by the users.
            % If a right-click menu item is not present or a menuItem with
            % name in MENUNAMES does not exist this method returns without
            % any error.
            %
            % MENUNAMES cell array of menu item names that are being changed
            % ISENABLED true to enable the menu, false to disable the menu.
            
            assert(iscellstr(menuNames)...
                && islogical(isEnabled)...
                && length(menuNames) == length(isEnabled),...
                'menuName must be a cell array of strings. isEnabled must be logical');
            
            javaMethodEDT('enableMenus', obj.TreePanel, menuNames, isEnabled);
        end
        
        function setSelectedNodes(obj, selectedNodes)
            % SETSELECTEDNODES(OBJ, SELECTEDNODES) selects the nodes
            % specified by SELECTEDNODES in the tree
            %
            %  SELECTEDNODES cell array of fully qualified node paths of the
            %  nodes that should be selected in the tree.
            
            assert(iscellstr(selectedNodes),...
                'selectedNodes must be a cell-array of strings');
            
            nodes = java.util.ArrayList();
            for idx = 1 :length(selectedNodes)
                nodes.add(java.lang.String(selectedNodes{idx}));
            end
            
            javaMethodEDT('setSelectedNodes', obj.TreePanel, nodes);
        end
        
        function addNode(obj, nodePath, isContainer)
            % ADDNODE(OBJ, NODEPATH, ISCONTAINER) adds a new node at
            % NODEPATH. 
            %
            % NODEPATH the fully qualified path of the node. the name of
            % the node is the portion of the path after the last
            % period
            %
            % ISCONTAINER true if this node can be a parent node, false
            % otherwise. this will help determine the icon to be used for
            % the node.
            
            javaMethodEDT('addNode', obj.TreePanel, nodePath, isContainer);
        end
        
        function renameNode(obj, oldPath, newPath)
            % RENAMENODE(OBJ, OLDPATH, NEWPATH) renames the node
            % to the new name. 
            %
            % OLDPATH is fully qualified path of the node in the tree. It
            % contains the names of ancestor nodes separated by '.' period
            % characters.
            %
            % NEWPATH is fully qualified path of the new node node in the
            % tree. It contains the names of ancestor nodes separated by
            % '.' period characters.
            
            assert(ischar(oldPath) && ischar(newPath),...
                'names must be strings');
            
            javaMethodEDT('renameNode', obj.TreePanel, oldPath, newPath);
        end
        
        function deleteNode(obj, nodePath)
            % DELETENODE(OBJ, NODEPATH) deletes the node corresponding to
            % NODEPATH. 
            %
            % NODEPATH is fully qualified path of the node in the tree. It
            % contains the names of ancestor nodes separated by '.' period
            % characters.
            
            assert(ischar(nodePath), 'nodePath must be a string');
            
            javaMethodEDT('deleteNode', obj.TreePanel, nodePath);
        end
        
        function setEditable(obj, isEditable)
            % SETEDITABLE(OBJ, ISEDITABLE) makes the tree nodes editable or
            % not. the tree nodes are editable by default.
            %
            % ISEDITABLE true to allow users to rename nodes; false
            % otherwise.
            
            assert(islogical(isEditable), 'isEditable must be a logical');
            
            javaMethodEDT('setEditable', obj.TreePanel, isEditable);
        end
        
        function editNode(obj, nodePath)
            % EDITNODE(OBJ, NODEPATH) edits the node corresponding to
            % NODEPATH. 
            %
            % NODEPATH is fully qualified path of the node in the tree. It
            % contains the names of ancestor nodes separated by '.' period
            % characters.
            
            javaMethodEDT('editNode', obj.TreePanel, nodePath);
        end
        
        function deleteAllNodes(obj)
            % DELETEALLNODES(OBJ) deletes all the nodes in the tree 
            
            javaMethodEDT('deleteAllNodes', obj.TreePanel);
        end
    end
    
    %---------------------------------------------------------------------
    
    % Private functions
    methods(Access = 'private')
        
        function obj = handleNodeSelected(obj, nodeSelectedEventData)
            % HANDLENODESELECTED(NODESELECTEDEVENTDATA) is invoked each time a
            % node is selected by a user in the tree. converts the event
            % data to a MATLAB data
            %
            % NODESELECTEDEVENTDATA the java event data object.
            
            selectedNodes = {};
            for idx = 0 : nodeSelectedEventData.size() - 1
                selectedNodes{end + 1} = obj.getMData(nodeSelectedEventData.get(idx).getNodePath()); %#ok<AGROW>
            end
            
            evtdata.SelectedNodes = selectedNodes;
            
            notify(obj, 'NodesSelected', systest.event.GenericEventData(evtdata));
        end
        
        function obj = handleNodeEdited(obj, nodeEditedEventData)
            % HANDLENODEEDITED(OBJ, NODEEDITEDEVENTDATA) is invoked each
            % time a node is edited by a user in the tree. converts the
            % event data to a MATLAB data
            %
            % NODEEDITEDEVENTDATA the java event data object.
            
            evtdata =struct('NodePath', obj.getMData(nodeEditedEventData.getNodePath()),...
                            'OldName', obj.getMData(nodeEditedEventData.getOldName()),...
                            'NewName', obj.getMData(nodeEditedEventData.getNewName()));
            
            notify(obj, 'NodeEdited', systest.event.GenericEventData(evtdata));
        end
        
        function obj = handleKeyPressed(obj, keyPressedEventData)
            % HANDLEKEYPRESSED(OBJ, KEYPRESSEDEVENTDATA) is invoked each
            % time a key is pressed by a user in the table. converts the
            % event data to a MATLAB data.
            %
            % KEYPRESSEDEVENTDATA the java event data object.
             
            evtdata = struct('NodePath', obj.getMData(keyPressedEventData.getNodePath()));
            
            keyText = obj.getMData(keyPressedEventData.getKeyText);
            
            keyCode = keyPressedEventData.getKeyCode();
            if(keyCode == 127)
                notify(obj, 'NodeDeletionRequested', systest.event.GenericEventData(evtdata));
            else
                % add the key event entries to eventData.
                evtdata.KeyChar = keyPressedEventData.getKeyChar;
                evtdata.KeyText = keyText;
                evtdata.Modifiers = obj.getMData(keyPressedEventData.getModifiers);
                        
                notify(obj, 'KeyPressed', systest.event.GenericEventData(evtdata));
            end
        end
        
        function obj = handleMenuSelected(obj, menuSelectionEventData)
            % HANDLEMENUSELECTED(OBJ, MENUSELECTIONEVENTDATA) is invoked each time a
            % menu item is selected by the user. converts the event
            % data to a MATLAB data.
            %
            % MENUSELECTIONEVENTDATA the java event data object.
            
            evtdata =struct('NodePath', obj.getMData(menuSelectionEventData.getNodePath()),...
                            'SelectedMenuName', obj.getMData(menuSelectionEventData.getSelectedMenuName()));
            
            notify(obj, 'MenuSelected', systest.event.GenericEventData(evtdata));
        end
        
        function handleClipboardRequested(obj, clipboardEventData)
            % HANDLECLIPBOARDREQUESTED(OBJ, CLIPBOARDEVENTDATA) is invoked each
            % time cut,copy paste are selected from the right-click menu or
            % ctlr+c\x\v keys are pressed.
            %
            % CLIPBOARDEVENTDATA the java event data object.
            
            evtdata = struct('NodePath', obj.getMData(clipboardEventData.getNodePath()),...
                             'Type', obj.getMData(clipboardEventData.getType()));
            
            notify(obj, 'ClipboardRequested', systest.event.GenericEventData(evtdata));
        end
        
        function delete(obj)
            % DELETE Destroys the java object and listeners to its events
            
            delete(obj.WidgetListeners);
            
            % the java object must be destroyed
            javaMethodEDT('destroy', obj.TreePanel);            
        end
    end
    
    %----------------------------------------------------------------------
    
    % Private static functions - Not Commented yet
    methods(Static, Access = 'private')
        
        function newNode = createJavaNode(matlabNodeObj, javaNode)
            % NEWNODE = CREATEJAVANODE(MATLABNODEOBJ, JAVANODE) creates 
            % a java object and adds adds all children of matlabNodeObj to
            % NEWNODE recursively.
            %
            % NEWNODE is the java peer node of matlabNodeObj
            %
            % MATLABNODEOBJ an object of TreeNode class
            %
            % JAVANODE the java parent to which matlabNodeObj is added.
            % this can be empty.
            
            assert(isa(matlabNodeObj, 'internal.ui.widget.TreeNode'),...
            'matlabNodeObj must be object of type internal.ui.widget.TreeNode');
        
            % convert the matlabnode to java node.
            newNode = com.mathworks.toolbox.testmeas.tmswing.tree.Node(matlabNodeObj.Name, javaNode, matlabNodeObj.IsContainer);
            if(~isempty(javaNode))
                javaNode.appendChild(newNode);
            end
            
            % add all the children recursively
            for idx = 1 : length(matlabNodeObj.Children)
                internal.ui.widget.TreePanelController.createJavaNode(matlabNodeObj.Children(idx), newNode);
            end
        end
        
        function mdata = getMData(javaData)
            % MDATA = GETMDATA(JAVADATA)converts java data to matlab data.
            % only supports string objects
            %
            % JAVADATA - java object to convert
            %
            % MDATA - MATLAB data
            
            if(isa(javaData, 'java.lang.String') || isa(javaData, 'java.lang.Character'))
                mdata = char(javaData);
                return;
            end
            
            assert(false, 'Failed to convert java data to MATLAB data. Unxepcted data');
        end
    end
end