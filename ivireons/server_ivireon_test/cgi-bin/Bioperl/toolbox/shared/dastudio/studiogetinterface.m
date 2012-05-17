function schemas = studiogetinterface( whichMenu, callbackInfo )

% Copyright 2009 The MathWorks, Inc.
    schemas = {};
    
    if ~isempty( callbackInfo.studio.App )
        interface = callbackInfo.studio.App.getMenuInterface();
    else
        interface.interfaceFile = 'studioGetDefaultInterface';
        interface.gatewayFile = '';
    end
    
    try
        if isempty( interface.gatewayFile )
            schemas = feval( interface.interfaceFile, whichMenu, callbackInfo );
        else
            schemas = feval( interface.gatewayFile, interface.interfaceFile, ...
                             whichMenu, callbackInfo );
        end
    catch Err
        switch( whichMenu )
            case 'MenuBar'
                schemas = { { @ErrorMenuBar, Err } };
            otherwise
                rethrow(Err);
        end
        disp('MATLAB Exception: studiogetinterface()');
    end
end

function schema = ErrorMenuBar( cbinfo )
    schema = DAStudio.ContainerSchema;
    schema.label = 'DIG Error MenuBar';
    schema.tag = 'Studio:DIGError';
    schema.childrenFcns = { { @ErrorItem, cbinfo.userdata } };     
end

function schema = ErrorItem( cbinfo )
    schema = DAStudio.ActionSchema;
    schema.label = 'Edit Schema';
    schema.tag = 'Studio:EditSchema';
    schema.userdata = cbinfo.userdata;
    schema.callback = @EditSchemaCallback;    
end

function EditSchemaCallback( cbinfo )
    err = cbinfo.userdata;
    disp(err.getReport);
end