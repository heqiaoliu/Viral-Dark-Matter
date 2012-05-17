function callback = getDefaultCallback
    callback = @DefaultCallback;
end

function DefaultCallback( cbinfo )
	% CallbackInfo is expected to contain a handle to a Studio
	% The default callback raises a menu event in C++
    tag = cbinfo.userdata;
	if DAStudio.showNotImplementedDialog
		cbinfo.studio.raiseMenuEvent( tag );
        dp = DAStudio.DialogProvider;
        message = [ 'Menu Item ' tag ' is not yet implemented.' ];
        dp.msgbox( message, 'STUDIO', true );
    else
        warning off backtrace;
		warning( 'STUDIO: Menu Item %s is not yet implemented.', tag );		
	end
end	