function [status, errmsg] = checkPorts(blockH)

%   Copyright 2010 The MathWorks, Inc.

    status = true;
    errmsg = '';

    strPorts = Sldv.SubSystemExtract.getPorts(blockH);
    
    if ~isempty(strPorts.LConn) || ~isempty(strPorts.RConn)
        % Phys modSystem        
        errmsg = xlate('Extracting %s with connection ports is not supported');        
        status = false;        
    elseif ~isempty(strPorts.Ifaction)    
        % IfActionSystem
        errmsg = xlate('Extracting if-action %s is not supported');
        status = false;        
    elseif strPorts.hasFcnCalledTriggerBlock
       sfLicensed = license('test','Stateflow');      
       if ~sfLicensed,        
            errmsg = xlate(['Extracting Function-call %s is not '...
                'supported if Stateflow is not licensed']);
            status = false;            
       end
    end
    
    if ~status         
        errmsg = sprintf(errmsg,'subsystems');        
    end
end
% LocalWords:  subcharts
