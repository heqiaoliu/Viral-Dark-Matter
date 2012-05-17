function [sldvData, sampleTimeInformation] = generatDataForLogging(modelBlockH, sldvHarnessMdlH)

%   Copyright 2009-2010 The MathWorks, Inc.
    
    LoggedTestUnitInfo = [];                
    ReferencedModel = [];
    defaultTestCase = [];
    
    if ~isempty(modelBlockH)        
        referencedModelName = get_param(modelBlockH,'ModelName');   
        refmodelH = get_param(referencedModelName,'Handle');
        [InputPortInfo, OutputPortInfo, flatInfo] = ...
            Sldv.DataUtils.generateIOportInfo(refmodelH);        
                
        ReferencedModel.Name = referencedModelName;
        ReferencedModel.Version = get_param(refmodelH,'ModelVersion');
        ReferencedModel.Author = get_param(refmodelH,'Creator');
        ReferencedModel.InputPortInfo = InputPortInfo;
        ReferencedModel.OutputPortInfo = OutputPortInfo;
        ReferencedModel.SampleTimes = flatInfo.SampleTimes;
        sampleTimeInformation = flatInfo.ModelSampleTimesDetails;        
        
        ModelBlock.Path = getfullname(modelBlockH);
        ModelBlock.ReferencedModel = ReferencedModel;
        
        LoggedTestUnitInfo.ModelBlock = ModelBlock;       
                
        defaultTestCase = Sldv.DataUtils.createDefaultTC(flatInfo.InportCompInfo, true);
    end
    
    if ~isempty(sldvHarnessMdlH)
        SldvHarnessModel.Name = get_param(sldvHarnessMdlH, 'Name');
        SldvHarnessModel.Version = get_param(sldvHarnessMdlH,'ModelVersion');
        SldvHarnessModel.Author = get_param(sldvHarnessMdlH,'Creator'); 
        
        if ~isempty(ReferencedModel)
            SldvHarnessModel.TestUnitModel = ReferencedModel;
        else
            modelNameHarnessGenerated = ...
                    Sldv.HarnessUtils.getGeneratedModel(sldvHarnessMdlH);
            modelHHarnessGenerated = get_param(modelNameHarnessGenerated,'Handle');
            [InputPortInfo, OutputPortInfo, flatInfo] = ...
                Sldv.DataUtils.generateIOportInfo(modelHHarnessGenerated);
            
            TestUnitModel.Name = modelNameHarnessGenerated;
            TestUnitModel.Version = get_param(modelHHarnessGenerated,'ModelVersion');
            TestUnitModel.Author = get_param(modelHHarnessGenerated,'Creator');
            TestUnitModel.InputPortInfo = InputPortInfo;
            TestUnitModel.OutputPortInfo = OutputPortInfo;
            TestUnitModel.SampleTimes = flatInfo.SampleTimes;
            sampleTimeInformation = flatInfo.ModelSampleTimesDetails;            
            
            SldvHarnessModel.TestUnitModel = TestUnitModel;                        
            
            defaultTestCase = Sldv.DataUtils.createDefaultTC(flatInfo.InportCompInfo, true);                        
        end
        
        LoggedTestUnitInfo.SldvHarnessModel = SldvHarnessModel;                                                
    end                
    
    sldvData.LoggedTestUnitInfo = LoggedTestUnitInfo;
    sldvData.TestCases = defaultTestCase;    
end