classdef MenuBar < handle
    properties(SetAccess = 'protected')
        menuinfo;
        menus;
    end
    
    methods
        function self = MenuBar( actions, submenus )
            self.menuinfo = struct;
            self.menuinfo.actions = actions;
            self.menuinfo.submenus = submenus;
            
            filemenu = DAStudio.makeCallback( self, @FileMenu );
            editmenu = DAStudio.makeCallback( self, @EditMenu );
            viewmenu = DAStudio.makeCallback( self, @ViewMenu );
            helpmenu = DAStudio.makeCallback( self, @HelpMenu );
            
            % initialize the studio menu array.
            self.menus = { { filemenu, self.menuinfo }, ...
                           { editmenu, self.menuinfo }, ...
                           { viewmenu, self.menuinfo }, ...
                           { helpmenu, self.menuinfo }
                         };
        end
        
        function schemas = getSchemas( self, cbinfo )
            % DIG currently fails if we return no menu bar, so to provide a
            % convenient one-shot operation to hide the main menu, we instead
            % return a trivial menu bar with nothing to display. 
            hiddenmenu = DAStudio.makeCallback( self, @HiddenMenu );
            if isequal( cbinfo.studio.getMenuState('Studio:MenuBar'), 'Hidden' )
                schemas = { { hiddenmenu , self.menuinfo } };
            else
                schemas = self.menus;

                % lookup internal custom menus
                customs = DAStudio.getCustomSchemas( 'Studio:MenuBar', cbinfo );
                if ~isempty( customs )
                    schemas = [ schemas ...
                                customs ];
                end
            end
        end
        
        function menus = insertMenuBarSchemas( self, menu, at )
            if at > 0 && at <= length( self.menus )
                self.menus = [ self.menus(1:at-1) menu self.menus(at:end) ];
                menus = self.menus;
            else
                me = MException( 'SLStudio.CommonMenuBar:insertMenuBarSchemas', ...
                                  'Must insert menu bar items between File menu and Help menu.' );
                throw(me);
            end
        end
    end
    
    methods(Access=protected)
        % File Menu
        function schema = FileMenu( self, cbinfo ) 
            schema = DAStudio.ContainerSchema;
            schema.label = xlate('&File');
            schema.tag = 'Studio:FileMenu';
            schema.userdata = cbinfo.userdata;
            schema.generateFcn = DAStudio.makeCallback( self, @generateFileMenuChildren );     
        end
        
        function children = generateFileMenuChildren( self, cbinfo ) %#ok<MANU>
            actions = cbinfo.userdata.actions;
            submenus = cbinfo.userdata.submenus;
            % generate children
            children = { actions('New'), ...
                         actions('Open'), ...
                         { submenus('OpenRecentMenu'), cbinfo.userdata }, ...
                         { submenus('CloseMenu'), cbinfo.userdata }, ...
                         'separator', ...
                         actions('Save'), ...
                         actions('SaveAs'), ...
                         actions('SaveStudioLayout'), ...
                         'separator', ...
                         actions('Print'), ...
                         actions('PrinterSetup')
                      };

            % lookup internal custom menus
            customs = DAStudio.getCustomSchemas( 'Studio:FileMenu', cbinfo );
            if ~isempty( customs )
                children = [ children ...
                             {'separator'}  ...
                             customs ];
            end

            children = [ children ...
                         {'separator'} ...
                         { actions('ExitMatlab') } ];               
        end
        
        % Edit Menu
        function schema = EditMenu( self, cbinfo ) 
            schema = DAStudio.ContainerSchema;
            schema.label = xlate('&Edit');
            schema.tag = 'Studio:EditMenu';
            schema.userdata = cbinfo.userdata;
            schema.generateFcn = DAStudio.makeCallback( self, @generateEditMenuChildren );
        end
        
        function children = generateEditMenuChildren( self, cbinfo ) %#ok<MANU>
            actions = cbinfo.userdata.actions;
            % generate children
            children = { actions('Undo'), ...
                         actions('Redo'), ...
                         'separator', ...
                         actions('Cut'), ...
                         actions('Copy'), ...
                         actions('Paste'), ...
                         actions('Clear'), ...
                         'separator', ...
                         actions('Delete')
                       };

            % lookup internal custom menus
            customs = DAStudio.getCustomSchemas( 'Studio:EditMenu', cbinfo );
            if ~isempty( customs )
                children = [ children customs ];
            end              
        end
        
        % View Menu
        function schema = ViewMenu( self, cbinfo )  
            schema = DAStudio.ContainerSchema;
            schema.label = xlate('&View');
            schema.tag = 'Studio:ViewMenu';
            schema.userdata = cbinfo.userdata;
            schema.generateFcn = DAStudio.makeCallback( self, @generateViewMenuChildren );
        end
        
        function children = generateViewMenuChildren( self, cbinfo ) %#ok<MANU>
            submenus = cbinfo.userdata.submenus;
            % generate children
            children = { { submenus('DocksMenu'), cbinfo.userdata }, ...
                         { submenus('TabsMenu'), cbinfo.userdata }, ...
                         { submenus('StatusMenu'), cbinfo.userdata }, ...
                       };

            % lookup internal custom menus
            customs = DAStudio.GetCustomSchemas( 'Studio:ViewMenu', cbinfo );
            if ~isempty( customs )
                children = [ children customs ];
            end              
        end
        
        % Help Menu
        function schema = HelpMenu( self, cbinfo ) 
            schema = DAStudio.ContainerSchema;
            schema.label = xlate('&Help');
            schema.tag = 'Studio:HelpMenu';
            schema.userdata = cbinfo.userdata;
            schema.generateFcn = DAStudio.makeCallback( self, @generateHelpMenuChildren );
        end
        
        function children = generateHelpMenuChildren( self, cbinfo ) %#ok<MANU>
            actions = cbinfo.userdata.actions;
            % generate children
            children = { actions('About'), ...
                         actions('GettingStarted')
                       };

            % lookup internal custom menus
            customs = DAStudio.GetCustomSchemas( 'Studio:HelpMenu', cbinfo );
            if ~isempty( customs )
                children = [ children customs ];
            end               
        end
        
        % Hidden Menu
        function schema = HiddenMenu( self, ~ ) %#ok<MANU> % ( self, cbinfo )
            schema = DAStudio.ContainerSchema;
            schema.label = 'Hidden';
            schema.tag = 'Studio:HiddenMenu';
            schema.state = 'Hidden';
            schema.childrenFcns = {};          
        end

    end
end
