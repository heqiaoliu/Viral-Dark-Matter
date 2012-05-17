function msgPortNames = hasComplexTypeInports(SldvData, modelH)
    msgPortNames = {}; 
    inportBlkHs = Sldv.utils.getSubSystemPortBlks(modelH);
    inputPortInfo = SldvData.AnalysisInformation.InputPortInfo;
    numIports = length(inputPortInfo);
    for idx=1:numIports
        if hasComplexType(inputPortInfo{idx})    
            msgPortNames{end+1} = getfullname(inportBlkHs(idx)); %#ok<AGROW>
        end
    end
end

function isComplex = hasComplexType(inputPortInfo)
    isComplex = false;
    if ~iscell(inputPortInfo)
        if(isfield(inputPortInfo, 'Complexity')) 
            isComplex = strcmp(inputPortInfo.Complexity,'complex');
        end
    else
        for i=2:length(inputPortInfo)
            if hasComplexType(inputPortInfo{i})
                isComplex = true;
                break;
            end
        end        
    end      
end