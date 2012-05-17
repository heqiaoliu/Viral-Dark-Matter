function val = pGetState(job, val)
; %#ok Undocumented
%pGetState A short description of the function
%
%  VAL = pGetState(JOB, VAL)

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.8.6 $    $Date: 2008/06/24 17:01:19 $ 

persistent Values Strings
if isempty(Values)
    types = findtype('distcomp.jobexecutionstate');
    Values = types.Values;
    Strings = types.Strings;
end

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        val = Strings{double(proxyJob.getState(job.UUID)) == Values}; % pending, queued, running, or finished
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
