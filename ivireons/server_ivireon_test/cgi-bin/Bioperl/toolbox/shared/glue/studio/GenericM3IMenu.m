% Copyright 2005-2010 The MathWorks, Inc.
% Class to encapsulate and share our functionality for m3i based menus.
% This allows better reuse of the generic code inside here.
classdef GenericM3IMenu
    
    methods
        
        function addIcons( self, inStudio ) %#ok<INUSD>
            
            persistent iconsLoaded;
            
            if isempty(iconsLoaded)
                iconsLoaded = 1;
                im = DAStudio.IconManager;
                root = [matlabroot '/toolbox/shared/dastudio/resources/'];
                
                im.addFileToIcon( 'GenericM3I:New', [root 'new.png']);
                im.addFileToIcon( 'GenericM3I:Open', [root 'open.png']);
                im.addFileToIcon( 'GenericM3I:Save', [root 'save.png']);
                %       im.addFileToIcon( 'GenericM3I:Print', [root 'print.png']);
                im.addFileToIcon( 'GenericM3I:Undo', [root 'undo.png']);
                im.addFileToIcon( 'GenericM3I:Redo', [root 'redo.png']);
                %       im.addFileToIcon( 'GenericM3I:Cut', [root 'cut.png']);
                %       im.addFileToIcon( 'GenericM3I:Copy', [root 'copy.png']);
                %       im.addFileToIcon( 'GenericM3I:Paste', [root 'paste.png']);
                im.addFileToIcon( 'GLUE:New', [root 'new.png']);
                im.addFileToIcon( 'GLUE:Open', [root 'open.png']);
                im.addFileToIcon( 'GLUE:Save', [root 'save.png']);
                im.addFileToIcon( 'GLUE:Delete', [root 'delete.png']);
                im.addFileToIcon( 'GLUE:Undo', [root 'undo.png']);
                im.addFileToIcon( 'GLUE:Redo', [root 'redo.png']);
                
                inStudio.App.populateIconManager();
            end
            
        end
        
        
        %% --- dispatchToMethod ------------------------------------------
        %  Hub used to dispatch to different methods via a single point.
        function schemas = dispatchToMethod( self, whichMenu, callbackInfo )
            
            % ensure our icons have been added.
            self.addIcons(callbackInfo.studio);
            
            % launch to the appropriate method.
            switch( whichMenu )
                case 'ContextMenu'
                    schemas = self.DoContextMenuItems( callbackInfo );
                case 'MenuBar'
                    schemas = self.MenuBar( callbackInfo );
                case 'ToolBars'
                    schemas = self.ToolBars( callbackInfo );
            end
        end
        
        function schema = DoContextMenuItems( self, callbackInfo )
            
            isValid = self.DoContextMenuSetup(callbackInfo);
            if(~isValid)
                return;
            end
            
            % make a new schema.
            schema = cell(0);
            
            % add our new option
            schema = self.ContextMenuAddItemNew(callbackInfo, schema);
            
            % add our remove option
            schema = self.ContextMenuAddItemRemove(callbackInfo, schema);
            
            customSchemas = cm_get_custom_schemas( 'GenericM3I:ContextMenu' );
            
            schema =  {  schema{:}, ...
                customSchemas{:}, ...
                };
            
        end
        
        %% --- DoContextMenuSetup -------------------------------------------
        % This stores menu items in a cell-array.
        function isValid = DoContextMenuSetup( self, callbackInfo )
            
            isValid = true;
            
            % ensure we have a valid item
            sel = GenericM3IMenu.getContextMenuSelectedItem(callbackInfo.studio);
            if(~sel.isvalid)
                isValid = false;
            else
                
                % get our metaClass info.
                metaClass = sel.getMetaClass;
                if(~metaClass.isvalid)
                    isValid = false;
                end
                
            end
            
            if(~isValid)
                return;
            end
            
        end
        
        
        %% --- ContextMenuAddItemNew-------------------------------------------
        % Adds the "new" item
        function schema = ContextMenuAddItemNew( self, callbackInfo, ioSchema )
            
            % build a "New" section.
            schema = ioSchema;
            schema{end+1} = @GenericM3IMenu.CreateMenuNew;
            
        end
        
        %% --- ContextMenuAddItemRemove-------------------------------------------
        % Adds the "new" item
        function schema = ContextMenuAddItemRemove( self, callbackInfo, ioSchema )
            
            % This gives us the option to remove an item
            schema = ioSchema;
            schema{end+1} = @GenericM3IMenu.DoContextRemove;
            
        end
        
        %% --- ContextMenuAddItemRemove-------------------------------------------
        % Adds the "new" item
        function schema = ContextMenuAddItemRename( self, callbackInfo, ioSchema )
            
            schema = ioSchema;
            sel = GenericM3IMenu.getContextMenuSelectedItem(callbackInfo.studio);
            if(sel.isvalid())
                nameProp = sel.getMetaClass.getProperty('name');
                if(nameProp.isvalid()) 
                    schema{end+1} = @GenericM3IMenu.DoContextRename;
                end
            end
            
        end
        
        
    end
    
    methods (Static)
        
        %% --- MenuBar ---------------------------------------------------
        function schemas = MenuBar( callbackInfo )
            schemas = { @GenericM3IMenu.FileMenu, ...
                @GenericM3IMenu.EditMenu
                };
            customSchemas = cm_get_custom_schemas( 'GenericM3I:MenuBar' );
            
            schemas = { schemas{:}, ...
                customSchemas{:}, ...
                @GenericM3IMenu.HelpMenu };
            
        end
        
        %% --- Toolbars --------------------------------------------------
        function schemas = ToolBars( callbackInfo )
            schemas = { @GenericM3IMenu.MainToolBar, ...
                };
        end
        
        %% --- FileMenu --------------------------------------------------
        function schema = FileMenu( callbackInfo )
            schema = sl_container_schema;
            schema.label = '&File';
            schema.tag = 'GenericM3I:FileMenu';
            
            schema.generateFcn = @GenericM3IMenu.FileMenuChildren;
            
        end
        
        %% --- FileMenuChildren ------------------------------------------
        function schemas = FileMenuChildren( callbackInfo )
            schemas = { @GenericM3IMenu.New, ...
                @GenericM3IMenu.Open, ...
                @GenericM3IMenu.Close, ...
                @GenericM3IMenu.Update, ...
                'separator', ...
                @GenericM3IMenu.Save, ...
                @GenericM3IMenu.SaveAs, ...
                ...%            'separator', ...
                ...%            @PageSetup, ...
                ...%            @Print, ...
                'separator'
                };
            
            customSchemas = cm_get_custom_schemas( 'GenericM3I:FileMenu' );
            
            schemas = { schemas{:}, ...
                'separator', ...
                customSchemas{:}, ...
                'separator', ...
                @GenericM3IMenu.ExitStudio };
            
        end
        
        %% --- EditMenu --------------------------------------------------
        function schema = EditMenu( callbackInfo )
            schema = sl_container_schema;
            schema.label = '&Edit';
            schema.tag = 'GenericM3I:EditMenu';
            
            schema.generateFcn = @GenericM3IMenu.EditMenuChildren;
        end
        
        %% --- EditMenuChildren ------------------------------------------
        function schemas = EditMenuChildren( callbackInfo )
            schemas = { @GenericM3IMenu.Undo, ...
                @GenericM3IMenu.Redo, ...
                ...%            'separator', ...
                ...%            @GenericM3IMenu.Cut, ...
                ...%            @GenericM3IMenu.Copy, ...
                ...%            @GenericM3IMenu.Paste, ...
                ...%            @GenericM3IMenu.Clear, ...
                ...%            'separator', ...
                ...%            @GenericM3IMenu.SelectAll, ...
                };
        end
        
        %% --- ViewMenu -------------------------------------------------
        function schema = ViewMenu( callbackInfo )
            schema = sl_container_schema;
            schema.label = '&View';
            schema.tag = 'GenericM3I:ViewMenu';
            
            schema.generateFcn = @GenericM3IMenu.ViewMenuChildren;
        end
        
        %% --- ViewMenuChildren -----------------------------------------
        function schemas = ViewMenuChildren( callbackInfo )
            schemas = { @GenericM3IMenu.TreeBrowser, ...
                @GenericM3IMenu.PropertyPane, ...
                };
        end
        
        %% --- HelpMenu ---------------------------------------------------
        function schema = HelpMenu( callbackInfo )
            schema = sl_container_schema;
            schema.label = '&Help';
            schema.tag = 'GenericM3I:HelpMenu';
            
            schema.generateFcn = @GenericM3IMenu.HelpMenuChildren;
        end
        
        %% --- HelpMenuChildren --------------------------------------------
        function schemas = HelpMenuChildren( callbackInfo )
            schemas = { @GenericM3IMenu.About, ...
                };
        end
        
        %% --- MainToolBar -------------------------------------------------
        function schema = MainToolBar( callbackInfo )
            schema = sl_container_schema;
            schema.tag = 'GenericM3I:MainToolBar';
            
            schema.childrenFcns = { @GenericM3IMenu.New, ...
                @GenericM3IMenu.Open, ...
                @GenericM3IMenu.Save, ...
                'separator', ...
                ...%                        @GenericM3IMenu.Cut, ...
                ...%                        @GenericM3IMenu.Copy, ...
                ...%                        @GenericM3IMenu.Paste, ...
                @GenericM3IMenu.Undo, ...
                @GenericM3IMenu.Redo, ...
                'separator', ...
                ...%                        @GenericM3IMenu.Print, ...
                ...%                        @GenericM3IMenu.RunMode, ...
                ...%                        @GenericM3IMenu.BuildMode, ...
                };
        end
        
        %% --- New -----------------------------------------------------------------
        function schema = New( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&New';
            schema.tag = 'GenericM3I:New';
            schema.icon = schema.tag;
            schema.accelerator = 'Ctrl+N';
            schema.callback = @GenericM3IMenu.loc_newAction;
        end
        
        %% --- New callback ------------------------------------------------------
        function loc_newAction( callbackInfo )
            s = callbackInfo.studio;
            s.App.removeAllModels();
            
            m = callbackInfo.studio.App.createNewModel();
            if(~m.isvalid())
                disp(['cannot create a model of uri ' s.App.getMetaUri() '. Please provide a different Uri']);
                return;
            end
            callbackInfo.studio.App.addModel(m);
        end
        
        
        %% --- Open ----------------------------------------------------------------
        function schema = Open( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&Open...';
            schema.tag = 'GenericM3I:Open';
            schema.icon = schema.tag;
            schema.accelerator = 'Ctrl+O';
            schema.callback = @GenericM3IMenu.loc_openAction;
        end
        
        %% --- Open callback ------------------------------------------------------
        function loc_openAction( callbackInfo )
            s = callbackInfo.studio;
            [filename, pathname] = uigetfile({'*.xml', 'M3I files (*.xml)'}, ...
                xlate('Open...'));
            if(filename==0), return; end
            
            f = M3I.XmiReaderFactory();
            r = f.createXmiReader();
            m = r.read([pathname filesep filename]);
            
            s.App.removeAllModels();
            s.App.addModel(m);
        end
        
        %% --- Close ---------------------------------------------------------------
        function schema = Close( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&Close...';
            schema.tag = 'GenericM3I:Close';
            schema.accelerator = 'Ctrl+W';
            schema.callback = @GenericM3IMenu.loc_closeAction;
        end
        
        %% --- Close callback ------------------------------------------------------
        function loc_closeAction( callbackInfo )
            s = callbackInfo.studio;
            s.App.removeAllModels();
        end
        
        %% --- Update ---------------------------------------------------------------
        function schema = Update( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&Update';
            schema.tag = 'GenericM3I:Update';
            schema.accelerator = 'Ctrl+U';
            schema.callback = @GenericM3IMenu.loc_updateAction;
        end
        
        %% --- Update callback ------------------------------------------------------
        function loc_updateAction( callbackInfo )
            s = callbackInfo.studio;
            m = s.App.getActiveModel;
            if(~m.isvalid())
                disp('ther is no active model as thus nothing to update');
            end
            
            f = M3I.XmiReaderFactory;
            r = f.createXmiReader();
            m = r.update(m.uri, m);
        end
        
        %% --- SaveAs --------------------------------------------------------------
        function schema = SaveAs( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = 'Save&As...';
            schema.tag = 'GenericM3I:SaveAs';
            schema.callback = @GenericM3IMenu.loc_saveAsAction;
        end
        
        %% --- SaveAs callback ------------------------------------------------------
        function loc_saveAsAction( callbackInfo )
            
            s = callbackInfo.studio;
            m = s.App.getActiveModel;
            if(~m.isvalid())
                disp('ther is no active model as thus nothing to save');
                return;
            end
            
            [filename, pathname] = uiputfile('*.xml', xlate('Save As...'));
            if(filename==0), return; end
            
            factory = M3I.XmiWriterFactory;
            w = factory.createXmiWriter();
            w.write(fullfile(pathname, filename), m);
            clear w;
            
        end        
        %% --- Save ----------------------------------------------------------------
        function schema = Save( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&Save';
            schema.tag = 'GenericM3I:Save';
            schema.icon = schema.tag;
            schema.accelerator = 'Ctrl+S';
            schema.callback = @GenericM3IMenu.loc_saveAction;
        end
        
        %% --- Save callback ------------------------------------------------------
        function loc_saveAction( callbackInfo )
            s = callbackInfo.studio;
            m = s.App.getActiveModel;
            if(~m.isvalid())
                disp('ther is no active model as thus nothing to save');
                return;
            end
            
            if(~isempty(m.uri))
                m.uri;
                factory = M3I.XmiWriterFactory;
                w = factory.createXmiWriter();
                w.write(m.asImmutable);
                return;
            else
                GenericM3IMenu.loc_saveAsAction(callbackInfo);
                return;
            end
        end
        
        %% --- Exit Studio-----------------------------------------------------
        function schema = ExitStudio( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = 'E&xit SCP';
            schema.tag = 'GenericM3I:ExitStudio';
            schema.callback = @GenericM3IMenu.loc_exitStudio;
        end
        
        %% --- Exit Studio callback -------------------------------------------
        function loc_exitStudio( callbackInfo )
            s = callbackInfo.studio;
            s.hide;
        end
        
        %% --- Undo ----------------------------------------------------------------
        function schema = Undo( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&Undo ';
            schema.tag = 'GenericM3I:Undo';
            schema.icon = schema.tag;
            schema.accelerator = 'Ctrl+Z';
            schema.callback = @GenericM3IMenu.loc_undo;
        end
        
        %% --- Undo callback ------------------------------------------------------
        function loc_undo( callbackInfo )
            s = callbackInfo.studio;
            m = s.App.getActiveModel();
            if(m.isvalid())
                m.undo;
            end
        end
        
        
        %% --- Redo ----------------------------------------------------------------
        function schema = Redo( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&Redo';
            schema.tag = 'GenericM3I:Redo';
            schema.icon = schema.tag;
            schema.accelerator = 'Ctrl+Y';
            schema.callback = @GenericM3IMenu.loc_redo;
        end
        
        %% --- Undo callback ------------------------------------------------------
        function loc_redo( callbackInfo )
            s = callbackInfo.studio;
            m = s.App.getActiveModel();
            if(m.isvalid())
                m.redo;
            end
        end
        
        
        % %% --- Cut -----------------------------------------------------------------
        % function schema = Cut( callbackInfo )
        %     schema = sl_action_schema;
        %
        %     schema.label = 'Cut';
        %     schema.tag = 'GenericM3I:Cut';
        %     schema.icon = schema.tag;
        %     schema.accelerator = 'Ctrl+X';
        %     schema.callback = 'disp(''Test:Cut'')';
        % end
        %
        % %% --- Copy ----------------------------------------------------------------
        % function schema = Copy( callbackInfo )
        %     schema = sl_action_schema;
        %
        %     schema.label = 'Copy';
        %     schema.tag = 'GenericM3I:Copy';
        %     schema.icon = schema.tag;
        %     schema.accelerator = 'Ctrl+C';
        %     schema.callback = 'disp(''Test:Copy'')';
        % end
        %
        % %% --- Paste ---------------------------------------------------------------
        % function schema = Paste( callbackInfo )
        %     schema = sl_action_schema;
        %
        %     schema.label = 'Paste';
        %     schema.tag = 'GenericM3I:Paste';
        %     schema.icon = schema.tag;
        %     schema.accelerator = 'Ctrl+V';
        %     schema.callback = 'disp(''Test:Paste'')';
        % end
        
        %% --- Clear ---------------------------------------------------------------
        function schema = Clear( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&Clear';
            schema.tag = 'GenericM3I:Clear';
            schema.callback = 'disp(''Test:Clear'')';
        end
        
        %% --- Select All ----------------------------------------------------------
        function schema = SelectAll( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = 'Select &All';
            schema.tag = 'GenericM3I:SelectAll';
            schema.accelerator = 'Ctrl+A';
            schema.callback = 'disp(''Test:Clear'')';
        end
        
        
        % --- About ---------------------------------------------------------------
        function schema = About( callbackInfo )
            schema = sl_action_schema;
            
            schema.label = '&About Simulink';
            schema.tag = 'GenericM3I:About';
            schema.callback = 'daabout(''simulink'');';
        end
        
        function BuildModeCallback( builder )
            builder.Build;
        end
        
        %% Context menu section
        
        %% --- Helper to retrieve the right context menu item we want ----------
        function sel = getMainTreeSelectedItem(studio)
            sel = studio.getComponent('main_tree').getSelected();
        end
        
        %% --- Helper to retrieve the right context menu item we want ----------
        function sel = getContextMenuSelectedItem(studio)
            try
                theMainTree = studio.getComponent('main_tree');
            catch Err
                if(~strcmp(Err.identifier, 'PLATFORM_ObjectNotFound'))
                    rethrow(Err);
                end
                sel = studio.App.getCurrentSelection();
                return;
            end
            
            if(theMainTree == studio.getActiveComponent())
                sel = studio.getActiveComponent().getSelected();
            else
                sel = studio.App.getCurrentSelection();
            end
        end
        
        %% --- DoContextMenuItems ------------------------------------------
        
        %% --- CreateMenuNew -------------------------------------------------------
        % Builds a "new" menu.
        function schema = CreateMenuNew( callbackInfo )
            
            % ensure we have a valid item
            sel = GenericM3IMenu.getContextMenuSelectedItem(callbackInfo.studio);
            if(~sel.isvalid)
                return;
            end
            
            % get the metaClass
            metaClass = sel.getMetaClass;
            if(~metaClass.isvalid)
                return;
            end
            
            % build the "New' menu.
            schema = sl_container_schema;
            schema.label = '&New';
            schema.tag = 'GLUE2:Context:NewMenu';
            schema.generateFcn = @GenericM3IMenu.CreateMenuSubItemsNew;
            schema.userdata = metaClass;
            %callbackInfo.userdata = schema.userdata;
            
            result = GenericM3IMenu.CreateMenuSubItemsNew_Helper(callbackInfo.studio.App);

            if (isempty(result))
                schema.state = 'hidden';
            end
            
        end
        
        %% --- CreateMenuSubItemsNew -----------------------------------------------
        % Builds all the "new" menu items.
        function schema = CreateMenuSubItemsNew( callbackInfo )
            schema = GenericM3IMenu.CreateMenuSubItemsNew_Helper( callbackInfo.studio.App );
        end

        function schema = CreateMenuSubItemsNew_Helper( app )
            schema = cell(0);

            % get our metaclass
            sel = app.getCurrentSelection;
            metaClass = sel.getMetaClass;
            
            % here, we gather each owned attribute that we could use.
            % Note: We remove abstract and invalid items.
            
            %oas = metaClass.ownedAttribute;
            %metaClasses = M3I.getContainedClasses(metaClass, oas);
            metaClasses = app.getFilteredChildrenTypes(metaClass);
            
            % use a for_each to process each item.
            curr = metaClasses.begin;
            while (curr ~= metaClasses.end)
                mc = curr.item;
                schema{end+1} = { @GenericM3IMenu.CreateMenuItemGenerator, mc };
                curr.getNext;
            end
            
        end
        
        
        %% --- CreateMenuItemGenerator ------------------------------------------------------
        % This creates a menu item and all it's data associated with it.
        function schema = CreateMenuItemGenerator( callbackInfo )
            
            propType = callbackInfo.userdata;
            
            schema = sl_action_schema;
            schema.label = propType.qualifiedName();
            schema.tag = ['GLUE2:Context:Create' propType.qualifiedName()];
            %schema.icon = 'GLUE:New';
            theName = callbackInfo.studio.App.getIconTagForObject(propType);
            %schema.icon = theName;
            %schema.accelerator = 'Ctrl+C';
            schema.callback = @GenericM3IMenu.loc_CreateProp;
            userdata.metatype = propType;
            schema.userdata = userdata;
        end
        
        %% --- DoContextRemove ----------------------------------------------------
        % This creates a menu item to fire "REMOVE"
        function schema = DoContextRemove( callbackInfo )
            schema = sl_action_schema;
            schema.label = '&Delete';
            schema.tag = 'GLUE2:Context:Remove';
            schema.icon = 'GLUE:Delete';
            schema.accelerator = 'Ctrl+D';
            schema.callback = @GenericM3IMenu.loc_ActionItemRemove;
        end
        
        %% --- DoContextRename ----------------------------------------------------
        % This creates a menu item to fire "RENAME"
        function schema = DoContextRename( callbackInfo )
            schema = sl_action_schema;
            schema.label = 'Rename';
            schema.tag = 'GLUE2:Context:Rename';
            %schema.icon = 'GLUE:Rename';
            schema.accelerator = 'F2';
            schema.callback = @GenericM3IMenu.loc_ActionItemRename;
        end
        
        %% --- loc_CreateProp ------------------------------------------------------
        % This is the "action" for creating a property.
        function loc_CreateProp( callbackInfo )
            
            % get the model
            sel = GenericM3IMenu.getContextMenuSelectedItem(callbackInfo.studio);
            model = sel.modelM3I;
            t = M3I.Transaction(model);
            
            userdataStruct = callbackInfo.userdata;
            % get the factory from the metaType's name.
            % NOTE: Transaction is commited inside this method.
            newObj = callbackInfo.studio.App.createObjectOfType(sel, userdataStruct.metatype);
            
            if(isfield(userdataStruct, 'stereotype'))
                callbackInfo.studio.App.createObjectOfType(newObj, userdataStruct.stereotype);
            end
            
            if(isfield(userdataStruct, 'propValue'))
                propValues = userdataStruct.propValue;
                if(iscell(propValues))
                    for i=1:2:length(propValues)
                        newObj.setOrAdd(propValues{i}, propValues{i+1});
                    end
                end
            end
            
            t.commit;
            clear t;
            
            callbackInfo.studio.App.setCurrentSelection(newObj);

        end
        
        %% --- loc_ActionItemRemove ------------------------------------------------
        % This will fire the "remove" action for this.
        function loc_ActionItemRemove( callbackInfo )
            sel = GenericM3IMenu.getContextMenuSelectedItem(callbackInfo.studio);
            if(sel.isvalid)
                m = sel.modelM3I;
                t = M3I.Transaction(m);
                sel.destroy();
                t.commit;
            end
        end
        
        %% --- loc_ActionItemRename ------------------------------------------------
        % This will fire the "rename" action for this.
        function loc_ActionItemRename( callbackInfo )
            sel = GenericM3IMenu.getContextMenuSelectedItem(callbackInfo.studio);
            if(sel.isvalid)
                tc = [];
                try % checking SAM tree first.
                    tc = callbackInfo.studio.getComponent('main_tree');
                catch e1
                    try
                        tc = callbackInfo.studio.getComponent('main_tree');
                    catch e2
                        tc = [];
                    end
                end
                
                if(~isempty(tc))
                   tc.editObject( sel );
                end
            end
        end
        
        
    end
    
end

% LocalWords:  im uri xml ther xit userdata oas commited
