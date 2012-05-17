function err = handleJavaException(obj, caughtException)
; %#ok Undocumented
    % function to return an appropriate error message for a variety of java
    % exceptions that the proxy layer could throw.  This function does
    % nothing if the exception is not one of the ones it recognizes.
    % objectType should be either 'jobmanager' or 'worker' as appropriate.

% Copyright 2004-2010 The MathWorks, Inc.

nExpectArgs = 2;
assert(nargin == nExpectArgs, ...
       'function was given %d args instead of %d.', nargin, nExpectArgs);

    [isJavaError, exceptionType] = isJavaException(caughtException);
    
    if ~isJavaError
        err = caughtException;
        return;
    end
    
    errMessage = caughtException.message;
    
    % Try and unravel a java.rmi.ServerException which will wrap the original exception
    if strcmp(exceptionType, 'java.rmi.ServerException')
        [hasCause, causeExceptionType, causeMessage] = dct_getJavaExceptionCause(errMessage);
        if hasCause
            exceptionType = causeExceptionType;
            errMessage = causeMessage;
        end
    end

    % Try and unravel a DistcompException which will wrap the original exception
    if strcmp(exceptionType,...
            'com.mathworks.toolbox.distcomp.distcompobjects.DistcompException')
        [hasCause, causeExceptionType] = dct_getJavaExceptionCause(errMessage);
        if hasCause
            exceptionType = causeExceptionType;
        end
    end
    
    msgstruct = iFindErrorMessage(obj, exceptionType);
    if isempty(msgstruct.identifier)
        msgstruct.identifier = caughtException.identifier;
        msgstruct.message = caughtException.message;
    end
    

    err = MException(msgstruct.identifier, msgstruct.message);
    if isa(caughtException, 'MException')
        err.addCause(caughtException);
    end

end

