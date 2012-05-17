function errormenu = ErrorMenu( selector, schemas )
	errormenu = public();
	return;
	function schemas = getSchemas( ~ )
		schemas = { @ErrorMenuBar };
	end

	function schema = ErrorMenuBar( ~ )
		schema = DAStudio.ContainerSchema;
		schema.label = 'DIG Error MenuBar';
		schema.tag = 'Studio:DIGError';
		schema.generateFcn = @ErrorMenuGenerator; 			
	end
	
	function schemas = ErrorMenuGenerator( ~ )
		schemas = { @PrintSchemaTree }; 
	end
	
	function schema = PrintSchemaTree( ~ )
		schema = DAStudio.ActionSchema;
		schema.label = 'Print Schema Tree';
		schema.tag = 'Studio:DIGError';
		schema.callback = @PrintSchemaTreeCB;  
	end

	function PrintSchemaTreeCB( cbinfo )
		tree = DAStudio.SchemaTree( selector, schemas, cbinfo );
		tree.print();
	end
	
	function o = public()
		o = struct;
		
		o.getSchemas = @getSchemas;
	end
end
