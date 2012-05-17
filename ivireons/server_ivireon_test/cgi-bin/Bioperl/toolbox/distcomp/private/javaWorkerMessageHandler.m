function aHandler = javaWorkerMessageHandler( )
; %#ok Undocumented
% Create a message handler.
%
% The message handler accepts a level number and a message, and routes them
% to the worker logger.

% Copyright 2006-2010 The MathWorks, Inc.

aHandler = @nMessageHandler;
workerLogger = com.mathworks.toolbox.distcomp.worker.PackageInfo.LOGGER;
    function nMessageHandler(msg, levelNum)
        % Do nothing if log level is invalid
        if nargin ~= 2
            return
        end
        lvl = com.mathworks.toolbox.distcomp.logging.DistcompLevel.getLevelFromValue(levelNum);
        workerLogger.log(lvl, msg);
    end

end
