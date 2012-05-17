function strPorts = getPorts(blockH)                           

%   Copyright 2010 The MathWorks, Inc.

    strPorts = getPortInfo(blockH);       
end

function  strPorts = getPortInfo(blockH)    

    strPorts = get_param(blockH, 'PortHandles');    
    strPorts.hasFcnCalledTriggerBlock = false;
    strPorts.hasFcnCalledTriggerPeriodicBlock = false;
    
    blockMaskType = get_param(blockH, 'MaskType');
    if ~isempty(strPorts.Trigger) && ~strcmp(blockMaskType,'Stateflow'),        
        trigH = find_system(blockH,'searchdepth',1,'BlockType','TriggerPort');        
        for i=1:length(trigH),            
            if strcmp(get_param(trigH(i),'TriggerType'),'function-call'),
                strPorts.hasFcnCalledTriggerBlock = true;
                if strcmp(get_param(trigH(i),'SampleTimeType'),'periodic')
                    strPorts.hasFcnCalledTriggerPeriodicBlock = true;
                end
                break;
            end
        end
    end
end

% LocalWords:  searchdepth
