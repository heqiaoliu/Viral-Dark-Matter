function insertLineNames(obj)

%   Copyright 2010 The MathWorks, Inc.

    if strcmp(obj.OutputFormat,'TimeSeries')        
        portHandles = Sldv.utils.getSubsystemIOPortHs([], obj.OutportBlkHs);        
        for idx=1:length(obj.OutportBlkHs)                            
            lineH = get_param(portHandles(idx),'Line');                                    
            if isempty(get_param(lineH,'Name'))
                set_param(lineH,'Name',sprintf('%s%d',obj.LineNamePrefix, idx));
            end
        end
    end
end

