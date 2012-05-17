function varargout = simTestCases(obj, model, sldvData, varargin)

    %   Copyright 2009-2010 The MathWorks, Inc.
    obj.deriveModelParam(model);
    obj.deriveSldvDataParam(sldvData);
             
    obj.OrigModelH = obj.ModelH;
    obj.OrigModel = obj.Model;
    
    runtestOpts = obj.checkRuntestOpts(varargin{1});       
                       
    obj.deriveNonCGVParams(runtestOpts);       
    
    obj.deriveCoverageParam(runtestOpts);
    
    obj.checkPARFORoption;
                    
    obj.checkSldvData;
    
    obj.createTmpModelForParFor;    
    
    obj.FunTs = ...
        sldvshareprivate('mdl_derive_sampletime_for_sldvdata',...
        obj.SldvData.AnalysisInformation.SampleTimes);
    
    [obj.InportBlkHs, obj.OutportBlkHs] = ...
        Sldv.utils.getSubSystemPortBlks(obj.ModelH);
    
    try                    
        obj.configureAutoSaveState;
        
        % Store original model configurations
        obj.storeOriginalModelParams;        
        obj.derivePortHandlesToLog;
        obj.cacheExistingLoggers;              
        
        %Start Simulation
        obj.runTests;                
    catch Mex
        internalError = strmatch(obj.MsgIdPref,Mex.identifier);
        if isempty(internalError) || internalError~=1
            % Reset session data only for unknown errors. Otherwise session
            % is already cleared.
            obj.resetSessionData;       
        end     
        rethrow(Mex);
    end
        
    varargout{1} = obj.OutData;
    varargout{2} = obj.CvData;
    obj.resetSessionData;
end

% LocalWords:  EMLSF sampletime sldv sldvdata CGV
