function updateOutports(obj)

%   Copyright 2010 The MathWorks, Inc.

    OutputPortInfo = obj.SldvData.AnalysisInformation.OutputPortInfo;    
    for idx=1:length(OutputPortInfo)
        outportInfo = OutputPortInfo{idx};
        if iscell(outportInfo) && ...
                Sldv.utils.isInOutportBlkDataTypeBus(obj.OutportBlkHs(idx)) && ...                
                strcmp(get_param(obj.OutportBlkHs(idx),'BusOutputAsStruct'),'off')
            set_param(obj.OutportBlkHs(idx),'BusOutputAsStruct','on');
        end               
    end
end

