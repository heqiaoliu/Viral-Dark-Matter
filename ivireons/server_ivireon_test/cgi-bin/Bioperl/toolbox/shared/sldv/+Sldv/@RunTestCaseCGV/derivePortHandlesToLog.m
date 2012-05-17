function derivePortHandlesToLog(obj)

%   Copyright 2009-2010 The MathWorks, Inc.
    obj.PortHsToLog = [];
    if strcmp(obj.OutputFormat,'TimeSeries')        
        portHandles = Sldv.utils.getSubsystemIOPortHs([], obj.OutportBlkHs);        
        for idx=1:length(obj.OutportBlkHs)                     
            lineH = get_param(portHandles(idx),'Line');        
            srcportH = get_param(lineH,'SrcPortHandle'); 
            if ~any(obj.PortHsToLog==srcportH)
                % Same port might be feeding separate Outport blocks
                obj.PortHsToLog(end+1) = srcportH;
            end            
        end
    end
end

