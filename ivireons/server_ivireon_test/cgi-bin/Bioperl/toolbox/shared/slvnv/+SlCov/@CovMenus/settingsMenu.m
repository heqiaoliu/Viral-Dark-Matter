function schema = settingsMenu(callbackInfo)

    schema = DAStudio.ActionSchema;
    
    schema.tag = 'Simulink:CoverageSettings';
    schema.label = xlate('Co&verage Settings');
    schema.callback = @CoverageSettings_callback;
    
    if  ~license('test','sl_verification_validation') || ...
        exist('cvsim', 'file') == 0 
        schema.state = 'Hidden';
        return;
    else
        schema.state = 'Enabled';        
    end

end

function CoverageSettings_callback( callbackInfo )
   cv('Private', 'scvdialog', 'open',callbackInfo.model.Name);
end

