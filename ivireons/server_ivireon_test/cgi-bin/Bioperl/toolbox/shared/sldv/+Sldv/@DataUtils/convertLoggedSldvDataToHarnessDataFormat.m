function [sldvData, errorMsg] = convertLoggedSldvDataToHarnessDataFormat(sldvDataLogged, copyModelH)    

%   Copyright 2009-2010 The MathWorks, Inc.

    errorMsg = '';
    sldvData = [];
    
    if nargin<2
        copyModelH = [];
    end
    
    if ~isfield(sldvDataLogged,'LoggedTestUnitInfo')
        sldvData = sldvDataLogged;
        return;
    end
    
    sldvDataLogged = updateModelIfo(sldvDataLogged, copyModelH);
    
    LoggedTestUnitInfo = sldvDataLogged.LoggedTestUnitInfo;        
    
    if isfield(LoggedTestUnitInfo,'ModelBlock')
        ModelHarnessedInfo = LoggedTestUnitInfo.ModelBlock.ReferencedModel;
    else
        assert(isfield(LoggedTestUnitInfo,'SldvHarnessModel'))
        ModelHarnessedInfo = LoggedTestUnitInfo.SldvHarnessModel.TestUnitModel;
    end
    isLoaded = bdIsLoaded(ModelHarnessedInfo.Name);
    if ~isLoaded
        errorMsg = xlate(['The sldvData argument of sldvmakeharess ',...
            'is generated from sldvlogsignals or slvnvlogsignals. Model ''%s'' must be loaded ',...
            'to generate harness model from this sldvData.']);  
        errorMsg = sprintf(errorMsg,ModelHarnessedInfo.Name);  
        return
    end       
    
    %Create Model Information
    ModelInformation.Name = get_param(ModelHarnessedInfo.Name, 'Name');
    ModelInformation.Version = get_param(ModelHarnessedInfo.Name,'ModelVersion');
    ModelInformation.Author = get_param(ModelHarnessedInfo.Name,'Creator'); 
       
    sldvOptions = sldvdefaultoptions(ModelHarnessedInfo.Name);
    
    AnalysisInformation.Status = [];
    AnalysisInformation.AnalysisTime = 0;
    AnalysisInformation.Options = sldvOptions;
    AnalysisInformation.InputPortInfo = ModelHarnessedInfo.InputPortInfo;
    AnalysisInformation.OutputPortInfo = ModelHarnessedInfo.OutputPortInfo;
    AnalysisInformation.SampleTimes = ModelHarnessedInfo.SampleTimes;
    
    sldvData.ModelInformation = ModelInformation;
    sldvData.AnalysisInformation = AnalysisInformation;    
    sldvData.Constraints = [];
    sldvData.ModelObjects = [];
    sldvData.Objectives = []; 
    
    [sldvData, dataUpdated] = ...
        Sldv.DataUtils.addComplexityInformation(sldvData, ModelHarnessedInfo.Name);
    if ~dataUpdated
        %If Used flag is not on the AnalysisInformation, then add it. 
        %If data is already updated then it must be there. 
        sldvData = Sldv.DataUtils.addInportUsage(sldvData);
    end
    
    sldvData = Sldv.DataUtils.setSimData(sldvData,[],sldvDataLogged.TestCases);                
    sldvData = correctTestCaseFields(sldvData);
    sldvData = Sldv.DataUtils.compressSldvData(sldvData);        
    
    % Version is empty because DV might not be installed
    sldvData.Version = '';
end

function sldvDataLogged = updateModelIfo(sldvDataLogged, copyModelH)
    if ~isempty(copyModelH)
        LoggedTestUnitInfo = sldvDataLogged.LoggedTestUnitInfo;            
        if isfield(LoggedTestUnitInfo,'ModelBlock')
            LoggedTestUnitInfo.ModelBlock.ReferencedModel.Name = ...
                get_param(copyModelH,'Name');            
            if isfield(LoggedTestUnitInfo,'SldvHarnessModel')
                LoggedTestUnitInfo.SldvHarnessModel.TestUnitModel.Name = ...
                    get_param(copyModelH,'Name');
            end
            sldvDataLogged.LoggedTestUnitInfo = LoggedTestUnitInfo;
        end
    end
end

function sldvData = correctTestCaseFields(sldvDataLogged)
    sldvData = sldvDataLogged;
    SimData = Sldv.DataUtils.getSimData(sldvData);
    if isempty(SimData)        
        return;
    end
    sldvData = rmfield(sldvData,'TestCases');
    numTestCases = length(SimData);
    TestCases(1:numTestCases) = struct(...
                                    'timeValues', [],...
                                    'dataValues', [],...
                                    'paramValues',[], ...
                                    'stepValues', [],... 
                                    'objectives', [],...
                                    'dataNoEffect', []);                                    
    for i=1:numTestCases           
        simData = SimData(i);     
        TestCases(i).timeValues = simData.timeValues;
        TestCases(i).dataValues = simData.dataValues;
        TestCases(i).paramValues = simData.paramValues;                
    end
    sldvData.TestCases = TestCases;
end
% LocalWords:  sldvlogsignals sldvmakeharess slvnvlogsignals
