function newRules = saSFDiagnostics(obj)
    % Remove SF diagnostics when saving in earlier versions

%   Copyright 2010 The MathWorks, Inc.
        
    
    if isR2010aOrEarlier(obj.ver)
        % Remove the SF diagnostics from the configset:
        % Simulink.DebuggingCC.SF*Diag        
        diagnostics = sfprivate('getDiagnosticsList');
        newRules = cell(1, length(diagnostics));
                
        for i = 1:length(diagnostics)        
            rule1 = sl('makeSaveAsRule', diagnostics{i},'','remove');
            rmSFDiag = sl('makeSaveAsRule', 'Simulink.DebuggingCC', '', '', rule1);
            
            newRules{i} = rmSFDiag;
        end        
    end
end
