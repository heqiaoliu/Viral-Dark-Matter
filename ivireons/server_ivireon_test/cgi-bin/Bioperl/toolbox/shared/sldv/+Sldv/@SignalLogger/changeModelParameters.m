function changeModelParameters(obj)

%   Copyright 2008-2010 The MathWorks, Inc.
    
    if isempty(obj.ModelBlockH)
        return;
    end
    
    if ~obj.UseParComp
        % If parfor is used we will not change the referenced models
        % because each parfor loop will reload them.     
        
        paramNameValStruct.AssertControl = 'DisableAll';
        if ~strcmp(get_param(obj.ModelBlockH,'SimulationMode'),'Normal')       
            obj.RequiresMexRebuild = true;
            paramNameValStruct.UpdateModelReferenceTargets = 'AssumeUpToDate';
        else
            paramNameValStruct.UpdateModelReferenceTargets = 'IfOutOfDate';
        end
        paramNameValStruct.SFSimEnableDebug = 'off';
        
        modelH = obj.RefModelH;
        modelName = get_param(modelH,'Name');
        currentParamNameValStruct = paramNameValStruct;
        
        origDirty = get_param(modelH,'Dirty');
        
        currenConfigSet = getActiveConfigSet(modelH);
        % Parameters will be changed remove the current ones
        Sldv.utils.removeConfigSetRef(modelH);

        % Change model parameters and store the existing ones
        modelInfo = ...
            Sldv.SimModel.changeMdlParams(modelH, currentParamNameValStruct);    
        
        % OldConfigSet should be the last element in the struct filed list
        modelInfo.OldConfigSet = currenConfigSet;

        obj.MdlParametersMap(modelName)=modelInfo;

        set_param(modelH,'Dirty',origDirty);             
    end                                      
end