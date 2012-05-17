
%   Copyright 2008-2010 The MathWorks, Inc.

classdef (Sealed=true) DataUtils     
   
    methods(Access = 'private')       
        function obj = DataUtils
        end                        
    end
    
    methods(Static, Access = 'private')                   
        inportInfo = constructInportInformation(sldvData)
        [inportValuesObj, leafeIdx] = constructDataValuesForTsInport( ...                                                                
                                                                leafeIdx, ...
                                                                inportInfoData, ...  
                                                                timeExpanded, ...
                                                                timeCompressed, ...                                                                   
                                                                inportTestData)
                        
        yi = interpBelow(x, y, xi, dimensions)   
        testCaseCompressed = compressTestCaseData(testCase)        
        sldvDataComp = compressSldvData(sldvData)
        
        [inPortInfo, outPortInfo, modelCompileInfo] = ...
            getModelCompiledIOInfo(model, parameterSettings)        
                
        currentSldvData = setVersionToCurrent(sldvData)
        oldSldvData = removeVersionInfo(sldvData)
        
        [InputPortInfo, OutputPortInfo, flatInfo] = ...
            generateIOportInfo(model, parameterSettings)
        
        [dataValues, dataNoEffect] = constructDataValuesForInport( ...                                                                                                                                
                                                                inportInfoData, ...
                                                                timeCompressed, ... 
                                                                inportTestData, ...
                                                                inportNoEffectData, ...
                                                                forNewFormat)

        out = util_randvalue(flatdimensions,numberTimeSteps,x)
        
        errStr = check_model_arg(model, utility)        
        
        modelinfo = getModelInformation(model,activity)        
        hasMatrixInput = checkRootInportDimensions(InportInfo)
        
        tc = createDefaultTC(inportCompInfos, forLogging)
        
        funTs = deriveFunTsFromLoggedTsData(modelTs, simData)
    end       
    
    methods (Static)  
        out = dataVersionLessThan(sldvData,verstr)
        
        out = dataVersionLessThanR2008b(sldvData)
        
        [inportUsage, allUnused, anyUnused] = getInportUsage(sldvData)        
        
        sldvData = addInportUsage(sldvData)
        
        sldvData = updateInportUsage(sldvData, sldvDataWithUsed)
        
        [sldvData, dataUpdated] = addComplexityInformation(sldvData, modelH)

        % For harness generation from only the model
        sldvData = generateDataFromMdl(model,usedSignalsOnly,forMdlRefHarness)
        
        % For storing logging information
        [sldvData, sampleTimeInformation] = ...
            generatDataForLogging(modelBlockH, sldvHarnessMdlH)
        
        % Converts the sldvDataTs (sldvData where test cases are stored in
        % timeseries format) to cell format. sldvDataTs is assumed to be
        % generated from sldvlogsignals and it is used to log the input
        % signals of a model block
        sldvData = convertLoggedTsSldvDataToCellFormat(sldvDataTs)
        
        % Converts sldvData generated from sldvlogsignals to a new format that
        % is acceptable by sldvmakeharness.
        [sldvData, errorMsg] = convertLoggedSldvDataToHarnessDataFormat(sldvDataLogged, copyModelH)
           
        % manipulating TestCases or CounterExamples field
        sldvData = setSimData(sldvData,dataIdx,simData)
        [simData, title] = getSimData(sldvData,dataIdx)
        
        % manipulating test case data
        dataShaped = reshapeData(numberTimeSteps, dimensions, data)        
        dataFlat = flattenData(numberTimeSteps, dimensions, data)
        [dims, nts] = getDimAndTime(testData,timeValues)                   
        
        % methods used by sldvrun
        sldvData = save_data(model, testcomp)
        
         % methods used by sldvcompat
        sldvData = save_compat_data(modelH, testcomp, status)
        
        % methods used by sldvruntest
        sldvDatainTs = storeDataInTimeseries(model, sldvData)
        sldvDatainTs = storeDataInTimeseriesForSystemTest(sldvData)
        dataValueInTs = storeDataValuesInTimeseries(data, inportInfo, fundamentalTS)
        varName = assignSldvDataInBaseWS(sldvData)
        str = genExternalInputStrForTestCase(sldvData, idx, baseWsSldvDataVarName)                                
        dataValuesInCell =  storeDataValuesInCellFormatForLogging(...
            dataValuesInTs, PortInfo, ...
            funTsRefModel, funTsLoggeData, timeExpanded, minLogTime, maxLogTime)
        [dataValuesInCell, tsTimeInfo] = ...
            storeDataValuesInCellFormat(dataValuesInTs, PortInfo)        
        sldvData = storeDataInCellFormatForSystemTest(sldvDatainTs)   
        timeExpanded = expandTimeForTimeseries(time, fundamentalSampleTime, fundamentalSampleTimeExpand)        
        hasFxptInput = modelHasFixedPntInput(sldvData)
        hasFxptInterface = modelHasFixedPntInterface(sldvData)
        blockWithUspecBus = has_unspecified_bus_objects(model,sldvData)
        hasStructTypes = has_structTypes_interface(sldvData)
        
        % methods to convert the format of sldvData
        currentSldvData = convertToCurrentFormat(model, sldvData)  
        oldSldvData = convertToOldFormat(model, sldvData)  
        sldvDataExp = repeat_last_step(sldvData, forTimeSeries)
        
        % methods used by sldvDataUtils
        [goals, depth] = getTestCaseGoals(sldvData, idx)        
        warnmsg = saveDataToFile(sldvData, filename, createableSimData)                      
        newData = recordExpectedOutput(sldvData, model)          
        [sldvDataRandomized, warnmsg] = randomize(sldvData, randSeed)  

        % Getting test cases descriptions
        desc = getTestcaseDesc(sldvData, i)     
        
        % Setting the attributes of model for correct compiled info
        set_cache_compiled_bus(model, status)                
        
        % Map inport/outport information to original model
        sldvDataMapped = mapInportOutportInfo(sldvData);
        
        % Checking the input port info for Complexity 
        msgPortNames = hasComplexTypeInports(sldvData, modelH);
    end
end

% LocalWords:  sldvlogsignals sldvmakeharness
