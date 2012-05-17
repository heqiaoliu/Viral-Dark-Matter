
%   Copyright 2009-2010 The MathWorks, Inc.

classdef SimModel < handle
    %SIMMODEL Base class for simulating models 
    %   
    
    properties (Access = protected)
        % MsgIdPref - Id for generating errors and warnings
        MsgIdPref = '';
        
        %Autosave state of Simulink preferences before simulation
        CachedAutoSaveState = [];
        
        %SignalLoggerPrefix - Prefix for signal logger names
        SignalLoggerPrefix = '';
        
        %PortHsToLog - Array of port handles to log
        PortHsToLog = [];
        
        % TcIdx - TestCasesThat should run 
        TcIdx = [];
        
        %Cell array storing the status of warnings before logging
        OriginalWarningStatus = {};     
        
        %MdlParametersMap - Model name to original model settings map. This
        %map will not include settings for the top level model                                        
        MdlParametersMap = [];                
        
        %MdlLoaded - Name of the model that is load 
        MdlLoaded = {};
        
        %ModelHsNormalMode - Handles of the models that are in normal mode
        %in model reference hierarchy
        ModelHsNormalMode = [];
        
        %ModelsInMdlRefTree - Handles of the models in model hierarchy
        ModelHsInMdlRefTree = [];                
                       
        % SettingsCache - Structure storing the model settings before
        % changing 
        SettingsCache = [];       
        
        % DirtyStatus - Structure where each field represents the dirty
        % status of models in model hierarchy
        DirtyStatus = [];
        
        % ExistingLoggerConfig - Struct array storing the config of
        % current loggers
        ExistingLoggerConfig = [];             
        
        %ModelLogger - Name of the logger object used in simulation
        ModelLogger = 'dvlogsout';
        
        %UseParFor - True if parfor should be used
        UseParComp = false;
        
        %UtilityName - Name of the utility
        UtilityName = '';                          
    end
    
    methods
         function obj = SimModel    
             obj.MdlParametersMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
         end         
         
         function delete(obj)
             delete(obj.MdlParametersMap);
         end
    end
    
    methods (Access = protected)      
        function restoreModelBack(obj)
            % Restore back 
            obj.restoreInterpForInports;
            obj.restoreBaseWorkspaceVars;            
            obj.restoreModelParameters;
            obj.restoreOriginalModelParams;
            obj.restoreWarningStatus;

            % Restore back the models loaded
            obj.restoreLoadedModels;  

            obj.restoreAutoSaveState;    
        end
        
        function configureAutoSaveState(obj)
            if isempty(obj.CachedAutoSaveState)
                old_autosave_state=get_param(0,'AutoSaveOptions');
                obj.CachedAutoSaveState = old_autosave_state;
                new_autosave_state=old_autosave_state;
                new_autosave_state.SaveOnModelUpdate=0;
                new_autosave_state.SaveBackupOnVersionUpgrade=0;
                set_param(0,'AutoSaveOptions',new_autosave_state);                
            end
        end
        
        function restoreAutoSaveState(obj)
            if ~isempty(obj.CachedAutoSaveState)
                old_autosave_state = obj.CachedAutoSaveState;
                set_param(0,'AutoSaveOptions',old_autosave_state);
                obj.CachedAutoSaveState = [];
            end
        end    
        
        function resetSessionData(obj)        
            obj.restoreModelBack;   
            obj.stopMatlabPool;                    
        end
        
        function handleMsg(obj, msgOpt, strId, strMsg, varargin)            
            strId = [obj.MsgIdPref, strId];            
            switch msgOpt
                case 'warning'
                    sldvshareprivate('util_gen_warning_notrace',strId, strMsg, varargin{1:end});
                case 'error'
                    obj.resetSessionData;
                    error(strId, strMsg, varargin{1:end});
                otherwise
                    assert(false, 'Unexpected msg value');
            end
        end       
        
        cacheExistingLoggers(obj)
        %cacheExistingLoggers Stores the settings of the loggers that are
        %changed
        
        restoreLoggers(obj, modelHIncludingLoggers)
        %restoreLoggers Restore the logger status
        
        configureLoggers(obj, modelHIncludingLoggers)
        %configureLoggers Configure the loggers on the model     
        
        function turnOffAndStoreWarningStatus(obj)
            warningIds = obj.listWarningsToTurnForLogging;
            warningStatus = cell(1,length(warningIds));
            for i=1:length(warningIds)        
                warningStatus{i} = warning('query',char(warningIds{i})); 
                warning('off',char(warningIds{i})); 
            end            
            obj.OriginalWarningStatus = warningStatus;
        end
        
        function restoreWarningStatus(obj)
            if ~isempty(obj.OriginalWarningStatus)
                warningIds = obj.listWarningsToTurnForLogging;            
                warningStatus = obj.OriginalWarningStatus;
                for i=1:length(warningIds)        
                    warning(warningStatus{i}.state,char(warningIds{i}));
                end     
                obj.OriginalWarningStatus = {};
            end
        end                 
        
        function restoreLoadedModels(obj)
            if ~isempty(obj.MdlLoaded)
                for idx=1:length(obj.MdlLoaded)
                    close_system(obj.MdlLoaded{idx},0);
                end
                obj.MdlLoaded = {};
            end   
        end                                   
                 
        function restoreModelParameters(obj)                        
            entries = obj.MdlParametersMap.keys;
            if ~isempty(entries) 
                for idx=1:length(entries)        
                    modelName = entries{idx};  
                    modelH = get_param(modelName,'Handle');
                    origDirty = get_param(modelH,'Dirty');
                    buildInfo = obj.MdlParametersMap(entries{idx});
                    paramNames = fields(buildInfo);
                    for jdx=1:length(paramNames)
                        if strcmp(paramNames{jdx},'OldConfigSet')
                            assert(jdx==length(paramNames));
                            oldConfigSet = buildInfo.(paramNames{jdx});
                            Sldv.utils.restoreConfigSet(modelName, oldConfigSet);                                        
                        elseif strcmp(paramNames{jdx},'SfDebugSettings')
                            Sldv.utils.setSFDebugSettings(modelH, buildInfo.(paramNames{jdx}));
                        elseif strcmp(paramNames{jdx},'EmlDebugSettings')
                            Sldv.utils.settingsValueHandler(buildInfo.(paramNames{jdx}), '', false);
                        else
                            set_param(modelName,paramNames{jdx},buildInfo.(paramNames{jdx}));
                        end
                    end     
                    set_param(modelH,'Dirty',origDirty);       
                end                      
            end
        end                                            
        
        function restoreDirtyStatus(obj)
            modelNames = fieldnames(obj.DirtyStatus);
            for idx=1:length(modelNames)
                set_param(modelNames{idx},'Dirty',obj.DirtyStatus.(modelNames{idx}));
            end            
        end                
        
        function restoreInterpForInports(obj) %#ok<MANU>
        end
        
        function restoreBaseWorkspaceVars(obj) %#ok<MANU>
        end     
        
        function checkMatlabPool(obj)
            poolsize = matlabpool('size');
            if poolsize~=0
                msgId = 'UseParforVal';                       
                msg = xlate(['Invalid usage of sldvruntest. ', ...                           
                           'Parallel computation can be used ', ...
                           'in simulating test cases only if current worker pool is closed.']);                       
                obj.handleMsg('error', msgId, msg);               
            end
        end                                      
    end        
    
    methods (Abstract, Access = protected)                   
        storeOriginalModelParams(obj)
        %storeOriginalModelParams Store the original settings of the model
        %that will be simulated
        
        restoreOriginalModelParams(obj)     
        %restoreOriginalModelParams Restore the model parameters
        
        derivePortHandlesToLog(obj)           
        %derivePortHandlesToLog Identify the port handles to attach loggers                                
        
        initForSim(obj)            
        %initForSim Initialize the model parameters before starting
        %simulation                
        
        paramNameValStruct = getBaseSimStruct(obj)
        %getBaseSimStruct Return the simulation parameters in a structure
        %format
        
        paramNameValStruct = modifySimstruct(obj, testIndex, paramNameValStruct)
        %modifySimstruct Modify the simulation parameters for the current
        %test case
        
        runTests(obj)       
        %runTests Run tests                 
        
        listWarningsToTurnForLogging(obj)  
        
        changeModelParameters(obj)
    end        
    
    methods (Access = protected, Static)                
        function settings = updateEMLSFSettings(modelH, settings)
            sfDebugSettings = Sldv.utils.disableSFDebugSettings(modelH); 
            if ~isempty(sfDebugSettings)
                settings.SfDebugSettings = sfDebugSettings;
            end
            emlDebugSettings = Sldv.utils.resolveEmlDebugSettings(modelH);
            if ~isempty(emlDebugSettings)
                settings.EmlDebugSettings = Sldv.utils.settingsValueHandler(...
                        emlDebugSettings, '', true); 
                Sldv.utils.settingsValueHandler(emlDebugSettings, [], false);
            end
        end                
        
        function originalParams = changeMdlParams(modelH, paramNameValStruct)
            originalParams = [];
            paramNames = fieldnames(paramNameValStruct);
            for idx=1:length(paramNames)
                originalParams.(paramNames{idx}) = get_param(modelH,paramNames{idx});
                set_param(modelH,paramNames{idx},paramNameValStruct.(paramNames{idx}));
            end
        end
        
        function out = checkSldvFeature(featureName)
            out = license('test','Simulink_Design_Verifier') && ...
                    exist('slavteng','file')==3 && ...
                    logical(slavteng('feature',featureName));  
        end
    end
    
    methods (Access = private)
        function stopMatlabPool(obj)
            if obj.UseParComp
                poolsize = matlabpool('size');
                if poolsize~=0
                    matlabpool('close');
                end
                obj.UseParComp = false;
            end
        end        
    end
    
end

% LocalWords:  Hs Simstruct dvlogsout notrace slavtpackage
