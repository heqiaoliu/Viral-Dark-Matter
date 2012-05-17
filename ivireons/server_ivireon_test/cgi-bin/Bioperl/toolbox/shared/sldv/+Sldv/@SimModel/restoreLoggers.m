function restoreLoggers(obj, modelHIncludingLoggers)

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

    if ~isempty(obj.ExistingLoggerConfig)
        numPorts = length(obj.PortHsToLog);    
        loggerFields = fields(obj.ExistingLoggerConfig);
        numFields = length(loggerFields);
        for idx=1:numPorts
            for jdx=1:numFields                
                set_param(obj.PortHsToLog(idx),loggerFields{jdx},...
                    obj.ExistingLoggerConfig(idx).(loggerFields{jdx}));
            end               
        end
        obj.ExistingLoggerConfig = [];
    end
    
     if restoreDirtyness
        set_param(modelHIncludingLoggers,'Dirty',origDirty);       
    end
end