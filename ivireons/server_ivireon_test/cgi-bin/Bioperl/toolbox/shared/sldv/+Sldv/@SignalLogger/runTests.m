function runTests(obj)

%   Copyright 2009 The MathWorks, Inc.
    
    obj.turnOffAndStoreWarningStatus;
    obj.initForSim;    
    
    [sldvData, sampleTimeInformation] = Sldv.DataUtils.generatDataForLogging(obj.ModelBlockH, ...
        obj.SldvHarnessModelH);   
    obj.checkRefModelSampleTimes(sampleTimeInformation);   
    obj.checkForComplexType(Sldv.DataUtils.convertLoggedSldvDataToHarnessDataFormat(sldvData));
    
    paramNameValStruct = obj.getBaseSimStruct;
    
    parentSystemNames = findParentSubsystems(obj.ModelBlockH);
    
    emptyTest = sldvData.TestCases; 
    
    if ~isempty(obj.SldvHarnessModelH)   
        numTests = length(obj.TcIdx);        
        [sbTime, ~] = signalbuilder(obj.SigBlockH);
        if ~iscell(sbTime)
            sbTime = {sbTime};
        end          
        obj.SigBTime = sbTime;
        modelToSim = get_param(obj.SldvHarnessModelH,'Name');
        for idx=1:numTests            
            signalbuilder(obj.SigBlockH, 'ActiveGroup', obj.TcIdx(idx));            
            paramNameValStructCurrent = obj.modifySimstruct(obj.TcIdx(idx), paramNameValStruct);
            simOut = sim(modelToSim, paramNameValStructCurrent);                          
            modelDataLogger = obj.findModelDataLogger(parentSystemNames,...
                simOut.find(paramNameValStruct.SignalLoggingName));
            sldvData.TestCases(idx) = getCurrentTest(modelDataLogger,obj.PortHsToLog,emptyTest);
        end                                       
    else                                                    
        modelToSim = get_param(obj.TopLevelModelH,'Name');                         
        simOut = sim(modelToSim, paramNameValStruct);                            
        modelDataLogger = obj.findModelDataLogger(parentSystemNames,...
            simOut.find(paramNameValStruct.SignalLoggingName));
        sldvData.TestCases = getCurrentTest(modelDataLogger,obj.PortHsToLog,emptyTest);        
    end
        
    obj.LoggedData = Sldv.DataUtils.convertLoggedTsSldvDataToCellFormat(sldvData);              
end

function parentSystemNames = findParentSubsystems(modelBlockH)
    parentSystemNames = {};        
    if ~isempty(modelBlockH)
        parentSystemNames{end+1} = get_param(modelBlockH,'Name');
        parent = get_param(modelBlockH,'parent');        
        while ~strcmp(get_param(parent,'Type'),'block_diagram')
            parentSystemNames{end+1} = get_param(parent,'Name');   %#ok<AGROW>
            parent = get_param(parent,'parent');
        end            
        parentSystemNames = parentSystemNames(length(parentSystemNames):-1:1);        
    end
end

function currentTest = getCurrentTest(modelDataLogger,portHs,emptyTest)        
    currentTest = emptyTest;            
    for idx = 1:length(portHs) 
        loggerVar = get_param(portHs(idx),'DataLoggingName');
        currentTest.dataValues{idx} = modelDataLogger.(loggerVar);        
    end    
end

