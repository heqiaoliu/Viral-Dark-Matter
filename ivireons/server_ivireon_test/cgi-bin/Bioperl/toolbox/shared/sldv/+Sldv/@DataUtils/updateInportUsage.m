function sldvData = updateInportUsage(sldvData, sldvDataWithUsed)

%   Copyright 2010 The MathWorks, Inc.

    newInportInfo = sldvDataWithUsed.AnalysisInformation.InputPortInfo;
    newOutportInfo = sldvDataWithUsed.AnalysisInformation.OutputPortInfo;
    inportInfo = sldvData.AnalysisInformation.InputPortInfo;
    outportInfo = sldvData.AnalysisInformation.OutputPortInfo;  
    sldvData.AnalysisInformation.InputPortInfo = ...
        updateUsedField(inportInfo, newInportInfo);
    sldvData.AnalysisInformation.OutputPortInfo = ...
        updateUsedField(outportInfo, newOutportInfo); 
end

function portInfo = updateUsedField(portInfo, newportInfo)
    for idx=1:length(portInfo)
        portInfo{idx} = setUsedFieldForPort(portInfo{idx}, newportInfo{idx});
    end
end

function portInfo = setUsedFieldForPort(portInfo, newportInfo)
    if isstruct(portInfo) 
        portInfo.Used = newportInfo.Used;        
    else
        for idx=2:length(portInfo)
             portInfosub = setUsedFieldForPort(portInfo{idx},newportInfo{idx});
             portInfo{idx} = portInfosub;
        end
    end
end