function msgstruct = iFindErrorMessage(obj, exceptionType)
    msgstruct = struct('identifier', '', 'message', '');
    % Some error messages need to tell the user which JVM this is (either worker or local) so
    % define a string based on isdmlworker
    if system_dependent('isdmlworker')
        jvmType = 'worker';
    else
        jvmType = 'local';
    end

    if isa(obj, 'distcomp.jobmanager')
        switch exceptionType
            case 'com.mathworks.toolbox.distcomp.storage.JobNotFoundException'
                msgstruct.identifier = 'distcomp:job:NotFound';
                msgstruct.message = 'Job not found in job manager';
            case 'com.mathworks.toolbox.distcomp.storage.WorkUnitNotFoundException'
                msgstruct.identifier = 'distcomp:job:NotFound';
                msgstruct.message = 'Task or Job not found in job manager';                
            case 'com.mathworks.toolbox.distcomp.workunit.JobStateException'
                msgstruct.identifier = 'distcomp:job:InvalidState';
                msgstruct.message = 'Invalid job state for operation';
            case 'com.mathworks.toolbox.distcomp.workunit.WorkUnitStateException'
                msgstruct.identifier = 'distcomp:job:InvalidState';
                msgstruct.message = 'Invalid job state for operation';
            case 'com.mathworks.toolbox.distcomp.jobmanager.SavePausedStateException'
               msgstruct.identifier = 'distcomp:jobmanager:StateNotSaved';
               msgstruct.message = sprintf(['The paused state of the job manager could not be saved to the checkpoint directory.\n' ...
                                            'Refer to the mdce-service.log file on the job manager computer for further details.\n' ...
                                            'Restarting the job manager will cause jobs in the queue to begin running.']);
            case 'com.mathworks.toolbox.distcomp.jobmanager.SaveRunningStateException'
               msgstruct.identifier = 'distcomp:jobmanager:StateNotSaved';
               msgstruct.message = sprintf(['The running state of the job manager could not be saved to the checkpoint directory.\n' ...
                                            'Refer to the mdce-service.log file on the job manager computer for further details.\n' ...
                                            'Restarting the job manager will cause the queue to be paused again.']);
            case 'com.mathworks.toolbox.distcomp.util.PortUnavailableException'
               msgstruct.identifier = 'distcomp:jobmanager:PortUnavailable';
               msgstruct.message = 'Port unavailable.  Please use the pctconfig function if on client or mdce_def file if on worker to select a different port.';
            case 'java.net.ConnectException' 
               msgstruct.identifier = 'distcomp:jobmanager:Unavailable'; 
               msgstruct.message = 'Job manager could not be reached'; 
            case 'java.rmi.ConnectException' 
               msgstruct.identifier = 'distcomp:jobmanager:Unavailable'; 
               msgstruct.message = 'Job manager could not be reached'; 
            case 'java.rmi.RemoteException'
               msgstruct.identifier = 'distcomp:jobmanager:Unavailable';
               msgstruct.message = 'Job manager could not be reached';
            case 'java.rmi.NoSuchObjectException'
               msgstruct.identifier = 'distcomp:jobmanager:Unavailable';
               msgstruct.message = 'Job manager could not be reached';
            case 'com.mathworks.toolbox.distcomp.distcompobjects.DistcompProxy$SerializeProxyException'
               msgstruct.identifier = 'distcomp:jobmanager:Unavailable';
               msgstruct.message = sprintf(['Job manager was contactable but returned invalid data. This jobmanager should be restarted\n' ...
                                            'using the -clean flag to clear out invalid stored data. Provided it is restarted with the same\n' ...
                                            'name and baseport the existing workers will reattach and build a cluster']);
            case 'com.mathworks.toolbox.distcomp.auth.credentials.consumer.NoCredentialsEnteredException'
               msgstruct.identifier = 'distcomp:auth:AbortByUser';
               msgstruct.message = 'Operation aborted by user';
            case 'com.mathworks.toolbox.distcomp.auth.NoAuthorisedUserFoundException'
               msgstruct.identifier = 'distcomp:auth:AuthFailed';
               msgstruct.message = 'Authentication failed';
            case 'com.mathworks.toolbox.distcomp.auth.InvalidPasswordException'
               msgstruct.identifier = 'distcomp:auth:InvalidPassword';
               msgstruct.message = sprintf(...
                                  ['The password you entered does not match the password previously entered for this user on this job manager.\n' ...
                                   'To correct this, you can update the Username property of the job manager, or use changePassword to change the\n', ...
                                   'the password to the correct one.\n',...
                                   'For information on this method, type help distcomp.jobmanager/changePassword\n', ...
                                   'If you have forgotten your password please contact your Administrator and ask them to reset your password.']);
            case 'com.mathworks.toolbox.distcomp.auth.UnauthorisedUserException'
               msgstruct.identifier = 'distcomp:auth:UnauthorizedUser';
               msgstruct.message = 'The user is not authorized.';       
            case 'com.mathworks.toolbox.distcomp.auth.PasswordRetrievalException'
               msgstruct.identifier = 'distcomp:auth:NoPassword';
               msgstruct.message = 'There is no password stored for this user.';       
            case 'com.mathworks.toolbox.distcomp.auth.UnknownUserException'
               msgstruct.identifier = 'distcomp:auth:UnknownUser';
               msgstruct.message = 'This user does not exist or there is no password stored.';
            case 'com.mathworks.toolbox.distcomp.auth.UserCreationException'
               msgstruct.identifier = 'distcomp:auth:UserCreation';
               msgstruct.message = sprintf(['The user could not be created. Regular users may only be created if they are listed in\n' ...
                                            'ALLOWED_USERS in the mdce_def script.  The admin user should have been created during\n' ...
                                            'job manager startup. If not, stopping and restarting the job manager will attempt to add\n' ...
                                            'the admin user properly.']);
        end
    elseif isa(obj, 'distcomp.worker')
        switch exceptionType
            case 'java.net.ConnectException' 
                msgstruct.identifier = 'distcomp:worker:Unavailable'; 
                msgstruct.message = 'Worker could not be reached'; 
            case 'java.rmi.ConnectException' 
                msgstruct.identifier = 'distcomp:worker:Unavailable'; 
                msgstruct.message = 'Worker could not be reached'; 
            case 'java.rmi.RemoteException'
                msgstruct.identifier = 'distcomp:worker:Unavailable';
                msgstruct.message = 'Worker could not be reached';
            case 'java.rmi.NoSuchObjectException'
                msgstruct.identifier = 'distcomp:worker:Unavailable';
                msgstruct.message = 'Worker could not be reached';
        end
    elseif isa(obj, 'distcomp.task')
        switch exceptionType
            case 'com.mathworks.toolbox.distcomp.storage.TaskNotFoundException'
                msgstruct.identifier = 'distcomp:task:NotFound';
                msgstruct.message = 'Task not found in job manager';
            case 'com.mathworks.toolbox.distcomp.storage.JobNotFoundException'
                msgstruct.identifier = 'distcomp:job:NotFound';
                msgstruct.message = 'Job not found in job manager';
            case 'com.mathworks.toolbox.distcomp.storage.WorkUnitNotFoundException'
                msgstruct.identifier = 'distcomp:task:NotFound';
                msgstruct.message = 'Task or Job not found in job manager';                
            case 'com.mathworks.toolbox.distcomp.workunit.TaskStateException'
                msgstruct.identifier = 'distcomp:task:InvalidState';
                msgstruct.message = 'Invalid task state for task operation';                
            case 'com.mathworks.toolbox.distcomp.workunit.JobStateException'
                msgstruct.identifier = 'distcomp:job:InvalidState';
                msgstruct.message = 'Invalid job state for task operation';
            case 'com.mathworks.toolbox.distcomp.workunit.WorkUnitStateException'
                msgstruct.identifier = 'distcomp:task:InvalidState';
                msgstruct.message = 'Invalid task state for task operation';
            case 'com.mathworks.toolbox.distcomp.workunit.TaskDispatchInProgressException'
                msgstruct.identifier = 'distcomp:task:InvalidState';
                msgstruct.message = sprintf(['The task cannot be modified because the job manager\n' ...
                                             'is currently trying to send the task to a worker.']);
            case 'com.mathworks.toolbox.distcomp.util.MaxDataLimitExceededException'
                msgstruct.identifier = 'distcomp:task:TooMuchData';
                msgstruct.message = sprintf(['Not enough jobmanager Java memory to allocate data.  Refer to the \n' ...
                                            'troubleshooting section of the documentation for information on\n' ...
                                            'how to increase the size of the local Java memory and the memory\n' ...
                                            'on the job manager and the workers.']);
            case 'com.mathworks.toolbox.distcomp.util.CallerDataStoreExceededException'
                storeSize = iGetDataStoreSizeInMB();
                msgstruct.identifier = 'distcomp:task:TooMuchData';
                msgstruct.message = sprintf(['Not enough %s memory to transfer data.  The maximum amount of data\n' ...
                                            'that can be transferred in one call is %d MB. This can be changed by\n' ...
                                            'setting the MaxDirectMemorySize property of the JVM in this MATLAB process.\n' ...                                            
                                            'See the documentation on memory transfer limits for more details.'], jvmType, storeSize);
            case 'com.mathworks.toolbox.distcomp.distcompobjects.DataTransferException'
                msgstruct.identifier = 'distcomp:task:TooMuchData';
                msgstruct.message = sprintf(['Not enough %s Java memory to allocate data.  Refer to the \n' ...
                                            'troubleshooting section of the documentation for information on\n' ...
                                            'how to increase the size of the local Java memory and the memory\n' ...
                                            'on the job manager and the workers.'], jvmType);
            case 'java.lang.OutOfMemoryError'
                msgstruct.identifier = 'distcomp:task:TooMuchData';
                msgstruct.message = sprintf(['Not enough %s Java memory to allocate data.  Refer to the \n' ...
                                            'troubleshooting section of the documentation for information on\n' ...
                                            'how to increase the size of the local Java memory and the memory\n' ...
                                            'on the job manager and the workers.'], jvmType);
            case 'com.mathworks.toolbox.distcomp.util.DataStoreException'
               msgstruct.identifier = 'distcomp:jobmanager:CommFromJobManager';
               msgstruct.message = sprintf(['The job manager could not contact this MATLAB session on hostname %s and port %d.\n' ...
                                            'Using the findResource command to find the job manager may provide a more detailed error message.'],  ...
                                            char(java.lang.System.getProperty('java.rmi.server.hostname')), iGetDataStoreExportPort());
            case 'com.mathworks.toolbox.distcomp.util.PortUnavailableException'
                msgstruct.identifier = 'distcomp:task:PortUnavailable';
                msgstruct.message = 'Port unavailable.  Please use the pctconfig function if on client or mdce_def file if on worker to select a different port.';
            case 'java.rmi.ServerException'
                msgstruct.identifier = 'distcomp:job:ClientUnreachable';
                msgstruct.message = 'The job manager was unable to contact the client to receive information';
            case 'java.net.ConnectException' 
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable'; 
                msgstruct.message = 'Job manager could not be reached'; 
            case 'java.rmi.ConnectException' 
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable'; 
                msgstruct.message = 'Job manager could not be reached'; 
            case 'java.rmi.RemoteException'
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable';
                msgstruct.message = 'Job manager could not be reached';
            case 'java.rmi.NoSuchObjectException'
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable';
                msgstruct.message = 'Job manager could not be reached';
            case 'com.mathworks.toolbox.distcomp.util.UnavailableEphemeralPortsException'
                msgstruct.identifier = 'distcomp:jobmanager:UnavailableEphemeralPorts';
                msgstruct.message = sprintf(['The job manager computer has exceeded its allocation of ephemeral TCP ports.\n'...
                                    'Refer to the troubleshooting section of the MDCE documentation for information on\n', ...
                                    'how to increase the allocation of ephemeral TCP ports on the job manager computer.']);
            case 'com.mathworks.toolbox.distcomp.auth.credentials.consumer.NoCredentialsEnteredException'
               msgstruct.identifier = 'distcomp:auth:AbortByUser';
               msgstruct.message = 'Operation aborted by user';
            case 'com.mathworks.toolbox.distcomp.auth.NoAuthorisedUserFoundException'
               msgstruct.identifier = 'distcomp:auth:AuthFailed';
               msgstruct.message = 'Authentication failed';
            case 'com.mathworks.toolbox.distcomp.auth.InvalidPasswordException'
               msgstruct.identifier = 'distcomp:auth:InvalidPassword';
               msgstruct.message = 'The password is invalid.';
            case 'com.mathworks.toolbox.distcomp.auth.UnauthorisedUserException'
               msgstruct.identifier = 'distcomp:auth:UnauthorizedUser';
               msgstruct.message = 'The user is not authorized.';       
            case 'com.mathworks.toolbox.distcomp.auth.PasswordRetrievalException'
               msgstruct.identifier = 'distcomp:auth:NoPassword';
               msgstruct.message = 'There is no password stored for this user.';       
            case 'com.mathworks.toolbox.distcomp.auth.UnknownUserException'
               msgstruct.identifier = 'distcomp:auth:UnknownUser';
               msgstruct.message = 'This user does not exist or there is no password stored.';
        end           
    elseif isa(obj, 'distcomp.job')
        switch exceptionType
            case 'com.mathworks.toolbox.distcomp.storage.TaskNotFoundException'
                msgstruct.identifier = 'distcomp:task:NotFound';
                msgstruct.message = 'Task not found in job manager'; 
            case 'com.mathworks.toolbox.distcomp.storage.JobNotFoundException'
                msgstruct.identifier = 'distcomp:job:NotFound';
                msgstruct.message = 'Job not found in job manager';
            case 'com.mathworks.toolbox.distcomp.storage.WorkUnitNotFoundException'
                msgstruct.identifier = 'distcomp:job:NotFound';
                msgstruct.message = 'Task or Job not found in job manager';                
            case 'com.mathworks.toolbox.distcomp.workunit.TaskStateException'
                msgstruct.identifier = 'distcomp:task:InvalidState';
                msgstruct.message = 'Invalid task state for task operation';                
            case 'com.mathworks.toolbox.distcomp.workunit.JobStateException'
                msgstruct.identifier = 'distcomp:job:InvalidState';
                msgstruct.message = 'Invalid job state for task operation';
            case 'com.mathworks.toolbox.distcomp.workunit.WorkUnitStateException'
                msgstruct.identifier = 'distcomp:job:InvalidState';
                msgstruct.message = 'Invalid job state for job operation';                 
            case 'com.mathworks.toolbox.distcomp.util.MaxDataLimitExceededException'
                msgstruct.identifier = 'distcomp:job:TooMuchData';
                msgstruct.message = sprintf(['Not enough jobmanager Java memory to allocate data.  Refer to the \n' ...
                                            'troubleshooting section of the documentation for information on\n' ...
                                            'how to increase the size of the local Java memory and the memory\n' ...
                                            'on the job manager and the workers.']);
            case 'com.mathworks.toolbox.distcomp.util.CallerDataStoreExceededException'
                storeSize = iGetDataStoreSizeInMB();
                msgstruct.identifier = 'distcomp:job:TooMuchData';
                msgstruct.message = sprintf(['Not enough %s memory to transfer data.  The maximum amount of data\n' ...
                                            'that can be transferred in one call is %d MB. This can be changed by\n' ...
                                            'setting the MaxDirectMemorySize property of the JVM in this MATLAB process.\n' ...                                            
                                            'See the documentation on memory transfer limits for more details.'], jvmType, storeSize);
            case 'com.mathworks.toolbox.distcomp.distcompobjects.DataTransferException'
                msgstruct.identifier = 'distcomp:job:TooMuchData';
                msgstruct.message = sprintf(['Not enough %s Java memory to allocate data.  Refer to the \n' ...
                                            'troubleshooting section of the documentation for information on\n' ...
                                            'how to increase the size of the local Java memory and the memory\n' ...
                                            'on the job manager and the workers.'], jvmType);
            case 'java.lang.OutOfMemoryError'
                msgstruct.identifier = 'distcomp:job:TooMuchData';
                msgstruct.message = sprintf(['Not enough %s Java memory to allocate data.  Refer to the \n' ...
                                            'troubleshooting section of the documentation for information on\n' ...
                                            'how to increase the size of the local Java memory and the memory\n' ...
                                            'on the job manager and the workers.'], jvmType);
            case 'com.mathworks.toolbox.distcomp.util.DataStoreException'
               msgstruct.identifier = 'distcomp:jobmanager:CommFromJobManager';
               msgstruct.message = sprintf(['The job manager could not contact this MATLAB session on hostname %s and port %d.\n' ...
                                            'Using the findResource command to find the job manager may provide a more detailed error message.'],  ...
                                            char(java.lang.System.getProperty('java.rmi.server.hostname')), iGetDataStoreExportPort());
            case 'com.mathworks.toolbox.distcomp.util.PortUnavailableException'
                msgstruct.identifier = 'distcomp:job:PortUnavailable';
                msgstruct.message = 'Port unavailable.  Please use the pctconfig function if on client or mdce_def file if on worker to select a different port.';
            case 'java.rmi.ServerException'
                msgstruct.identifier = 'distcomp:job:ClientUnreachable';
                msgstruct.message = 'The job manager was unable to contact the client to receive information';
            case 'java.net.ConnectException' 
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable'; 
                msgstruct.message = 'Job manager could not be reached'; 
            case 'java.rmi.ConnectException' 
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable'; 
                msgstruct.message = 'Job manager could not be reached'; 
            case 'java.rmi.RemoteException'
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable';
                msgstruct.message = 'Job manager could not be reached';
            case 'java.rmi.NoSuchObjectException'
                msgstruct.identifier = 'distcomp:jobmanager:Unavailable';
                msgstruct.message = 'Job manager could not be reached';
            % ParallelJob exceptions here - subclass of job
            case 'com.mathworks.toolbox.distcomp.pml.ParallelJobSingleTaskException'
                msgstruct.identifier = 'distcomp:job:InvalidJobState';
                msgstruct.message = 'When setting up a parallel job, only 1 task is allowed';
            case 'com.mathworks.toolbox.distcomp.util.UnavailableEphemeralPortsException'
                msgstruct.identifier = 'distcomp:jobmanager:UnavailableEphemeralPorts';
                msgstruct.message = sprintf(['The job manager computer has exceeded its allocation of ephemeral TCP ports.\n'...
                                    'Refer to the troubleshooting section of the MDCE documentation for information on\n', ...
                                    'how to increase the allocation of ephemeral TCP ports on the job manager computer.']);
            case 'com.mathworks.toolbox.distcomp.auth.credentials.consumer.NoCredentialsEnteredException'
               msgstruct.identifier = 'distcomp:auth:AbortByUser';
               msgstruct.message = 'Operation aborted by user';
            case 'com.mathworks.toolbox.distcomp.auth.NoAuthorisedUserFoundException'
               msgstruct.identifier = 'distcomp:auth:AuthFailed';
               msgstruct.message = 'Authentication failed';
            case 'com.mathworks.toolbox.distcomp.auth.InvalidPasswordException'
               msgstruct.identifier = 'distcomp:auth:InvalidPassword';
               msgstruct.message = 'The password is invalid.';
            case 'com.mathworks.toolbox.distcomp.auth.UnauthorisedUserException'
               msgstruct.identifier = 'distcomp:auth:UnauthorizedUser';
               msgstruct.message = 'The user is not authorized.';       
            case 'com.mathworks.toolbox.distcomp.auth.PasswordRetrievalException'
               msgstruct.identifier = 'distcomp:auth:NoPassword';
               msgstruct.message = 'There is no password stored for this user.';       
            case 'com.mathworks.toolbox.distcomp.auth.UnknownUserException'
               msgstruct.identifier = 'distcomp:auth:UnknownUser';
               msgstruct.message = 'This user does not exist or there is no password stored.';
        end
    else
        switch exceptionType
            case 'com.mathworks.toolbox.distcomp.util.PortUnavailableException'
                msgstruct.identifier = 'distcomp:object:PortUnavailable';
                msgstruct.message = 'Port unavailable.  Please use the pctconfig function if on client or mdce_def file if on worker to select a different port.';
        end        
    end        
end

function storeSize = iGetDataStoreSizeInMB()
storeSize =  fix(com.mathworks.toolbox.distcomp.util.LargeDataInvoker.getDataStoreSize() / (1024 * 1024));
end

function exportPort = iGetDataStoreExportPort()
exportPort = com.mathworks.toolbox.distcomp.util.LargeDataInvoker.getDataStoreExportPort();
end
