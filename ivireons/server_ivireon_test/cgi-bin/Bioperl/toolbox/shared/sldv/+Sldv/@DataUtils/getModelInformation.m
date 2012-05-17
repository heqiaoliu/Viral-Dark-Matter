function modelinfo = getModelInformation(model,activity)

%   Copyright 2008-2010 The MathWorks, Inc.

    modelinfo = [];

    if ischar(model)
        try
            modelH = get_param(model,'Handle');
        catch myException %#ok<NASGU>
            modelH = [];
        end
    else
        modelH = model;
    end
    
    analyzedModelH = modelH;
    SubsystemPath = '';          
    ExtractedModel = '';
    ReplacementModel = '';
    
    if strcmp(activity,'datagen')           
        testcomp = Sldv.Token.get.getTestComponent;
        designModelH = testcomp.analysisInfo.designModelH;        
        if ~isempty(testcomp.analysisInfo.analyzedSubsystemH)
            SubsystemPath = getfullname(testcomp.analysisInfo.analyzedSubsystemH);            
            ExtractedModel = get_param(testcomp.analysisInfo.extractedModelH,'Name');
            if ~isempty(testcomp.analysisInfo.replacementInfo.replacementModelH)            
                ReplacementModel = get_param(testcomp.analysisInfo.replacementInfo.replacementModelH,'Name'); 
            end
        else
            if ~isempty(testcomp.analysisInfo.replacementInfo.replacementModelH)        
                ReplacementModel = get_param(testcomp.analysisInfo.replacementInfo.replacementModelH,'Name'); 
            end
        end                           
    elseif strcmp(activity,'dataconvert')                
        designModelH = analyzedModelH;        
    else
        error('SLDV:DataUtils:getModelInformation:WrongActivity',...
            'wrong activity');
    end         
    
    modelinfo.Name = get_param(designModelH,'Name');
    modelinfo.Version = get_param(designModelH,'ModelVersion');
    modelinfo.Author = get_param(designModelH,'Creator');     
    
    if ~isempty(SubsystemPath)        
        modelinfo.SubsystemPath = SubsystemPath;                    
        modelinfo.ExtractedModel = ExtractedModel;
    end
       
    if ~isempty(ReplacementModel)
        modelinfo.ReplacementModel = ReplacementModel;
    end
    
end
% LocalWords:  datagen testcomponent dataconvert
