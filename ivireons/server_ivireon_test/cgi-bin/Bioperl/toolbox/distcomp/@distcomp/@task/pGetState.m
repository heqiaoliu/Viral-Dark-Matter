function val = pGetState(task, val)
; %#ok Undocumented
%pGetState A short description of the function
%
%  VAL = pGetState(TASK, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

persistent Values Strings
if isempty(Values)
    types = findtype('distcomp.taskexecutionstate');
    Values = types.Values;
    Strings = types.Strings;
end

proxyTask = task.ProxyObject;
try
    val = Strings{proxyTask.getState(task.UUID) == Values}; % pending, running, or finished
catch err
    [isJavaError, exceptionType, causes] = isJavaException(err);
    if isJavaError
        % Find the original cause of the exception
        if isempty(causes)
            cause = exceptionType;
        else
            cause = causes{end};
        end
        switch cause
            case 'com.mathworks.toolbox.distcomp.storage.WorkUnitNotFoundException'
                val = Strings{-1 == Values}; % destroyed
            case 'java.rmi.RemoteException'
                val = Strings{-2 == Values}; % unavailable
            case 'java.rmi.NoSuchObjectException'
                val = Strings{-2 == Values}; % unavaialble
        end
    end
end
end

