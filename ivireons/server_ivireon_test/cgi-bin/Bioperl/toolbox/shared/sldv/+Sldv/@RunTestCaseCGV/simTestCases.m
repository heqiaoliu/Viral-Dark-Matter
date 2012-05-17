function varargout = simTestCases(obj, model, sldvData, varargin)

    %   Copyright 2009-2010 The MathWorks, Inc.
    obj.deriveModelParam(model);
    obj.deriveSldvDataParam(sldvData);             
    
    runtestOpts = obj.checkRuntestOpts(varargin{1},'cgv');              
        
    obj.deriveCGVParams(runtestOpts);
   
    obj.deriveNonCGVParams(runtestOpts);                               
    
    useParComp = Sldv.SimModel.checkSldvFeature('UseParforForSim');    
    if useParComp                    
        msgId = 'NoParforForCGV';                       
        msg = xlate(['Parallel computation cannot be used  ', ...                           
                   'Code Generation Verification (CGV) API. ']);                       
        obj.handleMsg('error', msgId, msg);           
    end                 
        
    try         
        obj.checkModelInOutInterface;        
        if obj.ModelInOutInterfaceAcceptable                        
            obj.checkCGVConfig;
            if obj.ModelConfiguredCorrectlyForCGV
                obj.getSimStructForRunTest;                                    
            else           
                % User allowed copying the model
                obj.createCGVModel;  
            end            
        else        
            % User allowed copying the model
            obj.createCGVModel;                                    
        end               
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
                    
    varargout{1} = obj.CGVObj;    
    obj.resetSessionData;
end

% LocalWords:  EMLSF sampletime sldv sldvdata CGV cgv
