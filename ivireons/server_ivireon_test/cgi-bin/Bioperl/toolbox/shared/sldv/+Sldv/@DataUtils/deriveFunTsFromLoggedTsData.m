function funTs = deriveFunTsFromLoggedTsData(modelTs, simData)        

%   Copyright 2009 The MathWorks, Inc.

    funTs = [];
    for i=1:length(simData)   
        currentsimData = simData(i);                    
        currentFunTs = [];
        for j=1:length(currentsimData.dataValues)
            funjTs = findFunTsfromLoggedTimeInfo(currentsimData.dataValues{j});            
            if ~isempty(funjTs)            
                currentFunTs(end+1) = funjTs; %#ok<AGROW>
            end
        end
        if ~isempty(currentFunTs)            
            funTs = sldvshareprivate('mdl_derive_sampletime_for_sldvdata',currentFunTs);
            break;
        end
    end
    if isempty(funTs)
        funTs = sldvshareprivate('mdl_derive_sampletime_for_sldvdata',modelTs);
    end
end

function [funTs, incomplete] = findFunTsfromLoggedTimeInfo(dataValuesInTs)    
    incomplete = false;
    funTs = [];
    if isa(dataValuesInTs,'Simulink.Timeseries')     
        if length(dataValuesInTs.Time)==1
            incomplete = true;
        else
            timeDiff = diff(dataValuesInTs.Time);                
            sortedtimeDiff = sort(timeDiff);
            if (abs(sortedtimeDiff(1)-sortedtimeDiff(end))/sortedtimeDiff(end))<=eps
                funTs = sortedtimeDiff(1);
            else
                funTs = sldvshareprivate('mdl_derive_sampletime_for_sldvdata',sortedtimeDiff);
            end        
        end
    else
        numComponents = length(dataValuesInTs.Members);       
        for i=1:numComponents
            component = dataValuesInTs.Members(i);    
            [funTs, incomplete]  = findFunTsfromLoggedTimeInfo(dataValuesInTs.(component.('name')));
            if incomplete || ~isempty(funTs)
                break;
            end
        end
    end
end