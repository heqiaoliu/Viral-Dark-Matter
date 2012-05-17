function blockWithUspecBus = has_unspecified_bus_objects(model,sldvData)

%   Copyright 2008-2009 The MathWorks, Inc.

    blockWithUspecBus = '';
    
    OutputPortInfo = sldvData.AnalysisInformation.OutputPortInfo;    
    outportBlksH = find_system(model, ...
        'SearchDepth',1,...        
        'BlockType','Outport'); 

    for i=1:length(OutputPortInfo)
        outportInfo = OutputPortInfo{i};
        if strcmp(get_param(outportBlksH(i),'UseBusObject'),'off')
            if iscell(outportInfo) && ...
                    isfield(outportInfo{1},'BusObject') && ...
                    isempty(outportInfo{1}.('BusObject'))                
                blockWithUspecBus = outportInfo{1}.('BlockPath');
                break;
            end
        end               
    end
end