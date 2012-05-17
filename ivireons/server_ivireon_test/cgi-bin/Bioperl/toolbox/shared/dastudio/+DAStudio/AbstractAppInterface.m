classdef AbstractAppInterface < handle
    properties(SetAccess = protected)
        domainmap;
        error;
    end
    
    methods
        function self = AbstractAppInterface()
            self.domainmap = containers.Map;
        end
        
        function has = hasDomain( self, name )
            has = self.domainmap.isKey( name );
        end
        
        function addDomain( self, name, domain_if )
            if ~self.hasDomain( name )
                self.domainmap( name ) = domain_if;
            else
                % should we error?
            end
        end
        
        function removeDomain( self, name )
            if self.hasDomain( name )
                self.domainmap.remove( name );
            end
        end
        
        function domain_if = getInterfaceForDomain( self, domain )
            domain_if = {};
            domain_class = metaclass( domain );
            name = domain_class.Name;
            if self.hasDomain( name )
                domain_if = self.domainmap( name );
            end
        end
        
        function domain = getMenuBarDomain( self, cbinfo )
            domain = cbinfo.domain;
        end
        
        function domain = getToolBarDomain( self, cbinfo )
            domain = cbinfo.domain;
        end
                
       function domain = getContextMenuDomain( self, cbinfo )
            domain = cbinfo.domain;          
        end
    end
    
    methods(Sealed)     
        function schemas = getSchemas( self, selector, cbinfo )
            schemas = {};
            self.error = {};
            try
                switch( selector )
                    case 'MenuBar'
                        domain = self.getMenuBarDomain( cbinfo );
                        domain_if = self.getInterfaceForDomain( domain );
                        if ~isempty( domain_if )
                            schemas = domain_if.getMenuBarSchemas( cbinfo );
                        end
                    case 'ToolBars'
                        domain = self.getMenuBarDomain( cbinfo );
                        domain_if = self.getInterfaceForDomain( domain );
                        if ~isempty( domain_if )
                            schemas = domain_if.getToolBarSchemas( cbinfo );
                        end                        
                    otherwise
                        domain = self.getContextMenuDomain( cbinfo );
                        domain_if = self.getInterfaceForDomain( domain );
                        if ~isempty( domain_if ) && domain_if.hasContextMenu( selector )
                            schemas = domain_if.getContextMenuSchemas( selector, cbinfo );
                        else
                            schemas = DAStudio.getCustomSchemas( selector, cbinfo );
                        end
                end
            catch Err
                self.error = Err;
            end
            
            if isempty( self.error )
                % Empty schemas OK for context menus and tool bars.
                if isempty( schemas ) && strcmp( selector, 'MenuBar' )
                    msg = sprintf( '%s produced an empty schema.', selector );
                    self.error = MException( 'Studio:SchemaError', msg );
                end
            end
            
            % If we catch an error, let's try to keep DIG from crashing.
            if ~isempty( self.error )
                schemas = self.getErrorSchema( selector, schemas, cbinfo );
            end
        end
    end
    
    methods(Access = protected)
        function schema = getErrorSchema( self, selector, schemas, cbinfo )
            errmenu = DAStudio.ErrorMenu( selector, schemas );
            schema = errmenu.getSchemas( cbinfo );
        end
    end
end
