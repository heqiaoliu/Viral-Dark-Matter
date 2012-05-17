classdef ToolBars < handle
	properties
		menuinfo;
	end
	
	methods
		function self = ToolBars( actions,submenus )
            self.menuinfo = struct;
			self.menuinfo.actions = actions;
            self.menuinfo.submenus = submenus;
		end
		
		function schemas = getSchemas( self, cbinfo )
			% Standard toolbars
            % DIG currently ignores the schema.state for a toolbar, so if you want
            % to hide a tool bar, the way to do it is to not generate one at all.
            % If the generator function returns nothing, DIG will raise a warning.
            % SO, we need to check the state here.
            if isequal(cbinfo.studio.getMenuState('Studio:ToolBars'),'Hidden')
                schemas = {};
			else
				schema_1 = self.getToolBarSchemas( cbinfo );

                % schema_2 contains any custom items.
                schema_2 = DAStudio.getCustomSchemas( 'Studio:ToolBars', cbinfo );

                % Return all toolbars.
                schemas = [ schema_1 schema_2 ];
            end  			
		end
		
		function schemas = getToolBarSchemas( self, cbinfo )
            schemas = {};
            if ~isequal(cbinfo.studio.getMenuState('Studio:MainToolBar'),'Hidden')
                schemas = [ schemas ...
                            { { @self.MainToolBar, self.menuinfo } } ];
            end
        end
    end
    
    methods(Static)
        function schema = MainToolBar( cbinfo )
            schema = DAStudio.ContainerSchema;
            schema.label = xlate('MainToolBar');
            schema.tag = 'Studio:MainToolBar';
            
            actions = cbinfo.userdata.actions;
            children = { actions('New'), ...
                         actions('Open'), ...
                         actions('Save'), ...
                         'separator', ...
                         actions('Cut'), ...
                         actions('Copy'), ...
                         actions('Paste'), ...
                         actions('Undo'), ...
                         actions('Redo'), ...
                         'separator', ...
                         actions('Print')
                       };
            schema.childrenFcns = children;
        end
    end
end