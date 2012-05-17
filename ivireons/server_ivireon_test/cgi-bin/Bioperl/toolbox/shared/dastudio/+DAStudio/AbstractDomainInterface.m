classdef AbstractDomainInterface < handle
    properties(SetAccess = 'protected')
        menubar;
        toolbars;
        context;
    end
    
    methods
        function self = AbstractDomainInterface( menubar, toolbars, context )
            self.menubar = menubar;
            self.toolbars = toolbars;
            self.context = context;
        end
        
        function schemas = getMenuBarSchemas( self, cbinfo )
            schemas = {};
            if ~isempty( self.menubar )
                schemas = self.menubar.getSchemas( cbinfo );
            end
        end
        
        function schemas = getToolBarSchemas( self, cbinfo )
            schemas = {};
            if ~isempty( self.toolbars )
                schemas = self.toolbars.getSchemas( cbinfo );
            end
        end
        
        function has = hasContextMenu( self, selector )
            if ~isempty( self.context )
                has = self.context.hasMenu( selector );
            else
                has = false;
            end
        end
        
        function schemas = getContextMenuSchemas( self, selector, cbinfo )
            schemas = {};
            if ~isempty( self.context )
                schemas = self.context.getSchemas( selector, cbinfo );
            end
        end
    end
end