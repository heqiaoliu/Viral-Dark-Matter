function createCGVModel(obj)                         
    % Create the copy model

%   Copyright 2010 The MathWorks, Inc.

    obj.createCopyCGVModel;                             

    [obj.InportBlkHs, obj.OutportBlkHs] = ...
        Sldv.utils.getSubSystemPortBlks(obj.CGVModelH);
    % There is a copy model. Re-derive the port handles to log
    obj.derivePortHandlesToLog;

    % Do not use referenced configuration sets in models that you are 
    % modifying using cgv.Config
    Sldv.utils.removeConfigSetRef(obj.CGVModelH);

    if ~obj.ModelInOutInterfaceAcceptable
        % Give names to the lines that doesn't have a name
        obj.insertLineNames;

        % Set BusOutputAsStruct to 'on' Outports if Bus object is specified
        obj.updateOutports;

        % Configure loggers      
        obj.configureLoggers;

        % Change the interpolations to be able to support feeding fixed
        % point input
        obj.changeInterpForInports;
    end

    % Make sure that model is not dirty before invoking cgv
    % configuration changes
    save_system(obj.CGVModelH);

    % Configure the model for CGV. Model will be changed the saved. 
    cgvCfg = obj.createCGVConfigObj('on');
    cgvCfg.configModel();       
    
    obj.getSimStructForRunTest;  
end

% LocalWords:  cgv sampletime sldvdata