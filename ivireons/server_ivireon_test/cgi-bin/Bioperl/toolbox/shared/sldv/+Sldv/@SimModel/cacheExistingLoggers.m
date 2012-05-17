function cacheExistingLoggers(obj)

%   Copyright 2009 The MathWorks, Inc.

    logInfo = struct('DataLogging','',...
        'DataLoggingNameMode','',...
        'DataLoggingName','',...
        'DataLoggingDecimateData','',...
        'DataLoggingLimitDataPoints','');         
    numPorts = length(obj.PortHsToLog);
    existingLoggerConfig(1:numPorts) = logInfo;
    loggerFields = fields(logInfo);
    numFields = length(loggerFields);
    for idx=1:numPorts
        for jdx=1:numFields
            existingLoggerConfig(idx).(loggerFields{jdx}) = get_param(obj.PortHsToLog(idx),loggerFields{jdx});
        end        
    end
    obj.ExistingLoggerConfig = existingLoggerConfig;
end

