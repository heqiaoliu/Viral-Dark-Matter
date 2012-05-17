function hasFxptInterface = modelHasFixedPntInterface(sldvData)

%   Copyright 2008 The MathWorks, Inc.

    hasFxptInterface = false;
    portInfo = [sldvData.AnalysisInformation.InputPortInfo ...
        sldvData.AnalysisInformation.OutputPortInfo];   
    for idx=1:length(portInfo)
        if fixPntInputTpye(portInfo{idx})
            hasFxptInterface = true;
            break;
        end
    end
end

function hasFxpt = fixPntInputTpye(portInfo)
    hasFxpt = false;
    if ~iscell(portInfo)
        hasFxpt = sldvshareprivate('util_is_fxp_type',portInfo.DataType);
    else
        for i=2:length(portInfo)
            if fixPntInputTpye(portInfo{i})
                hasFxpt = true;
                break;
            end
        end        
    end  
end

