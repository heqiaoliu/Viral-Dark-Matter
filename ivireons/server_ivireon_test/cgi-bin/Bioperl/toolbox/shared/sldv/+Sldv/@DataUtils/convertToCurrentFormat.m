function currentSldvData = convertToCurrentFormat(model, sldvData)

%   Copyright 2008-2010 The MathWorks, Inc.
       
    currentSldvData = sldvData;    
    if ~isfield(currentSldvData,'LoggedTestUnitInfo')                        
        model = getModelName(model);        
        if ~isfield(currentSldvData,'Version') || ...
                Sldv.DataUtils.dataVersionLessThan(currentSldvData,'1.3')            

            currentSldvData = setModelInformation(model, currentSldvData);    
            currentSldvData = setAnalysisInformation(model, currentSldvData);               
            currentSldvData.Constraints = [];

            SimData = Sldv.DataUtils.getSimData(currentSldvData);
            if isempty(SimData)
                % sldvData doesn't have test cases or counter examples
                return;
            end  

            currentSldvData.TestCases = rmfield(currentSldvData.TestCases,'portDimensions');
            currentSldvData.TestCases = rmfield(currentSldvData.TestCases,'signalLabels');           

            SimData = Sldv.DataUtils.getSimData(currentSldvData);
            for i=1:length(SimData)                
                simData = SimData(i);     
                newsimData = simData;

                if isempty(simData.dataValues)            
                    continue;
                end 

                newsimData.dataValues = {};
                newsimData.dataNoEffect = {};                

                for j=1:length(simData.dataValues)       
                    [dataValues, dataNoEffect] = Sldv.DataUtils.constructDataValuesForInport( ...                                                                                                                          
                                                                    currentSldvData.AnalysisInformation.InputPortInfo{j}, ...
                                                                    simData.timeValues, ...                                                            
                                                                    simData.dataValues{j}, ...
                                                                    simData.dataNoEffect{j}, ...
                                                                    true);

                    newsimData.dataValues{end+1} = dataValues;
                    newsimData.dataNoEffect{end+1} = dataNoEffect;
                end        
                newsimData =  Sldv.DataUtils.compressTestCaseData(newsimData);        
                currentSldvData = Sldv.DataUtils.setSimData(currentSldvData,i,newsimData);                
            end    
            currentSldvData = Sldv.DataUtils.setVersionToCurrent(currentSldvData);            
        elseif Sldv.DataUtils.dataVersionLessThan(currentSldvData,'1.7')       
            currentSldvData.Constraints = [];
            [currentSldvData, dataUpdated] = ...
                Sldv.DataUtils.addComplexityInformation(currentSldvData, model);
            if ~dataUpdated
                %If Used flag is not on the AnalysisInformation, then add it. 
                %If data is already updated then it must be there. 
                currentSldvData = Sldv.DataUtils.addInportUsage(currentSldvData);
            end
            currentSldvData = Sldv.DataUtils.setVersionToCurrent(currentSldvData);
        end
    end    
end

function model = getModelName(model)
    errStr = Sldv.DataUtils.check_model_arg(model, 'convertToCurrentFormat');
    if ~isempty(errStr)
        error('SLDV:DataUtils:ConvertToCurrentFormat:WrongParameter', errStr);                
    end

    if ~ischar(model)
        model = get_param(model,'Name');
    end
end

function sldvData = setAnalysisInformation(model, sldvData)    
    opts = sldvdefaultoptions(model);
    
    currAnalysisInformation.Status = sldvData.AnalysisInformation.Status;
    currAnalysisInformation.AnalysisTime = 0;
    currAnalysisInformation.Options = opts.deepCopy;
    
    [InputPortInfo, OutputPortInfo] = Sldv.DataUtils.generateIOportInfo(model);    
    currAnalysisInformation.InputPortInfo = InputPortInfo;
    currAnalysisInformation.OutputPortInfo = OutputPortInfo;
                          
    currAnalysisInformation.SampleTimes = sldvData.AnalysisInformation.SampleTimes;
    
    sldvData.AnalysisInformation = currAnalysisInformation;
end

function currentsldvData = setModelInformation(model, sldvData)
    ModelInformation = Sldv.DataUtils.getModelInformation(model,'dataconvert');    
    currentsldvData.ModelInformation = ModelInformation;
    fields = fieldnames(sldvData);
    for i=1:length(fields)
        currentsldvData.(fields{i}) = sldvData.(fields{i});
    end    
end