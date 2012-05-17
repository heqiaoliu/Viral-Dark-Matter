function [inPortInfo, outPortInfo, modelCompileInfo] = ...
    getModelCompiledIOInfo(model, parameterSettings)   

%   Copyright 2008-2010 The MathWorks, Inc.

    modelCompileInfo = struct('sampleTime',[],...
        'modelSampleDetails',[]);        

    if ischar(model)
        try
            modelH = get_param(model,'Handle');
        catch myException %#ok<NASGU>
            modelH = [];
        end
    else
        modelH = model;
    end

    if exist('sldvprivate', 'file')==2
        try
            testcomp = Sldv.Token.get.getTestComponent;
        catch myException %#ok<NASGU>
            testcomp = [];
        end
    else
        testcomp = [];
    end
    
    if ~isempty(testcomp) && ishandle(testcomp) && ~isempty(testcomp.mdlFlatIOInfo)
        inPortInfo = testcomp.mdlFlatIOInfo.Inport;
        outPortInfo = testcomp.mdlFlatIOInfo.Outport;
        modelCompileInfo.sampleTime = testcomp.mdlFundamentalTs;
        return;
    end    
    
    featureVal = feature('EngineInterface');
    feature('EngineInterface', 1001);
    
    old_autosave_state=get_param(0,'AutoSaveOptions');
    new_autosave_state=old_autosave_state;
    new_autosave_state.SaveOnModelUpdate=0;
    new_autosave_state.SaveBackupOnVersionUpgrade=0;
    set_param(0,'AutoSaveOptions',new_autosave_state);
    
    origDirtyFlag = get_param(modelH, 'Dirty');         
    origConfigSet = getActiveConfigSet(modelH);
       
    Sldv.utils.removeConfigSetRef(modelH);
    
    parameterSettings = ...
        Sldv.utils.checkParametersForCompile(modelH, parameterSettings);            
    
    model = get_param(modelH,'Name'); 
    Sldv.DataUtils.set_cache_compiled_bus(modelH,'on');    
    mException = [];
    strictBusErros = false;
    try                 
        % We want full compile because we want the state information 
        evalc('feval(model,[],[],[],''compileForSizes'');');             
    catch Mex
        mException = Mex;        
    end
    
    if ~isempty(mException)
        if isfield(parameterSettings, 'StrictBusMsg') && ...
                sldvshareprivate('util_is_related_exc', ...
                mException, Sldv.utils.errorIdsForStrictBusMsg)
            % compile one more time
            disp('### Model failed to compile with strict bus check on');
            disp('### Turning strict bus check off');                 
            strictBusErros = true;
            set_param(modelH, 'StrictBusMsg', parameterSettings.('StrictBusMsg').originalvalue);            
            Sldv.DataUtils.set_cache_compiled_bus(modelH,'off');    
            mException = [];       
            try                         
                evalc('feval(model,[],[],[],''compileForSizes'');');        
            catch Mex    
                mException = Mex;
            end            
        end
    end
    
    if ~isempty(mException)
        % it is still causing errors
        if isfield(parameterSettings, 'MultiTaskRateTransMsg') && ...
                sldvshareprivate('util_is_related_exc', mException, 'Simulink:SampleTime:IllegalIPortRateTrans')
            finalExc = MException('SLDV:SldvDataUtils:GetModelCompiledIOInfo:IllegalModelRefHarness',...
                'Unable to generate a harness model that includes %s in a Model block.',model);
        else
            finalExc = MException('SLDV:SldvDataUtils:GetModelCompiledIOInfo:ModelDoesNotCompile',...
                'The model %s does not compile without errors',model);
        end        
        finalExc = finalExc.addCause(mException);        
    else
        finalExc = [];
    end
    
    if isempty(finalExc)
        mdlFlatIOInfo = sldvshareprivate('mdl_generate_inportinfo',modelH, testcomp, false, strictBusErros);
        inPortInfo = mdlFlatIOInfo.Inport;
        outPortInfo = mdlFlatIOInfo.Outport;
        mdlObj = get_param(modelH,'Object');
        modelCompileInfo.sampleTime = mdlObj.getSampleTimeValues();
        modelCompileInfo.modelSampleDetails = Simulink.BlockDiagram.getSampleTimes(modelH);                        
        try
            evalc('feval(model,[],[],[],''term'');');                
        catch mException
            finalExc = MException('SLDV:SldvDataUtils:GetModelCompiledIOInfo:ModelDoesNotTerminateCompile',...
                    'The model %s does not terminate compilation without errors',model);
            finalExc = finalExc.addCause(mException);            
        end    
    end
    
    % Reverse back the model parameter
    Sldv.utils.restoreConfigSet(modelH, origConfigSet);  
    set_param(modelH, 'Dirty', origDirtyFlag);
    
    set_param(0,'AutoSaveOptions',old_autosave_state);
    
    feature('EngineInterface', featureVal);
    
    if ~isempty(finalExc)
        throw(finalExc);
    end            
end