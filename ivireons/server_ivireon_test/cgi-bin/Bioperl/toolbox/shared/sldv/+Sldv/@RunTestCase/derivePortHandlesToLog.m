function derivePortHandlesToLog(obj)

%   Copyright 2009 The MathWorks, Inc.
    if strcmp(obj.OutputFormat,'TimeSeries')
        outputPortInfo = obj.SldvData.AnalysisInformation.OutputPortInfo;        
        portHandles = Sldv.utils.getSubsystemIOPortHs([], obj.OutportBlkHs);        
        for idx=1:length(obj.OutportBlkHs)
            if iscell(outputPortInfo{idx})
                % Enable the signal logger only if the Outport is feeded by bus object.            
                lineH = get_param(portHandles(idx),'Line');        
                srcportH = get_param(lineH,'SrcPortHandle'); 
                if ~any(obj.PortHsToLog==srcportH)
                    % Same port might be feeding separate Outport blocks
                    obj.PortHsToLog(end+1) = srcportH;
                end
            end
        end
    end
end

