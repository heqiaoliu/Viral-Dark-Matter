function sldvDataExp = repeat_last_step(sldvData, forTimeSeries)

%   Copyright 2008-2009 The MathWorks, Inc.

    if nargin<2
        forTimeSeries = false;
    end
    sldvDataExp = sldvData;
    simData = Sldv.DataUtils.getSimData(sldvData);
    if ~isempty(simData)        
        fundamentalSampleTime = sldvshareprivate('mdl_derive_sampletime_for_sldvdata',sldvDataExp.AnalysisInformation.SampleTimes);
        InportInfo = sldvDataExp.AnalysisInformation.InputPortInfo;
        hasMatrixInput = Sldv.DataUtils.checkRootInportDimensions(InportInfo);
        for i=1:length(simData)
            numberTimeSteps = length(simData(i).timeValues);
            if forTimeSeries && ~(numberTimeSteps==1 && hasMatrixInput)
                continue;
            end
            lastTimeStep = simData(i).timeValues(end);            
            simData(i).timeValues = [simData(i).timeValues lastTimeStep+fundamentalSampleTime];
            for j=1:length(simData(i).dataValues)                                                              
                simData(i).dataValues{j} = ...
                    expandTestCaseData(simData(i).dataValues{j}, InportInfo{j}, numberTimeSteps);                
            end              
            for j=1:length(simData(i).dataNoEffect)                                                             
                simData(i).dataNoEffect{j} = ...
                    expandTestCaseData(simData(i).dataNoEffect{j}, InportInfo{j}, numberTimeSteps);                
            end              
            sldvDataExp = Sldv.DataUtils.setSimData(sldvDataExp,i,simData(i));
        end
    end 
end

function dataValues = expandTestCaseData(inportTestData, inportInfo, numberTimeSteps)    
    if ~iscell(inportTestData)
        dt = Sldv.DataUtils.flattenData(numberTimeSteps,inportInfo.Dimensions,inportTestData);        
        dt = [dt dt(:,end)];         
        dataValues = Sldv.DataUtils.reshapeData(numberTimeSteps+1,inportInfo.Dimensions,dt);        
    else
        numSignals = length(inportTestData);
        dataValues = cell(1,numSignals);        
        for i=1:numSignals
            dataValues{i} = expandTestCaseData( ...
                                        inportTestData{i}, ...                                                                
                                        inportInfo{i+1}, ...
                                        numberTimeSteps);
        end
    end    
end
