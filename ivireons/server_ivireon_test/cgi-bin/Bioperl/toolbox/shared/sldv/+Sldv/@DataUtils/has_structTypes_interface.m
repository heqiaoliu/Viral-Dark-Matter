function hasStructTypes = has_structTypes_interface(sldvData)

%   Copyright 2009 The MathWorks, Inc.

    hasStructTypes = false;
    portInfo = [sldvData.AnalysisInformation.InputPortInfo ...
        sldvData.AnalysisInformation.OutputPortInfo];   
    for idx=1:length(portInfo)
        if structInputType(portInfo{idx})
            hasStructTypes = true;
            break;
        end
    end
end

function hasStruct = structInputType(portInfo)
    hasStruct = false;
    if iscell(portInfo)
        hasStruct = isfield(portInfo{1},'StructObject');
    end    
end

