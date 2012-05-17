function changeModelParameters(obj)

%   Copyright 2008-2010 The MathWorks, Inc.
    
    modelHsToChange = obj.ModelHsInMdlRefTree;
    index = modelHsToChange==obj.ModelH;
    modelHsToChange(index) = [];
    if isempty(modelHsToChange)
        return;
    end
                
    if ~obj.UseParComp
        % If parfor is used we will not change the referenced models
        % because each parfor loop will reload them.     
        paramNameValStruct.AssertControl = 'DisableAll';
        paramNameValStruct.UpdateModelReferenceTargets = 'IfOutOfDate';
        if ~obj.GetCoverage                
            paramNameValStruct.SFSimEnableDebug = 'off';                           
        else
            paramNameValStruct.SFSimEnableDebug = 'on';                                            
        end
        for idx=1:length(modelHsToChange)
            modelH = modelHsToChange(idx);
            modelName = get_param(modelH,'Name');
            currentParamNameValStruct = paramNameValStruct;
            if ~obj.MdlParametersMap.isKey(modelName)
                origDirty = get_param(modelH,'Dirty');
                
                if obj.GetCoverage && ~any(modelH==obj.ModelHsNormalMode)
                    % Referenced model is not in normal mode. You cannot
                    % measure coverage in anyway. Turn off debugging on
                    % Stateflow and EML
                    currentParamNameValStruct.SFSimEnableDebug = 'off';    
                end
                
                currenConfigSet = getActiveConfigSet(modelH);
                % Parameters will be changed remove the current ones
                Sldv.utils.removeConfigSetRef(modelH);
                
                % Change model parameters and store the existing ones
                modelInfo = ...
                    Sldv.SimModel.changeMdlParams(modelH, currentParamNameValStruct);    
                
                if strcmp(currentParamNameValStruct.SFSimEnableDebug,'on')    
                    % We are measuring coverage.
                    % SFSimEnableDebug is turned on to measure coverage.
                    % However, stop the sf debugger
                    % Make sure that debugging is enabled on EML blocks
                    modelInfo = Sldv.SimModel.updateEMLSFSettings(modelH, modelInfo);                                        
                end
                
                % OldConfigSet should be the last element in the struct filed list
                modelInfo.OldConfigSet = currenConfigSet;
                
                obj.MdlParametersMap(modelName) = modelInfo;
                
                set_param(modelH,'Dirty',origDirty);       
            end
        end
    end                   
end