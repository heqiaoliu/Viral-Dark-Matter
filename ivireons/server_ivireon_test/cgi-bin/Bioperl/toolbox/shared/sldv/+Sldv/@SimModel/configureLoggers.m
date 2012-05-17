function configureLoggers(obj, modelHIncludingLoggers)    

%   Copyright 2009 The MathWorks, Inc.
    if nargin<2
        modelHIncludingLoggers = [];
    end
    
    if ~isempty(modelHIncludingLoggers)
        restoreDirtyness = true;
        origDirty = get_param(modelHIncludingLoggers,'Dirty');
    else
        restoreDirtyness = false;
    end

    numPorts = length(obj.PortHsToLog);    
    for idx=1:numPorts
        set_param(obj.PortHsToLog(idx),'DataLogging','on');
        set_param(obj.PortHsToLog(idx),'DataLoggingNameMode','Custom');
        set_param(obj.PortHsToLog(idx),'DataLoggingName',...
            sprintf('%s%d',obj.SignalLoggerPrefix, idx));  
        set_param(obj.PortHsToLog(idx),'DataLoggingDecimateData','off');
        set_param(obj.PortHsToLog(idx),'DataLoggingLimitDataPoints','off');
    end   
    
    if restoreDirtyness
        set_param(modelHIncludingLoggers,'Dirty',origDirty);       
    end
end

