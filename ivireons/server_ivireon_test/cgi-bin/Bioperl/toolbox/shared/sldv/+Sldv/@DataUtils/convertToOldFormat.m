function oldSldvData = convertToOldFormat(model, sldvData)

%   Copyright 2008-2010 The MathWorks, Inc.

    errStr = Sldv.DataUtils.check_model_arg(model, 'convertToOldFormat');
    if ~isempty(errStr)
        error('SLDV:DataUtils:ConvertToOldFormat:WrongParameter', errStr);                
    end

    oldSldvData = sldvData;
    
    if ~isfield(oldSldvData,'Version') || ...
            Sldv.DataUtils.dataVersionLessThan(oldSldvData,'1.3')
        return;
    end
    
    oldSldvData = Sldv.DataUtils.removeVersionInfo(oldSldvData);
    oldSldvData = rmfield(oldSldvData,'ModelInformation');

    oldAnalysisInfo = construct_analysisInfo_info(oldSldvData);   
      
    SimData = Sldv.DataUtils.getSimData(oldSldvData);
    if isempty(SimData)
        oldSldvData.AnalysisInformation = oldAnalysisInfo;   
        return;
    end
    
    oldSldvData = Sldv.DataUtils.repeat_last_step(oldSldvData);        
        
    if isfield(oldSldvData,'CounterExamples')
        SimData = Sldv.DataUtils.getSimData(oldSldvData);
        oldSldvData = rmfield(oldSldvData,'CounterExamples');
        oldSldvData.TestCases = SimData;
    end
    
    oldSldvData = generatePortDimensionsForTestCases(oldSldvData);        
    
    oldSldvData.AnalysisInformation = oldAnalysisInfo;   
    
    for i=1:length(oldSldvData.TestCases)                
        testCase = oldSldvData.TestCases(i);                                        
        
        oldSldvData.TestCases(i).dataValues = {};
        oldSldvData.TestCases(i).dataNoEffect = {};
        
        if isempty(testCase.dataValues)            
            continue;
        end 
        
        for j=1:length(testCase.dataValues)       
            [dataValues, dataNoEffect] = Sldv.DataUtils.constructDataValuesForInport( ...                                                                                                                          
                                                            oldSldvData.AnalysisInformation.InputPortInfo{j}, ...
                                                            testCase.timeValues, ...                                                            
                                                            testCase.dataValues{j}, ...
                                                            testCase.dataNoEffect{j}, ...
                                                            false);
            
            oldSldvData.TestCases(i).dataValues{end+1} = dataValues;
            oldSldvData.TestCases(i).dataNoEffect{end+1} = dataNoEffect;
        end
        
    end
    
    if isfield(oldSldvData,'Constraints')
        oldSldvData = rmfield(oldSldvData,'Constraints');
    end
    
end

function oldAnalysisInfo = construct_analysisInfo_info(oldSldvData)

    InputPortInfo = oldSldvData.AnalysisInformation.InputPortInfo;
   
    numInputs = length(InputPortInfo);
    oldInputPortInfo = cell(1,numInputs);
    for i=1:numInputs
        oldInputPortInfo{i} = construct_input_info(InputPortInfo{i});
    end    
        
    oldAnalysisInfo.Mode = oldSldvData.AnalysisInformation.Options.Mode;
    oldAnalysisInfo.SampleTimes = oldSldvData.AnalysisInformation.SampleTimes;
    oldAnalysisInfo.InputPortInfo = oldInputPortInfo;
    if strcmp(oldSldvData.AnalysisInformation.Options.Mode,'TestGeneration')
        oldAnalysisInfo.TestSuiteOptimization = oldSldvData.AnalysisInformation.Options.TestSuiteOptimization;
    else
        oldAnalysisInfo.ProvingStrategy = oldSldvData.AnalysisInformation.Options.ProvingStrategy;
    end
    oldAnalysisInfo.Status = oldSldvData.AnalysisInformation.Status;
    oldAnalysisInfo.MaxViolationSteps = oldSldvData.AnalysisInformation.Options.MaxViolationSteps;
    oldAnalysisInfo.MaxProcessTime = oldSldvData.AnalysisInformation.Options.MaxProcessTime;
    
end

function oldinputInfo = construct_input_info(inputInfo)
    if ~iscell(inputInfo)
        oldinputInfo = [];
        oldinputInfo.sampleTime = inputInfo.SampleTime;
        Dimensions = inputInfo.Dimensions;
        oldinputInfo.dimensions = Dimensions;
        if isscalar(Dimensions)            
            oldinputInfo.portDimensions = [1 Dimensions];
        else
            oldinputInfo.portDimensions = Dimensions;
        end
        DataType = inputInfo.DataType;
        if strcmp(DataType,'boolean')
            oldinputInfo.portTypes = 'logical';
        else
            oldinputInfo.portTypes = DataType;
        end
        oldinputInfo.SampleTimeStr = inputInfo.SampleTimeStr;
        oldinputInfo.SampleTimeNumeric = inputInfo.SampleTime;
    else
        numComp = length(inputInfo)-1;
        oldinputInfo = cell(1,numComp+1);
        for idx=1:numComp
            oldinputInfo{idx+1} = construct_input_info(inputInfo{idx+1});
        end
        oldinputInfo{1} = inputInfo{1};
    end
end

function sldvData = generatePortDimensionsForTestCases(sldvData)
    TestCases = sldvData.TestCases;    
        
    numPorts = length(sldvData.AnalysisInformation.InputPortInfo);
    portDimensions = cell(1,numPorts);
    signalLabels = cell(1,numPorts);
    for idx = 1:numPorts   
        [portDimensions{idx} signalLabels{idx}] = getDimensions(sldvData.AnalysisInformation.InputPortInfo{idx});
    end
    
    for i=1:length(TestCases)
        TestCases(i).signalLabels = signalLabels; 
        TestCases(i).portDimensions = portDimensions;         
    end
    
    sldvData.TestCases = TestCases;
end

function [portDim, signalLabel] = getDimensions(inportInfoData)    
    if ~iscell(inportInfoData)
        portDim = inportInfoData.Dimensions;
        signalLabel = inportInfoData.SignalLabels;
    else
        numComp = length(inportInfoData)-1;
        portDim = cell(1,numComp);
        signalLabel = cell(1,numComp);
        for idx=1:numComp
            [portDim{idx}, signalLabel{idx}] = getDimensions(inportInfoData{idx+1});
        end
    end
end