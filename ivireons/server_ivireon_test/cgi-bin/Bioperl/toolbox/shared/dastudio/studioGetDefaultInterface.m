function schemas = studioGetDefaultInterface( whichMenu, callbackInfo )
    persistent defaultInterface;
    
    if isempty( defaultInterface )
        defaultInterface = DAStudio.DefaultAppInterface;
    end

    schemas = defaultInterface.getSchemas( whichMenu, callbackInfo );
end