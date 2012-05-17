classdef SchemaWalker  < handle
    properties( SetAccess = private )
        current;
        root;
        schema = {};
        cbinfo;
    end
    
    properties( SetAccess = private, GetAccess = private )
        stack = {};
    end
    
    methods
        function self = SchemaWalker( root, inschema, incbinfo )
           self.schema = inschema;
           self.cbinfo = incbinfo;
           rootschema = DAStudio.ContainerSchema;
           rootschema.label = root;
           rootschema.generateFcn = self.LambdaGenerator1( @generateRootSchema );
           self.root = self.visit( rootschema );
        end 
        
        function stacknode = enter( self, index )
            % Cant advance if the current node has an error.
            if self.hasError( self.current )
                disp('Cannot enter Error Node!' );
                return;
            end
            
            if ~self.isContainer( self.current )
                msg = class(self.current.toolschema);
                msg = [ msg ' has no children' ];
                disp( msg );
                return;
            end
            
            % ok now we know we have a container.
            % make sure index is in range and if so,
            % get that child.
            if index >= 0 && index <= length( self.current.children )
				if index == 0
					self.visit( self.root );
				else
					% we're in range, lets get the child
					child = self.current.children{ index };

					% push current node onto stack with index
					stacknode = self.pushNode( self.current, index );

					% time to visit the node.
					self.visit( child );
				end
            else
                disp( 'Index out of range.' );
            end
        end
        
        function stacknode = leave( self )
            % leave the current node to its parent.
            if isempty( self.stack )
				msg = sprintf('Cannot leave %s!', self.root.toolschema.label );
                disp( 'Cannot leave Root Node!' );
                return;
            end
            
            stacknode = self.popNode();
            self.current = stacknode.node;
        end
        
        function err = error( self )
            err = self.current.error;
        end 
     
        function reset( self )
            self.root.error = {};
            self.current = self.root;
            self.stack = {};
        end
        
        function label = label( self )
            % current node could be separator...
            if ischar( self.current.toolschema )
                label = self.current.toolschema;
            else
                label = self.current.toolschema.label;
            end
        end
        
        function children = children( self )
            children = self.current.children;
        end
        
        function n = depth( self )
            n = length( self.stack );
		end
		
		function p = path( self )
			p = cell( size( self.stack ) );
			count = 1;
			for stacknode = self.stack
				p{count} = stacknode{1}.visiting;
				count = count + 1;
			end
			p = fliplr(p);
		end
    end
    
    methods(Access = private)
        function node = visit( self, toolschema )
            node.toolschema = toolschema;
            node.children = {};
            node.error = {};
            
            if ~self.isSeparator( toolschema ) && ~isa( toolschema, 'DAStudio.ToolSchema' )
                % this is an error and we should record such.
                node.error = MException( 'WALKER:CellIsWrongType', ...
                    'The toolschema must be either a DAStudio.ToolSchema or the string ''separator''.' );
            elseif isa( toolschema, 'DAStudio.ContainerSchema' )
                % try to get the children schemas
                try
					if ~isempty( toolschema.generateFcn )						
						schemas = toolschema.generateFcn( self.cbinfo );
					else
						schemas = toolschema.childrenFcns;
					end
                    % try to convert the children schema to ToolSchema
                    try 
                        node.children = self.convertToToolSchemas( schemas );
                    catch Err2
                        % this is an error, and we should record such.
                        me = MException( 'WALKER:BadSchemaConversion', ...
                            'Could not convert children.' );
                        node.error = addCause( me, Err2 );
                    end
                catch Err1
                    % this is an error, and we should record such.
                    me = MException( 'WALKER:ChildGenerationFailure', ...
                        'Could not generate children.' );
                    node.error =  addCause( me, Err1 );
                end
            end
            self.current = node;
        end
        
        function children = convertToToolSchemas( self, schemas )   
            children = {};
            % make sure it's a cell array 
            % for each entry, make sure it's either
            % 1. a function handle that takes cbinfo
            %    and returns a ToolSchema
            % 2. the word 'separator'
            if ~iscell( schemas )
                me = MException( 'WALKER:NonCellArray', ...
                    'Cannot convert non-cell array to ToolSchemas' );
                throw( me );
            end
            
            count = 1;
            for node = schemas
                cell = node{1};
                if isa( cell, 'function_handle' )
                    % the call to function_handle could throw. 
                    % But we want to put a more meaningful error
                    % in the records.
                    try
                        toolschema = cell( self.cbinfo );
                        
                        % we need to make sure that the return type is
                        % ToolSchema.
                        if ~isa( toolschema, 'DAStudio.ToolSchema' )
                            msg = sprintf( 'Child %d method returned Non ToolSchema', count );
                            me = MException( 'WALKER:ChildGenerationError', msg );
                            throw( me );
                        end
                        
                        % append to the children array.
                        children = [ children { toolschema } ];
                    catch Err
                        msg = sprintf( 'Child %d method failed.', count );
                        me = MException( 'WALKER:ChildGenerationError', msg );
                        me = addCause( me, Err );
                        throw( me );
                    end
                elseif DAStudio.SchemaWalker.isSeparator( cell )
                    children = [ children {'---------'} ];
                else
                    % not a function handle and not a separator. We're in
                    % trouble!
                    msg = sprintf( 'Cell must be either function_handle or the string %s!', 'separator' );
                    me = MException( 'WALKER:CellIsWrongType', msg );
                    throw( me );
                end
                count = count + 1;
            end
        end
        
        function stacknode = pushNode( self, node, visiting )
            stacknode.node = node;
            stacknode.visiting = visiting;
            self.stack = [ { stacknode } self.stack ];
        end
        
        function stacknode = popNode( self )
            if ~isempty( self.stack )  
                stacknode = self.stack{1};
                size = length( self.stack );
                if size > 1
                    self.stack = self.stack(2:size);
                else
                    self.stack = {};
                end
            else
                % this is an error. What should we do?
                stacknode.node = self.root;
                stacknode.visiting = 0;
            end
        end
    
        function schemas = generateRootSchema( self, ~ )
            schemas = self.schema;
        end
        
        function func = LambdaGenerator1( self, funchandle )
            func = @(cbinfo)funchandle( self, cbinfo );
        end 
    end
    
    methods(Static)
        function b = hasError( node )
            b = ~isempty( node.error );
        end
        
        function b = isSeparator( node )
            % we'll use this for both nodes and strings.
            % we''l need to reject anything else.
            b = false;
            word = {};
            if isa( node, 'struct' ) && isfield( node, 'toolschema' )
                word = node.toolschema;
            elseif ischar( node )
                word = node;
            else
                return;
            end
            
            b = ischar( word ) && ...
                ( strcmp( word, 'separator' ) || strcmp( word, '---------' ) );  
        end
        
        function b = isAction( node )
            b = isa( node.toolschema, 'DAStudio.ActionSchema' );
        end
        
        function b = isContainer( node )
            b = isa( node.toolschema, 'DAStudio.ContainerSchema' );
        end
        
        function b = isToggle( node )
            b = isa( node.toolschema, 'DAStudio.ToggleSchema' );
        end
    end
end