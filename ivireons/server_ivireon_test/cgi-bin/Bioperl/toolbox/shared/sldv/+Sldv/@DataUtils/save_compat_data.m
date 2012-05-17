function sldvData = save_compat_data(modelH, testcomp, status)

%   Copyright 2010 The MathWorks, Inc.

    settings = testcomp.activeSettings;     
    
    if ~isempty(testcomp.analysisInfo)
        ModelInformation = Sldv.DataUtils.getModelInformation(modelH,'datagen');
    else
        ModelInformation = [];
    end
    if ~isempty(testcomp.mdlFlatIOInfo)
        [InputPortInfo, OutputPortInfo, flatInfo] = ...
            Sldv.DataUtils.generateIOportInfo(modelH);
    else
        InputPortInfo = [];
        OutputPortInfo = [];
        flatInfo = [];
    end
    if ~isempty(testcomp.mdlSampleTimes)
        mdlSampleTimes = testcomp.mdlSampleTimes;
    else
        mdlSampleTimes = [];
    end
    
    AnalysisInformation.Status = status;
    AnalysisInformation.AnalysisTime = 0;
    AnalysisInformation.Options = settings.deepCopy;
    AnalysisInformation.InputPortInfo = InputPortInfo;
    AnalysisInformation.OutputPortInfo = OutputPortInfo; 
    AnalysisInformation.SampleTimes = mdlSampleTimes;  
    
    sldvData.ModelInformation = ModelInformation;
    sldvData.AnalysisInformation = AnalysisInformation;
    sldvData.ModelObjects = [];
    sldvData.Constraints = [];
    sldvData.Objectives = [];    
    
    if ~isempty(flatInfo)
        defaultTestCase = Sldv.DataUtils.createDefaultTC(flatInfo.InportCompInfo);
        sldvData = Sldv.DataUtils.setSimData(sldvData,[],defaultTestCase);        
        sldvData = Sldv.DataUtils.compressSldvData(sldvData);        
    else
        sldvData = Sldv.DataUtils.setSimData(sldvData,[],[]);
    end
    sldvData = Sldv.DataUtils.setVersionToCurrent(sldvData);
end
% LocalWords:  testcomponent datagen
