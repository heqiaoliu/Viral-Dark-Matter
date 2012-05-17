function hasFxptInput = modelHasFixedPntInput(sldvData)
    hasFxptInput = false;
    inputPortInfo = sldvData.AnalysisInformation.InputPortInfo;
    numIports = length(inputPortInfo);    
    for i=1:numIports
        if fixPntInputTpye(inputPortInfo{i})
            hasFxptInput = true;
            break;
        end
    end
end

function hasFxpt = fixPntInputTpye(inputPortInfo)
    hasFxpt = false;
    if ~iscell(inputPortInfo)
        hasFxpt = sldvshareprivate('util_is_fxp_type',inputPortInfo.DataType);
    else
        for i=2:length(inputPortInfo)
            if fixPntInputTpye(inputPortInfo{i})
                hasFxpt = true;
                break;
            end
        end        
    end  
end