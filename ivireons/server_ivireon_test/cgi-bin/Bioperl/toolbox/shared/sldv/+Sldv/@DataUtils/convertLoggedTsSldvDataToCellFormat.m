function sldvData = convertLoggedTsSldvDataToCellFormat(sldvDataTs)

%   Copyright 2009 The MathWorks, Inc.

    sldvData = sldvDataTs;
    
    SimData = Sldv.DataUtils.getSimData(sldvData);
    if isempty(SimData)        
        return;
    end

    if isfield(sldvData.LoggedTestUnitInfo,'ModelBlock')
        InputPortInfo = sldvData.LoggedTestUnitInfo.ModelBlock.ReferencedModel.InputPortInfo;        
        modelTs = sldvData.LoggedTestUnitInfo.ModelBlock.ReferencedModel.SampleTimes;
        funTsInLoggedData = Sldv.DataUtils.deriveFunTsFromLoggedTsData(modelTs, SimData);
        funTsRefMdl = sldvshareprivate('mdl_derive_sampletime_for_sldvdata',modelTs);                            
    else
        assert(isfield(sldvData.LoggedTestUnitInfo,'SldvHarnessModel'))
        InputPortInfo = sldvData.LoggedTestUnitInfo.SldvHarnessModel.TestUnitModel.InputPortInfo;
        modelTs = sldvData.LoggedTestUnitInfo.SldvHarnessModel.TestUnitModel.SampleTimes;
        funTsRefMdl = sldvshareprivate('mdl_derive_sampletime_for_sldvdata',modelTs);    
        funTsInLoggedData = funTsRefMdl;
    end
    
    for i=1:length(SimData)   
        simData = SimData(i);                                 
        [minLogTime, maxLogTime] = findMinMaxLogTime(simData);
        timeExpanded = findTimeLoggedData(minLogTime, maxLogTime, funTsInLoggedData, funTsRefMdl);
        for j=1:length(simData.dataValues)
            simData.dataValues{j} = ...
                Sldv.DataUtils.storeDataValuesInCellFormatForLogging(...                
                    simData.dataValues{j},...
                    InputPortInfo{j},...
                    funTsRefMdl,...
                    funTsInLoggedData, timeExpanded, minLogTime, maxLogTime);                                                                            
        end        
        simData.timeValues = timeExpanded;
        sldvData.TestCases(i) = simData;
    end
end

function timeExpanded = findTimeLoggedData(minLogTime, maxLogTime, ...
    funTsInLoggedData, funTsRefMdl)
    timeExpanded = Sldv.DataUtils.expandTimeForTimeseries([minLogTime maxLogTime],...
        funTsInLoggedData, funTsRefMdl); 
end

function [minLogTime, maxLogTime] = findMinMaxLogTime(simData)
    numInputs = length(simData.dataValues);
    minLogTimeTs = zeros(1,numInputs);
    maxLogTimeTs = zeros(1,numInputs);
    for idx=1:numInputs
        [minLogTimeTs(idx), maxLogTimeTs(idx)] = ...
            findMinMaxLogTimeFromTs(simData.dataValues{idx});
    end
    minLogTime = min(minLogTimeTs);
    maxLogTime = max(maxLogTimeTs);
end

function [minLogTimeTs, maxLogTimeTs] = findMinMaxLogTimeFromTs(dataValuesInTs)
    if isa(dataValuesInTs,'Simulink.Timeseries')
        tsTimeInfo = dataValuesInTs.Time;     
        minLogTimeTs = tsTimeInfo(1);
        maxLogTimeTs = tsTimeInfo(end);
    else        
        % Find the min/max time of the first element in Simulink.TsArray is
        % enough.
        component = dataValuesInTs.Members(1);    
        [minLogTimeTs, maxLogTimeTs] = findMinMaxLogTimeFromTs(dataValuesInTs.(component.('name')));        
    end
end

