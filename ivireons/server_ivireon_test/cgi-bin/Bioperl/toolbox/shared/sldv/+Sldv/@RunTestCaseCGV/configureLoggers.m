function configureLoggers(obj, modelHIncludingLoggers)     %#ok<INUSD>

%   Copyright 2009-2010 The MathWorks, Inc.

    numPorts = length(obj.PortHsToLog);    
    for idx=1:numPorts
        % Existing loggers will be left as is
        if strcmp(get_param(obj.PortHsToLog(idx),'DataLogging'),'off')            
            set_param(obj.PortHsToLog(idx),'DataLogging','on');
            set_param(obj.PortHsToLog(idx),'DataLoggingNameMode','Custom');
            set_param(obj.PortHsToLog(idx),'DataLoggingName',...
                sprintf('%s%d',obj.SignalLoggerPrefix, idx));  
            set_param(obj.PortHsToLog(idx),'DataLoggingDecimateData','off');
            set_param(obj.PortHsToLog(idx),'DataLoggingLimitDataPoints','off');
        end
    end           
end

