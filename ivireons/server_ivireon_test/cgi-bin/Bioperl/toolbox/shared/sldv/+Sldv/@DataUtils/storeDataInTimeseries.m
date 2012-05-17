function sldvDatainTs = storeDataInTimeseries(model, sldvData)

    if ~ischar(model)
        model = get_param(model,'Name');
    end
   
    sldvDatainTs = sldvData;        
    
    sldvDatainTs = Sldv.DataUtils.convertToCurrentFormat(model, sldvDatainTs);
    
    SimData = Sldv.DataUtils.getSimData(sldvDatainTs);
    if isempty(SimData)        
        return;
    end
    
    sldvDatainTs = Sldv.DataUtils.repeat_last_step(sldvDatainTs, true);
    
    inportInfo = Sldv.DataUtils.constructInportInformation(sldvDatainTs);  
       
    fundamentalSampleTime = ...
        sldvshareprivate('mdl_derive_sampletime_for_sldvdata',sldvDatainTs.AnalysisInformation.SampleTimes);    
    
     % disable the unwanted warnings
    warningstatus = warning('query','timeseries:init:istimefirst');     
    warning('off','timeseries:init:istimefirst');
    
    SimData = Sldv.DataUtils.getSimData(sldvDatainTs);
    for i=1:length(SimData)   
        
        simData = SimData(i);                                
        if isempty(simData.dataValues)            
            continue;
        end            
        
        timeExpanded = Sldv.DataUtils.expandTimeForTimeseries(simData.timeValues, fundamentalSampleTime);
                    
        for j=1:length(simData.dataValues)                                    
            leafeIdx = 1;
            [inportValuesObj] = Sldv.DataUtils.constructDataValuesForTsInport( ...                                                                
                                                                                leafeIdx, ...
                                                                                inportInfo(j), ...                                                 
                                                                                timeExpanded, ...
                                                                                simData.timeValues, ...
                                                                                simData.dataValues{j});
            
            simData.dataValues{j} = inportValuesObj;            
        end
        sldvDatainTs = Sldv.DataUtils.setSimData(sldvDatainTs,i,simData);
    end
    
    % enable them back
    warning(warningstatus.state,'timeseries:init:istimefirst');
end
