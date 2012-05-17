function runTests(obj)

%   Copyright 2009 The MathWorks, Inc.

    obj.SldvData = ...
            Sldv.DataUtils.storeDataInTimeseries(obj.ModelH,...
            obj.SldvData);
        
    obj.SimDataTimeSeries = Sldv.DataUtils.getSimData(obj.SldvData);
    numTestCases = length(obj.TcIdx);
        
    obj.cacheBaseWorkspaceVars;
    obj.turnOffAndStoreWarningStatus;
    obj.initForSim;       
    
    obj.BaseWSSldvDataName = Sldv.DataUtils.assignSldvDataInBaseWS(obj.SldvData);
       
    numInports = length(obj.InportBlkHs);
    paramNameValStruct = obj.getBaseSimStruct;
    if ~obj.UseParComp
        paramNameValStructCurrent = paramNameValStruct;
    else           
        inputNames = cell(1,numInports);
        inputStr = '';
        for idx=1:numInports
            inputNames{idx} = sprintf('%s_In%d',obj.BaseWSSldvDataName,idx);
            if idx~=numInports
                inputStr = sprintf('%s%s,',inputStr,inputNames{idx});
            else
                inputStr = sprintf('%s%s',inputStr,inputNames{idx});
            end
        end
        paramNameValStructCurrent = cell(1,numTestCases);        
        for idx=1:numTestCases
            paramNameValStructCurrent{idx} = obj.modifySimstruct(obj.TcIdx(idx), paramNameValStruct);            
            paramNameValStructCurrent{idx}.ExternalInput = inputStr;
        end        
    end
    
    simOut = cell(1,numTestCases);          
    covOut = cell(1,numTestCases); 
       
    if ~obj.UseParComp                
        for idx=1:numTestCases
            obj.changeBaseWSVar(obj.TcIdx(idx));
            paramNameValStructCurrent = obj.modifySimstruct(obj.TcIdx(idx), paramNameValStruct);
            if obj.GetCoverage                                
                test = cvtest(obj.Model);
                if ~isempty(obj.CvTestSpec)                    
                    test.settings = obj.CvTestSpec.settings;
                    test.modelRefSettings = obj.CvTestSpec.modelRefSettings;
                    test.emlSettings = obj.CvTestSpec.emlSettings;
                    test.options = obj.CvTestSpec.options;
                else
                    test.modelRefSettings.enable = 'On';
                    test.modelRefSettings.excludeTopModel = 0;
                    test.modelRefSettings.excludedModels = '';
                    test.emlSettings.enableExternal = 1;
                end 
                [covOut{idx}, simOut{idx}] = cvsim(test,paramNameValStructCurrent);                
            else
                simOut{idx} = sim(obj.Model,paramNameValStructCurrent);
            end
        end                 
    else
        model = obj.Model;
        simDataTimeSeries = obj.SimDataTimeSeries;          
        mdlDir = fileparts(get_param(obj.ModelH,'FileName'));         
        measuringCov = obj.GetCoverage;        
                        
        addMdlDirToPath = obj.ModelH~=obj.OrigModelH;                
                        
        if addMdlDirToPath
            addpath(mdlDir);
        end
        matlabpool('open');            
        parfor idx=1:numTestCases             
            sldvTestCases = simDataTimeSeries(idx).dataValues;
            for jdx=1:numInports
                assignin('base', inputNames{jdx}, sldvTestCases{jdx}); %#ok<PFBNS,PFEVB>
            end
            sldvParameters = simDataTimeSeries(idx).paramValues;
            for jdx=1:length(sldvParameters)
                assignin('base', sldvParameters(jdx).name, sldvParameters(jdx).value); %#ok<PFEVB>
            end                                                
            load_system(model);     
            if measuringCov
                simOut{idx} = sim(model,paramNameValStructCurrent{idx});  
            else
                simOut{idx} = sim(model,paramNameValStructCurrent{idx});                
            end
            for jdx=1:numInports
                evalin('base', [ 'clear(''' inputNames{jdx} ''');' ]); %#ok<PFEVB>
            end
        end                        
        matlabpool('close');
        if addMdlDirToPath
            rmpath(mdlDir);
        end                                      
    end                        
        
    outData(1:numTestCases) = struct('T',[],'X',[],'Y',[]);        
    for idx=1:numTestCases
        outData(idx).T = simOut{idx}.find(paramNameValStruct.TimeSaveName);
        outData(idx).X = simOut{idx}.find(paramNameValStruct.StateSaveName);
        outData(idx).Y = ...
            obj.reshapeOutValue(simOut{idx}.find(paramNameValStruct.OutputSaveName),...
            simOut{idx}.find(paramNameValStruct.SignalLoggingName));
    end
    obj.OutData = outData;
        
    if obj.GetCoverage        
        cvData = covOut{1};
        for idx=2:numTestCases
            cvData = cvData+covOut{idx};
        end
        obj.CvData = cvData;
    end    
end