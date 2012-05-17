classdef SchemaTree < handle
    properties( SetAccess = private )
        schema = {};
        cbinfo = {};
		walker = {};
		collapsed = {};
    end
    
    methods 
        function self = SchemaTree( name, inschema, incbinfo )
            self.schema = inschema;
            self.cbinfo = incbinfo;
			self.walker = DAStudio.SchemaWalker( name, self.schema, self.cbinfo );
        end
        
        function print( self )
            self.walker.reset();
            self.printRecursive( self.walker );
		end
		
		function expand( self, path )
			expanded = {};
			index = self.findCollapsedPath( path );
			len = length( self.collapsed );
			if index <= len
				if len > 1
					if index == 1
						expanded = { self.collapsed{1, 2:len} };
					elseif index == len
						expanded = { self.collapsed{1, 1:len-1} };
					else
						expanded = [ self.collapsed{1,1:index-1} self.collasped{index+1,len} ];
					end
				end
				self.collapsed = expanded;
			end		
		end
		
		function collapse( self, path )
			if ~self.isCollapsed( path )
				self.collapsed = [ self.collapsed { path } ];
			end
		end
		
		function b = isCollapsed( self, path )
			b = false;
			if self.findCollapsedPath( path ) <= length( self.collapsed )
				b = true;
			end	
		end
	
		function b = isExpanded( self, path )
			b = ~isCollapsed( path );
		end
		
		function expandAll( self )
			self.collapsed = {};
		end
    end
    
    methods(Access = private)
        function printRecursive( self, walker )
            % first, print the current label
            error = walker.error();
            msg = '';
            numtabs = walker.depth();
            for i = 1:numtabs
                msg = sprintf('%s\t', msg );
			end
			path = self.walker.path;
			iscollapsed = self.isCollapsed( path );
            if ~isempty( error )
                % we cannot rely on an error node having a printable
                % toolschema. 
				%errmsg = sprintf( '<a href="matlab:error.getReport">%s</a>', error.identifier );
                msg = [ msg ' ' error.identifier ];
            else
                label = walker.label;
                if label(1) == '-'
                    msg = [ msg ' ' label];
                else
                    if isa( walker.current.toolschema, 'DAStudio.ContainerSchema' ) 
						if iscollapsed == true
							msg = [ msg '+' ];
						else
							msg = [ msg '-' ];
						end
                        msg = [ msg label ' >' ];
                    elseif isa( walker.current.toolschema, 'DAStudio.ActionSchema' ) && ...
                                isprop( walker.current.toolschema, 'accelerator' )
                        if isa( walker.current.toolschema, 'DAStudio.ToggleSchema' )
                            msg = [ msg '/' label ];
                        else
                            msg = [ msg ' ' label ];
                        end
                        numblanks = 25 - length(msg); 
                        if numblanks < 1
                            numblanks = 1;
                        end
                        msg = [ msg blanks(numblanks) walker.current.toolschema.accelerator ];
                    end
                end
            end
            disp( msg );
            
            count = length( walker.children() );
            
			if ~iscollapsed
				for index = 1:count
					walker.enter( index );
					self.printRecursive( walker );
				end
			end
            % OK, we're done here. Go back to parent.
            if numtabs ~= 0
                walker.leave();
            end
		end
		
		function index = findCollapsedPath( self, path )
			index = 1;
			for a = self.collapsed
				if isequal( a{1}, path )
					break;
				end
				index = index + 1;
			end
		end
    end
end