function handleGetLargeDataError(obj, err)
; %#ok Undocumented
% Function that appropriately handles the error that occurred during the 
% reading of a large data set from the job manager computer.

% Copyright 2007 The MathWorks, Inc.
    
% Retrieve the last error. Java exceptions will have been converted to a error struct.
err = distcomp.handleJavaException(obj, err);
    
% Throw an error only if on a MATLAB worker. MATLAB clients will warn, not error.
if system_dependent('isdmlworker')
    throwAsCaller(err);
else
    % Currently, we only want to warn about the TooMuchData error and UnavailableEphemeralPorts.
    if isa(obj, 'distcomp.job')
        if strcmp(err.identifier, 'distcomp:job:TooMuchData')
            warning(err.identifier, 'Unable to get data :\n%s', err.message);
        end
        if strcmp(err.identifier, 'distcomp:jobmanager:UnavailableEphemeralPorts')
            warning(err.identifier, 'Unable to get data :\n%s', err.message);
        end
    elseif isa(obj, 'distcomp.task')
        if strcmp(err.identifier, 'distcomp:task:TooMuchData')
            warning(err.identifier, 'Unable to get data :\n%s', err.message);
        end
        if strcmp(err.identifier, 'distcomp:jobmanager:UnavailableEphemeralPorts')
            warning(err.identifier, 'Unable to get data :\n%s', err.message);
        end
    end
end
