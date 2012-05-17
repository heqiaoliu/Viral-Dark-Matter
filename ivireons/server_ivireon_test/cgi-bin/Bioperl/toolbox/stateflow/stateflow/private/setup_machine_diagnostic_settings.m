function setup_machine_diagnostic_settings(machineId)
% This function sets up the diagnostic settings for the machine

%   Copyright 2009 The MathWorks, Inc.

    cs = getActiveConfigSet(sf('get', machineId, 'machine.name'));
    diagnostics = getDiagnosticsList();
    for i = 1:length(diagnostics)
        val = get_param(cs,diagnostics{i});

        if(strcmp(val, 'none'))
            errorWarnNone = 0;
        elseif(strcmp(val, 'warning'))
            errorWarnNone = 1;
        else
            errorWarnNone = 2;
        end        
        
        diag = ['.diagSettings.' diagnostics{i}];
        sf('set',machineId, diag, errorWarnNone);
    end
end
