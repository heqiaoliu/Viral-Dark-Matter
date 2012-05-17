classdef ContextMenus < handle
    properties(SetAccess = protected)
        menus;
        menuinfo;
    end
    
    methods
        function self = ContextMenus( actions, submenus )
            self.menuinfo = struct;
            self.menuinfo.submenus = submenus;
            self.menuinfo.actions = actions;
            self.initialize;
        end
        
        function initialize( self )
            % add menus to map here.
            self.menus = containers.Map;
        end
        
        function schemas = getSchemas( self, selector, cbinfo )
            schemas = {};
            if self.hasMenu( selector )
                menu = self.menus( selector );
                schemas = menu( self.menuinfo, cbinfo );
            end
        end
        
        function has = hasMenu( self, selector )
            has = self.menus.isKey( selector );
        end
        
        function menu = getMenu( self, selector )
            assert( self.hasMenu( selector ), ['DAStudio Context Menus: No such selector: ' selector '. call hasMenu first!'] );
            menu = self.menus( selector );
        end
        
        function addMenu( self, selector, generator )
            self.menus( selector ) = generator;
        end
        
        function removeMenu( self, selector )
            % We do this check to avoid potential warnings.
            if self.hasMenu( selector )
                self.menus.remove( selector );
            end
        end
    end
end