classdef CodeCoverageSettings < hgsetget
%COVERAGESETTINGS allows configuration of code coverage settings 

%   Copyright 2010 The MathWorks, Inc.

    properties (GetAccess=private, Constant=true)
        CovClass = 'rtw.pil.Bullseye';
    end
    
    properties (SetAccess=public, GetAccess=public)
        TopModelCoverage;
        ReferencedModelCoverage;
        CoverageTool;
    end
    
    methods (Access=public, Static=true)
        
        function applyWrapper(covSettings,model)
        % Wrapper to do error checking before invoking the apply method
            if isempty(covSettings) || ...
                    ~isa(covSettings,'cov.CodeCoverageSettings')
                DAStudio.error('RTW:codeCoverage:invalidSettings');
            else
                covSettings.apply(model);
            end
        end
        
    end
    
    methods (Access=private, Static=true)
        
        function [topModel, refModels] = getCovSettingsFromHook(hook, model)

            if isempty(hook)
                
                topModel='off';
                refModels='off';
                
            else

                hookValid=true;
                
                if ~isempty(hook.argsAllComponents ) || ...
                        ~isempty(hook.excludedModels)
                    hookValid=false;
                end
                
                if hookValid
                    argsTopModelOnly=hook.argsTopModelOnly;
                    if ~iscell(argsTopModelOnly) || ...
                            ~(length(argsTopModelOnly)==2) || ...
                            ~strcmp(argsTopModelOnly{1},'CoverageForTopModel')
                        hookValid=false;
                    else
                        topModel=argsTopModelOnly{2};
                    end
                    if ~any(strcmp(topModel,{'on','off'}))
                        hookValid=false;
                    end
                end
                
                if hookValid
                    refModels=hook.includeReferencedModels;
                    if ~any(strcmp(refModels,{'on','off'}))
                        hookValid=false;
                    end
                end
                
                if ~hookValid
                    DAStudio.error('RTW:codeCoverage:InvalidBuildHook',model);
                end
            end
        end
    
    end
    
    methods (Access=private, Static=true)
        
        function str = cellToCommaSeparatedStr(cellArray)
            ca = strcat(cellArray,''',');
            ca = strcat('''', ca);
            str = strcat(ca{:});
            str = regexprep(str,'\s*'',',''', ');
            str = str(1:end-2);
        end
        
        
        function fullValue = validateSetting(value, allowedValues)
            validSetting = false;
            if ischar(value)
                idx = strmatch(value,allowedValues);
                if length(idx)==1
                    fullValue=allowedValues{idx};
                    validSetting=true;
                end
            end
            if ~validSetting
                allowedValuesStr=cov.CodeCoverageSettings.cellToCommaSeparatedStr...
                    (allowedValues);
                DAStudio.error('RTW:codeCoverage:InvalidCoverageSetting',...
                               value, allowedValuesStr);
            end                
        end

        
    end
    
    methods
        
        function obj = set.TopModelCoverage(obj,value)
            allowedValues = {'on','off'};
            obj.TopModelCoverage=cov.CodeCoverageSettings.validateSetting...
                (value,allowedValues);
        end
    
        function obj = set.ReferencedModelCoverage(obj,value)
            allowedValues = {'on','off'};
            obj.ReferencedModelCoverage=cov.CodeCoverageSettings.validateSetting...
                (value,allowedValues);
        end
    
        function obj = set.CoverageTool(obj,value)
            allowedValues = {'None','BullseyeCoverage'};
            obj.CoverageTool=cov.CodeCoverageSettings.validateSetting...
                (value,allowedValues);
        end
    
    end
    
    methods (Access=public)
        
        function this = CodeCoverageSettings(model)
            
            try
                % g354360
                get_param(model,'RTWBuildHooks');
            catch exc
                if strcmp(exc.identifier,'Simulink:Commands:ParamUnknown')
                    % Code coverage settings are not available
                    return
                else
                    rethrow(exc);
                end
            end
            
            hook = rtw.pil.BuildHook.getBuildHookForClass...
                   (model,cov.CodeCoverageSettings.CovClass);

            [this.TopModelCoverage,this.ReferencedModelCoverage]=...
                cov.CodeCoverageSettings.getCovSettingsFromHook(hook,model);
            
            this.CoverageTool=get_param(model,'ERTCodeCoverageTool');
        end
        
    
    end
    

    methods (Access=private)
        
        function apply(this, model)
            
            covTool=this.CoverageTool;
            if strcmp(covTool,'BullseyeCoverage')
                covTool='Bullseye'; % set_param requires short name
                covEnabled='on';
            else
                covEnabled='off';
            end
            set_param(model,'ERTCodeCoverageTool', covTool);
            
            if strcmp(this.TopModelCoverage,'off') && ...
                    strcmp(this.ReferencedModelCoverage,'off')
                rtw.pil.BuildHook.removeHook(model, cov.CodeCoverageSettings.CovClass);
            else
                if strcmp(this.TopModelCoverage,'on')
                    argsTopModelOnly = {'CoverageForTopModel','on'};
                else
                    argsTopModelOnly = {'CoverageForTopModel','off'};
                end
                if strcmp(this.ReferencedModelCoverage,'on')
                    includeReferencedModels='on';
                else
                    includeReferencedModels='off';
                end
                rtw.pil.BuildHook.addHook...
                    (model, cov.CodeCoverageSettings.CovClass,...
                     'ArgsTopModelOnly',argsTopModelOnly,...
                     'IncludeReferencedModels', includeReferencedModels,...
                     'Enabled',covEnabled);
            end
        end
    end
    
end
