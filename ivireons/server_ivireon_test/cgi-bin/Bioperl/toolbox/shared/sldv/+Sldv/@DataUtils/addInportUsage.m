function sldvData = addInportUsage(sldvData)

%   Copyright 2010 The MathWorks, Inc.

    inportInfo = sldvData.AnalysisInformation.InputPortInfo;
    outportInfo = sldvData.AnalysisInformation.OutputPortInfo;    
    sldvData.AnalysisInformation.InputPortInfo = addUsedField(inportInfo);
    sldvData.AnalysisInformation.OutputPortInfo = addUsedField(outportInfo);
end

function portInfo = addUsedField(portInfo)
    for idx=1:length(portInfo)
        portInfo{idx} = addaddUsedFieldForPort(portInfo{idx});
    end
end

function portInfo = addaddUsedFieldForPort(portInfo)
    if isstruct(portInfo) && ~isfield(portInfo,'Used')        
        portInfo.Used = true;        
    else
        for idx=2:length(portInfo)
             portInfosub = addaddUsedFieldForPort(portInfo{idx});
             portInfo{idx} = portInfosub;
        end
    end
end