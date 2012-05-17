function derivePortHandlesToLog(obj)

%   Copyright 2009 The MathWorks, Inc.

    if obj.isNoModelRef
        % Top level model is generated from sldvmakeharness
        % and TestUnit is a subsystem
        convPortHandles = get_param(obj.ConvBlockH,'PortHandles');
        obj.PortHsToLog = convPortHandles.Outport;
    else
        modelH = obj.RefModelH;
        inBlkHs = Sldv.utils.getSubSystemPortBlks(modelH);
        obj.PortHsToLog = Sldv.utils.getSubsystemIOPortHs(inBlkHs, []);        
    end
end

% LocalWords:  sldvmakeharness
