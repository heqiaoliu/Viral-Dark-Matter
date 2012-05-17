function [sldvData, dataUpdated] = addComplexityInformation(sldvData, model)

%   Copyright 2010 The MathWorks, Inc.

    dataUpdated = false;
    if complexityInfoMissing(sldvData)
        [InputPortInfo, OutputPortInfo] = Sldv.DataUtils.generateIOportInfo(model);    
        sldvData.AnalysisInformation.InputPortInfo = InputPortInfo;
        sldvData.AnalysisInformation.OutputPortInfo = OutputPortInfo;
        dataUpdated = true;
    end
end

function missing = complexityInfoMissing(sldvData)    
    portInfo = sldvData.AnalysisInformation.InputPortInfo;    
    missing = isComplexityMissing(portInfo);
    if ~missing
        portInfo = sldvData.AnalysisInformation.OutputPortInfo;    
        missing = isComplexityMissing(portInfo);
    end
end

function missing = isComplexityMissing(portInfo)
    missing = false;
    numIports = length(portInfo);
    for idx=1:numIports
        if hasNoComplexInfo(portInfo{idx})    
            missing = true;
            break;
        end
    end
end

function missing = hasNoComplexInfo(portInfoIdx)    
    missing = false;
    if ~iscell(portInfoIdx)
        missing = ~isfield(portInfoIdx, 'Complexity');            
    else
        for i=2:length(portInfoIdx)
            if hasNoComplexInfo(portInfoIdx{i})
                missing = true;
                break;
            end
        end        
    end      
end