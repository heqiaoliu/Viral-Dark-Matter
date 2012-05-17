function sldvDatainTs = storeDataInTimeseriesForSystemTest(sldvData)
      
    sldvDatainTs = sldvData;
    
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
        sldvDatainTs.TestCases(i) = simData;
    end
    
    % enable them back
    warning(warningstatus.state,'timeseries:init:istimefirst');

end