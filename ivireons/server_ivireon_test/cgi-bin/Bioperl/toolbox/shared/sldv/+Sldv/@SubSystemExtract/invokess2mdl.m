function invokess2mdl(obj)

%   Copyright 2010 The MathWorks, Inc.

    obj.PhaseId = 1;
    obj.storeOriginalModelParams;
    obj.configureAutoSaveState;
    obj.turnOffAndStoreWarningStatus;
    
    obj.changeModelParams;
    
    try    
        [modelH, portInfo, error_occ, ss2mdlExc] = rtwprivate('ss2mdl',obj.SubSystemH,...
            'SS2mdlForSLDV',true);
    catch Mex 
        error_occ = 1;
        ss2mdlExc = Mex;
    end          
    
    obj.Status = ~(logical(error_occ));
    
    if ~obj.Status
        if ~isempty(ss2mdlExc)
            newExc = MException([obj.MsgIdPref, 'SS2MDL'],'Extraction Failed');        
            newExc = newExc.addCause(ss2mdlExc);        
            obj.Ss2mdlExc = newExc;
        end
    else
        % ss2mdl compiled the model. Detect referenced Simulink.Signal
        % objects from the subsystem
        obj.detectReferencedSimulinkSignalVars;
        obj.ModelH = modelH;
        obj.PortInfo = portInfo;
    end
    
    obj.restoreWarningStatus;
    obj.restoreAutoSaveState;
    obj.restoreOriginalModelParams;
    obj.PhaseId = 0;
end

% LocalWords:  SLDV
