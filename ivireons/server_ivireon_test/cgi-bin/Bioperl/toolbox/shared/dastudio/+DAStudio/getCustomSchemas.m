function [ schemas, error ] = getCustomSchemas( selector, cbinfo )
	error = {};
	schemas = {};

	customs = cbinfo.studio.getDIGInterfaces();
	for i = 1:length(customs)
		interface = customs(i).interfaceFile;
		gateway = customs(i).gatewayFile;
		try
			if isempty(gateway)
				oneschema = feval( interface, selector, cbinfo );
			else
				oneschema = feval( gateway, interface, selector, cbinfo );
			end
			if ~isempty(oneschema)
				schemas = [ schemas {'separator'} oneschema ];
			end
		catch Err
			msg = sprintf('Could not read custom schema %s', interface );
			me = MException( 'StudioInterface:CustomSchemaError', msg );
			me.addCause( Err );
			if isempty( error )
				error = me;
			else
				error.addCause( me );
			end
		end
	end
end	