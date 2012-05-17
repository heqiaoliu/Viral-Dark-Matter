function saveExtractedModel(obj)

%   Copyright 2010 The MathWorks, Inc.

    if obj.SldvExist
        testcomp = Sldv.Token.get.getTestComponent;
        if ~isempty(testcomp)
            duringTranslation = true;
            opts = testcomp.activeSettings;        
        else
            duringTranslation = false;
            opts = sldvoptions;
            opts.OutputDir = '.';
        end
    else
        testcomp = [];
        duringTranslation = false;
        opts = sldvdefaultoptions;
        opts.OutputDir = '.';
    end

    extractedModelName = get_param(obj.ModelH,'Name');        
    extractedModelFullPath = deriveExtractedModelName(extractedModelName, obj.ModelH, opts);            
    if isempty(extractedModelFullPath)
        obj.ModelH = [];
        obj.Status = false;
        obj.ErrMsg = 'Unable to generate an mdl file for the extracted model.';
        return;
    end 
    
    obj.PhaseId = 2;
    obj.turnOffAndStoreWarningStatus;
       
    obj.restoreLibLinks;
    obj.fixAtomicSubchartMask;
    try
        save_system(obj.ModelH,extractedModelFullPath);        
    catch Mex         %#ok<NASGU>
        obj.ModelH = [];
        obj.Status = false;
        obj.ErrMsg = ...
            sprintf('An error occurred while saving extracted model.');        
    end
        
    obj.restoreWarningStatus;
    obj.PhaseId = 0;

    if ~obj.Status
        return;
    end
    
    if obj.ShowModel
        set_param(obj.ModelH,'Open','on');
    end        
        
    if duringTranslation
        testcomp.analysisInfo.analyzedModelH = obj.ModelH;
        testcomp.analysisInfo.extractedModelH = obj.ModelH;
        testcomp.analysisInfo.analyzedSubsystemH = obj.SubSystemH;        
        testcomp.analysisInfo.analyzedAtomicSubchartWithParam = obj.AtomicSubChartWithParam;
        testcomp.analysisInfo.mappedSfId = ...
            containers.Map('KeyType', 'double', 'ValueType', 'double');
        testcomp.analysisInfo.mappedBlockH = ...
            containers.Map('KeyType', 'double', 'ValueType', 'double');      
    end       
end

function extractedModelFullPath = deriveExtractedModelName(extractedModelName, modelH, opts)
    MakeOutputFilesUnique = 'off';
    extractedModelFullPath = Sldv.utils.settingsFilename(extractedModelName,MakeOutputFilesUnique,...
            '.mdl', modelH, false, true, opts);
end

% LocalWords:  testcomponent
