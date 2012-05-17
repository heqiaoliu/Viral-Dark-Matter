classdef RemoteClusterAccess < handle
    %RemoteClusterAccess Class for connecting to schedulers when client utilities are not available locally

    %  Copyright 2010 The MathWorks, Inc.

    %  $Revision: 1.1.6.4 $  $Date: 2010/05/10 17:03:47 $
    
    properties (SetAccess = private)
        Hostname = '';
        % This is the remote DataLocation using slashes as provided
        % by the user.
        DataLocation = '';
        IsConnected = false;
        IsFileMirrorSupported = false;
        Username = '';
        IdentityFilename = '';
        % Are we using passwords or identity files?
        UseIdentityFile = false;
        IdentityFileHasPassphrase = false;
    end
    
    properties (Access = private)
        JobsBeingMirrored = [];
        UserCredentialsParameterMap;
        % The java code requires all remote data locations to use
        % unix slashes.
        UnixSlashDataLocation = '';
        % The (undocumented) PCT QE supplied credential map
        PCTQECredentialMap;
    end
    
    properties (Constant, GetAccess = private)
        % We never want to mirror the file that contains the JobSchedulerData because
        % the JobSchedulerData may change after the mirror has been started for the job.
        % NB Properties must have the same case as those defined in 
        % @distcomp/@filestorage/schema.m
        DoNotMirrorJobProperties = {'jobschedulerdata'};
        % Never delete local files if they are deleted from the remote end
        DoNotDeleteLocalIfRemoteDeleted = false;
        % Prefix to add to all dctSchedulerMessages
        SchedulerMessagePrefix = 'RemoteClusterAccess:';
        WindowsSlash = '\';
        UnixSlash = '/';
    end
    
    methods
        % -------------------------------------------------------------------------
        % constructor
        % -------------------------------------------------------------------------
        function obj = RemoteClusterAccess(username, varargin)
        % RemoteClusterAccess constructor
        % RemoteClusterAccess allows you to establish a connection and run commands 
        % on a remote host.
        %
        %  r = RemoteClusterAccess(username) uses the supplied username when 
        %  connecting to the remote host.  You will be prompted for a password when 
        %  establishing the connection.
        %
        %  r = RemoteClusterAccess(username, P1, V1, ..., Pn, Vn) allows additional parameter-value
        %  pairs that modify the behavior of the connection. The accepted parameters are:
        %   - 'IdentityFilename' - A string containing the full path to the identity file
        %     to use when connecting to a remote host.  If IdentityFilename is not
        %     supplied, you will be prompted for a password when establishing the connection.
        %   - 'IdentityFileHasPassphrase' - A boolean indicating whether or not the identity file 
        %     requires a passphrase.  If true, you will be prompted for a password when 
        %     establishing a connection.  If an identity file is not supplied, this property is
        %     ignored.  This value is false by default.

        % Undocumented P-V pair for testing purposes
        %   - 'PCTQECredentialMap' - A com.mathworks.toolbox.distcomp.remote.ParameterMap containing
        %     the credentials to use.
        %
            error(nargchk(1, inf, nargin, 'struct'));
            
            if ~ischar(username)
                error('distcomp:RemoteClusterAccess:InvalidArgument', ...
                    'Username must be a string.');
            end
            obj.Username = username;

            % Convert the args to a parseable format
            [allProps, allValues] = parallel.internal.convertToPVArrays(varargin{:});
            allowedProps = {'IdentityFilename', 'IdentityFileHasPassphrase'};
            % Check that each property is unique amongst the allowed parameters
            for i = 1:numel(allProps)
                thisProp  = allProps{i};
                thisValue = allValues{i};
                
                % To guard against users accidentally stumbling on PCTQECredentialMap, 
                % this property name must be matched EXACTLY and is case-sensitive
                if strcmp(thisProp, 'PCTQECredentialMap')
                    if ~isa(thisValue, 'com.mathworks.toolbox.distcomp.remote.ParameterMap')
                        error('distcomp:RemoteClusterAccess:InvalidArgument', ...
                            'The value for PCTQECredentialMap must be a ParameterMap.');
                    end
                    obj.PCTQECredentialMap = thisValue;
                    continue;
                end

                % Find this property name in each of the sets of properties
                indexInProps  = find(strncmpi(thisProp, allowedProps, numel(thisProp)));
                if isempty(indexInProps)
                    error('distcomp:RemoteClusterAccess:InvalidInput', ...
                        '%s is not a valid property input to the RemoteClusterAccess constructor', thisProp);
                elseif numel(indexInProps) > 1
                    error('distcomp:RemoteClusterAccess:InvalidInput', ...
                        ['%s is an ambiguous property input to the RemoteClusterAccess constructor ', ...
                        'since it matches multiple valid property names'], thisProp);
                end
                % We know that only one property was matched by thisProp and
                % thus that one of the indexInProps holds a single value
                switch indexInProps
                    case 1 % IdentityFilename
                        if ~ischar(thisValue)
                            error('distcomp:RemoteClusterAccess:InvalidArgument', ...
                                'IdentityFilename must be a string.');
                        end
                        % Check that this is a valid file.  Note that exist(..., 'file') checks
                        % both files and directories, so we explicitly ensure that the file
                        % is a file and not a dir.
                        fileExists = exist(thisValue, 'file');
                        if fileExists == 0
                            error('distcomp:RemoteClusterAccess:InvalidIdentityFile', ...
                                'The supplied identity file ''%s'' does not exist.', thisValue);
                        end
                        if fileExists == 7
                            error('distcomp:RemoteClusterAccess:InvalidIdentityFile', ...
                                'The supplied identity file ''%s'' is a directory and not a file.', thisValue);
                        end
                        obj.UseIdentityFile = true;
                        obj.IdentityFilename = thisValue;
                    case 2 % IdentityFileHasPassphrase
                        if ~islogical(thisValue)
                            error('distcomp:RemoteClusterAccess:InvalidArgument', ...
                                'The value for FileHasPassphrase must be logical.');
                        end
                        obj.IdentityFileHasPassphrase = thisValue;
                    otherwise
                        error('distcomp:RemoteClusterAccess:InternalError', ...
                            'An internal error occurred.');
                end
            end
            % Error if we were given both an Identity file and Parameter Map
            if ~isempty(obj.PCTQECredentialMap) && obj.UseIdentityFile
                error('distcomp:RemoteClusterAccess:InvalidArgument', ...
                    'Supplying both an identity file and a parameter map is not allowed.');
            end
        end
    
        % -------------------------------------------------------------------------
        % connect
        % -------------------------------------------------------------------------
        function connect(obj, clusterHost, remoteDataLocation)
        % CONNECT connect to a remote host and optionally use the specified remote location
        % for mirroring of job files.
        %
        % RemoteClusterAccess.connect(clusterHost) establishes a connection to the 
        % specified host using the user credential options supplied in the constructor.
        % File Mirroring is not supported.  
        %
        % RemoteClusterAccess.connect(clusterHost, remoteDataLocation) establishes a 
        % connection to the specified host using the user credential options supplied 
        % in the constructor.  Files from your scheduler's DataLocation are mirrored 
        % to the remoteDataLocation on the clusterHost.
        
            error(nargchk(2, 3, nargin, 'struct'));
            if obj.IsConnected
                error('distcomp:RemoteClusterAccess:AlreadyConnected', ...
                    'Cannot connect to %s: already connected to %s', ...
                    clusterHost, obj.Hostname);
            end
            
            % remoteDataLocation is an optional input arg
            if nargin < 3
                remoteDataLocation = '';
            end

            userCredentials = obj.getOrCreateCredentialsParameterMap(clusterHost);
            clusterAccess = obj.getClusterAccess;
            try
                clusterAccess.connect(clusterHost, userCredentials);
            catch err
                ex = MException('distcomp:RemoteClusterAccess:FailedToConnect', ...
                    'Could not connect to remote host %s.', clusterHost);
                ex = ex.addCause(err);
                throw(ex);
            end

            % Set the data once we know we are connected
            obj.Hostname = clusterHost;
            obj.DataLocation = remoteDataLocation;
            obj.UserCredentialsParameterMap = userCredentials;
            obj.IsConnected = true;
            obj.IsFileMirrorSupported = ~isempty(remoteDataLocation);
            % Convert remoteDataLocation to unix fileseps
            obj.UnixSlashDataLocation = strrep(remoteDataLocation, obj.WindowsSlash, obj.UnixSlash);
        end
        
        % -------------------------------------------------------------------------
        % disconnect
        % -------------------------------------------------------------------------
        function disconnect(obj)
        % DISCONNECT disconnect from a remote host
        %
        % RemoteClusterAccess.disconnect() disconnects the existing remote connection.
        % The CONNECT method must have already been called.
        
            obj.errorIfNotConnected();

            % NB disconnect does not throw any errors
            clusterAccess = obj.getClusterAccess;
            clusterAccess.disconnect(obj.Hostname, obj.UserCredentialsParameterMap);

            obj.Hostname = '';
            obj.DataLocation = '';
            obj.UnixSlashDataLocation = '';
            obj.IsConnected = false;
            obj.IsFileMirrorSupported = false;
            obj.UserCredentialsParameterMap = [];
            obj.JobsBeingMirrored = [];
        end
        
        % -------------------------------------------------------------------------
        % startMirrorForJob
        % -------------------------------------------------------------------------
        function startMirrorForJob(obj, job)
        % startMirrorForJob start the mirroring of files from the local DataLocation to 
        % the remote DataLocation for the supplied job.
        %
        % RemoteClusterAccess.startMirrorForJob(job) copies all the job files from the 
        % local DataLocation to the remote DataLocation, and starts the mirroring of files 
        % such that any changes to the files in the remote DataLocation will be copied back
        % to the local DataLocation.  The CONNECT method must have already been called.
        
            error(nargchk(2, 2, nargin, 'struct'));
            obj.errorIfNotConnected();
            obj.errorIfMirroringNotSupported('start mirror');
            obj.errorIfAlreadyBeingMirrored(job.ID, 'start');
            
            % Use a 1s poll interval for file copying chores
            pollInterval = 1; 
            clusterAccess = obj.getClusterAccess;
            mirrorFilesInfo = obj.createMirrorFilesInfo(job);
            try
                sendAndMirrorChore = clusterAccess.sendAndMirrorJobFiles(...
                    obj.Hostname, obj.UserCredentialsParameterMap, mirrorFilesInfo);
                obj.waitForChoreToFinishOrError(sendAndMirrorChore, pollInterval);
                % Add the job ID to the list of jobs being mirrored
                obj.addJobToMirrorList(job.ID);
            catch err
                % If anything went wrong, try to remove the remote files
                dctSchedulerMessage(6, '%s Removing files for job %d because of error when starting mirror', ...
                    obj.SchedulerMessagePrefix, job.ID);
                try
                    removeFilesChore = clusterAccess.removeFilesForJob(obj.Hostname, ...
                        obj.UserCredentialsParameterMap, mirrorFilesInfo);
                    obj.waitForChoreToFinishOrError(removeFilesChore);
                catch removeErr 
                    warning('distcomp:RemoteClusterAccess:FailedToRemoveRemoteFiles', ...
                        ['Failed to remove remote files for job %d.\n', ...
                        'You may need to delete these files manually.\nReason: %s'], ...
                        job.ID, removeErr.getReport);
                end
                obj.throwFailedMirrorActionError('Start', 'start', job.ID, err);
            end
        end
        
        % -------------------------------------------------------------------------
        % stopMirrorForJob
        % -------------------------------------------------------------------------
        % This will cancel any running mirrors and remove the remote files.
        % This provides an abrupt termination of the mirroring process: no
        % attempt is made to ensure that the client has up-to-date files.
        function stopMirrorForJob(obj, job)
        % stopMirrorForJob stop the mirroring of files from the local DataLocation to 
        % the remote DataLocation for the supplied job.  
        %
        % RemoteClusterAccess.stopMirrorForJob(job) stops the mirroring of files from the 
        % local DataLocation to the remote DataLocation for the supplied job.  The 
        % startMirrorForJob or resumeMirrorForJob method must have already been called.  
        % This cancels the running mirror and removes the files for the job from the 
        % remote location.  This is similar to resumeMirrorForJob except that this method
        % makes no attempt to ensure that the local job files are up-to-date.
        
            error(nargchk(2, 2, nargin, 'struct'));
            obj.errorIfNotConnected();
            obj.errorIfMirroringNotSupported('stop mirror');
            obj.errorIfNotBeingMirrored(job.ID, 'stop');
            
            clusterAccess = obj.getClusterAccess;
            % Ensure we cancel the mirroring first before removing the 
            % remote files
            dctSchedulerMessage(6, '%s Cancelling mirror for job %d.', ...
                obj.SchedulerMessagePrefix, job.ID);
            errorToThrow = [];
            try
                clusterAccess.cancelMirrorForJob(obj.Hostname, ...
                    obj.UserCredentialsParameterMap, job.ID);
            catch err
                % Save up the error for later because we need to remove the 
                % remote files
                errorToThrow = MException('distcomp:RemoteClusterAccess:FailedToCancelMirror', ...
                    'Failed to cancel mirror for job %d.', job.ID);
                errorToThrow = errorToThrow.addCause(err);
            end
            
            dctSchedulerMessage(6, '%s Removing remote files for job %d.', ...
                obj.SchedulerMessagePrefix, job.ID);
            try
                obj.removeRemoteFiles(job);
            catch removeErr
                % Just warn if we couldn't remove the remote files
                warning('distcomp:RemoteClusterAccess:FailedToRemoveRemoteFiles', ...
                    ['Failed to remove the remote files for job %d. \n', ...
                    'You may need to delete the job files from %s manually.\nReason: %s'], ...
                    job.ID, obj.DataLocation, removeErr.getReport);
            end
                        
            % The mirror has been cancelled and the remote files removed
            % so the job is no longer using the connection
            obj.removeJobFromMirrorList(job.ID);

            if ~isempty(errorToThrow)
                throw(errorToThrow);
            end
        end
        
        % -------------------------------------------------------------------------
        % resumeMirrorForJob
        % -------------------------------------------------------------------------
        function resumeMirrorForJob(obj, job)
        % resumeMirrorForJob resume the mirroring of files from the local DataLocation to 
        % the remote DataLocation for the supplied job.  
        %
        % RemoteClusterAccess.resumeMirrorForJob(job) resumes the mirroring of files from the 
        % remote DataLocation to the local DataLocation for the supplied job.  This is similar 
        % to the startMirrorForJob method but this method does not copy the files from the local
        % DataLocation to the remote DataLocation.  The CONNECT method must have already been 
        % called.  
        
            error(nargchk(2, 2, nargin, 'struct'));
            obj.errorIfNotConnected();
            obj.errorIfMirroringNotSupported('resume mirror');
            obj.errorIfAlreadyBeingMirrored(job.ID, 'resume');
            
            clusterAccess = obj.getClusterAccess;
            mirrorFilesInfo = obj.createMirrorFilesInfo(job);
            try
                mirrorFilesChore = clusterAccess.resumeMirrorForJob(obj.Hostname, ...
                    obj.UserCredentialsParameterMap, mirrorFilesInfo);
                obj.waitForChoreToFinishOrError(mirrorFilesChore);
                % Add the job ID to the list of jobs being mirrored
                obj.addJobToMirrorList(job.ID);
            catch err
                % Don't attempt any cleanup at the remote end if resume errored.  We should
                % preserve the files on the remote end until user asks us to stop the mirror.
                obj.throwFailedMirrorActionError('Resume', 'resume', job.ID, err);
            end
        end
        
        % -------------------------------------------------------------------------
        % doLastMirrorForJob
        % -------------------------------------------------------------------------
        % This will do a complete mirror for the job and stop any running mirrors
        % and then remove the remote files.  This provides a graceful
        % termination of the mirroring process: we only remove the remote
        % files if we could successfully do the last mirror.
        function doLastMirrorForJob(obj, job)
        % doLastMirrorForJob perform a last mirror for the files from the remote 
        % DataLocation to the local DataLocation for the supplied job.  
        %
        % RemoteClusterAccess.doLastMirrorForJob(job) performs a final copy of 
        % changed files from the remote DataLocation to the local DataLocation for the 
        % supplied job.  Any running mirrors for the job are also stopped and the job 
        % files are removed from the remote DataLocation.  The startMirrorForJob or 
        % resumeMirrorForJob method must have already been called.  

            error(nargchk(2, 2, nargin, 'struct'));
            obj.errorIfNotConnected();
            obj.errorIfMirroringNotSupported('do last mirror');
            
            % It is OK to do the last mirror even if the job is not currently being mirrored
            % Use a 1s poll interval for file copying chores
            pollInterval = 1; 
            clusterAccess = obj.getClusterAccess;
            mirrorFilesInfo = obj.createMirrorFilesInfo(job);
            try
                mirrorFilesChore = clusterAccess.doLastMirrorForJob(obj.Hostname, ...
                    obj.UserCredentialsParameterMap, mirrorFilesInfo);
                obj.waitForChoreToFinishOrError(mirrorFilesChore, pollInterval);
            catch err
                obj.throwFailedMirrorActionError('DoLast', 'do last', job.ID, err);
            end
            
            % Only remove the remove files doLastMirrorForJob did not error
            try
                obj.removeRemoteFiles(job);
            catch removeErr
                % Just warn if we couldn't remove the remote files
                warning('distcomp:RemoteClusterAccess:FailedToRemoveRemoteFiles', ...
                    ['Failed to remove the remote files for job %d. \n', ...
                    'You may need to delete the job files from %s manually.\nReason: %s'], ...
                    job.ID, obj.DataLocation, removeErr.getReport);
            end
            
            % The last mirror has been done and the remote files removed
            % so the job is no longer using the connection.  Note the job
            % may not actually be in our list, but that is OK because
            % removeJobFromMirrorList can handle that.
            obj.removeJobFromMirrorList(job.ID);
        end
        
        % -------------------------------------------------------------------------
        % isJobUsingConnection
        % -------------------------------------------------------------------------
        % Do we think the job is being mirrored and is therefore using the connection?
        % NB this always returns false if file mirroring has not been configured.
        function foundJob = isJobUsingConnection(obj, jobID)
        % isJobUsingConnection query the connection to see if the job is being mirrored.
        %
        % RemoteClusterAccess.isJobUsingConnection(jobID) returns true if the job is 
        % currently being mirrored.  
            error(nargchk(2, 2, nargin, 'struct'));
            obj.errorIfNotConnected();
            foundJob = obj.IsFileMirrorSupported && any(obj.JobsBeingMirrored == jobID);
        end
        
        % -------------------------------------------------------------------------
        % getRemoteJobLocation
        % -------------------------------------------------------------------------
        function remoteJobDirectory = getRemoteJobLocation(obj, jobID, remoteOS)
        % getRemoteJobLocation get the remote location for the supplied job ID.
        %
        % RemoteClusterAccess.getRemoteJobLocation(jobID, remoteOS) returns the full
        % path to the remote job location for the supplied jobID.  Valid values of 
        % remoteOS are 'pc' and 'unix'
            error(nargchk(2, 3, nargin, 'struct'));
            obj.errorIfNotConnected();
            obj.errorIfMirroringNotSupported('get remote job location');
            allowedOS = {'unix', 'pc'};
            if ~any(strcmpi(remoteOS, allowedOS))
                error('distcomp:RemoteClusterAccess:IncorrectRemoteOS', ...
                    'Allowed values of remoteOS are: %s', sprintf('%s ', allowedOS{:}));
            end

            if strcmpi(remoteOS, 'unix')
                remoteFileSeparator = obj.UnixSlash;
            else
                remoteFileSeparator = obj.WindowsSlash;
            end

            % Build up the remote directory using the remote OS's slashes
            % We assume that the user provided the correctly slashed
            % DataLocation from their cluster OS type in the first place.
            remoteJobDirectory = sprintf('%s%sJob%d', obj.DataLocation, remoteFileSeparator, jobID);
        end

        % -------------------------------------------------------------------------
        % runCommand
        % -------------------------------------------------------------------------
        function [cmdStatus, cmdOut] = runCommand(obj, commandToRun)
        % runCommand run the supplied command on the remote host.
        %
        % [status, result] = RemoteClusterAccess.runCommand(command) runs the supplied 
        % command on the remote host and returns the resulting status and standard output
        % The CONNECT method must have already been called.  
        
            error(nargchk(2, 2, nargin, 'struct'));
            obj.errorIfNotConnected();

            clusterAccess = obj.getClusterAccess;
            try
                executeCommandChore = clusterAccess.executeCommand(obj.Hostname, ...
                    obj.UserCredentialsParameterMap, commandToRun);
                obj.waitForChoreToFinishOrError(executeCommandChore);
                cmdStatus = double(executeCommandChore.getExitStatus());
                
                % Check if stdout/stderr are reliable and warn if not.  Note that
                % we will still proceed to get the stdout and stderr because they 
                % may still contain something interesting.
                if ~executeCommandChore.isStdoutReliable
                    warning('distcomp:RemoteClusterAccess:StdOutUnreliable', ...
                        'Standard out from command %s may be unreliable.', commandToRun);
                end
                if ~executeCommandChore.isStderrReliable
                    warning('distcomp:RemoteClusterAccess:StdErrUnreliable', ...
                        'Standard error from command %s may be unreliable.', commandToRun);
                end
                % NB getStdOut and getStdErr come out as columns, so
                % transpose them as well as converting to char
                cmdOut = char(executeCommandChore.getStdOut())';
                cmdErr = char(executeCommandChore.getStdErr())';
                if ~isempty(cmdErr)
                    cmdOut = sprintf('%s\n%s', cmdOut, cmdErr);
                end
            catch err
                ex = MException('distcomp:RemoteClusterAccess:FailedToRunCommand', ...
                    'Failed to run command "%s" on host %s.', commandToRun, obj.Hostname);
                ex = ex.addCause(err);
                throw(ex);
            end
        end
    end
    
    methods (Access = private)
        % -------------------------------------------------------------------------
        % errorIfNotConnected
        % -------------------------------------------------------------------------
        function errorIfNotConnected(obj)
            if ~obj.IsConnected
                ex = MException('distcomp:RemoteClusterAccess:NotConnectedToRemoteHost', ...
                    'Not connected to a remote host');
                throwAsCaller(ex);
            end
        end
        
        % -------------------------------------------------------------------------
        % errorIfMirroringNotSupported
        % -------------------------------------------------------------------------
        function errorIfMirroringNotSupported(obj, action)
            if ~obj.IsFileMirrorSupported()
                ex = MException('distcomp:RemoteClusterAccess:MirroringNotSupported', ...
                    ['Cannot %s because file mirroring is not enabled.\n', ...
                    'To enable file mirroring, supply a remote data location to the connect method.'], ...
                    action);
                throwAsCaller(ex);
            end
        end

        % -------------------------------------------------------------------------
        % errorIfAlreadyBeingMirrored
        % -------------------------------------------------------------------------
        function errorIfAlreadyBeingMirrored(obj, jobID, mirrorAction)
            if obj.isJobUsingConnection(jobID)
                ex = MException('distcomp:RemoteClusterAccess:JobAlreadyBeingMirrored', ...
                    'Cannot %s mirror for job with ID %d because it is already being mirrored.', ...
                    mirrorAction, jobID);
                throwAsCaller(ex);
            end
        end
        
        % -------------------------------------------------------------------------
        % errorIfNotBeingMirrored
        % -------------------------------------------------------------------------
        function errorIfNotBeingMirrored(obj, jobID, mirrorAction)
            if ~obj.isJobUsingConnection(jobID)
                ex = MException('distcomp:RemoteClusterAccess:JobNotBeingMirrored', ...
                    'Cannot %s mirror for job with ID %d because it is not being mirrored.', ...
                    mirrorAction, jobID);
                throwAsCaller(ex);
            end
        end
        
        % -------------------------------------------------------------------------
        % addJobToMirrorList
        % -------------------------------------------------------------------------
        function addJobToMirrorList(obj, jobID)
            obj.JobsBeingMirrored(end+1) = jobID;
        end
        
        % -------------------------------------------------------------------------
        % removeJobFromMirrorList
        % -------------------------------------------------------------------------
        % This method must not error because it is being called from a catch block
        function removeJobFromMirrorList(obj, jobID)
            matchingJobIndex = obj.JobsBeingMirrored == jobID;
            obj.JobsBeingMirrored(matchingJobIndex) = [];
        end
        
        

        % -------------------------------------------------------------------------
        % removeRemoteFiles
        % -------------------------------------------------------------------------
        function removeRemoteFiles(obj, job)
            clusterAccess = obj.getClusterAccess;
            mirrorFilesInfo = obj.createMirrorFilesInfo(job);
            
            try
                removeFilesChore = clusterAccess.removeFilesForJob(obj.Hostname, ...
                    obj.UserCredentialsParameterMap, mirrorFilesInfo);
                obj.waitForChoreToFinishOrError(removeFilesChore);
            catch err
                ex = MException('distcomp:RemoteClusterAccess:FailedToRemoveRemoteFiles', ...
                    'Failed to remove remote files for job %d.', job.ID);
                ex = ex.addCause(err);
                throw(ex);
            end
        end
    
        % -------------------------------------------------------------------------
        % getOrCreateCredentialsParameterMap
        % -------------------------------------------------------------------------
        % Prompts the user for their username and password and converts them into a 
        % com.mathworks.toolbox.distcomp.clusteraccess.ParameterMap
        function credentials = getOrCreateCredentialsParameterMap(obj, hostname)
            if ~isempty(obj.PCTQECredentialMap)
                credentials = obj.PCTQECredentialMap;
                return;
            end
        
            import com.mathworks.toolbox.distcomp.clusteraccess.*;
            import com.mathworks.toolbox.distcomp.remote.*;
            import com.mathworks.toolbox.distcomp.remote.spi.plugin.JSchParameter;
            
            dctSchedulerMessage(6, '%s Using username %s to connect to %s', ...
                obj.SchedulerMessagePrefix, obj.Username, hostname);
            
            % Do an explicit conversion of the username to a java string because
            % something goes wrong with the char->string conversion when the MATLAB
            % char has only 1 character.
            javaUsername = java.lang.String(obj.Username);
            
            credentials = ParameterMap();
            credentials.put(JSchParameter.STRICT_HOST_KEY_CHECKING, ...
                JSchParameter.STRICT_HOST_KEY_CHECKING.getSuggestedValue());
            credentialParameters = ParameterMap();
            
            if obj.UseIdentityFile
                keyFile = java.io.File(obj.IdentityFilename);
                credentialParameters.put(IdentityFileCredentialDescription.USERNAME, javaUsername);
                credentialParameters.put(IdentityFileCredentialDescription.IDENTITY_FILE, keyFile);

                if obj.IdentityFileHasPassphrase
                    passphraseMsg = sprintf('Please enter the passphrase for identity file %s: ', obj.IdentityFilename);
                    keyfilePassphrase = obj.solicitPassword(passphraseMsg);
                    credentialParameters.put(IdentityFileCredentialDescription.PASSPHRASE, keyfilePassphrase);
                end
                
                credentials.put(JSchParameter.JSCH_CREDENTIAL, ...
                    IdentityFileCredentialDescription.INSTANCE.create(credentialParameters));
            else
                passwordMsg = sprintf('Please enter the password for user %s on %s: ', obj.Username, hostname);
                password = obj.solicitPassword(passwordMsg);

                credentialParameters.put(PasswordCredentialDescription.USERNAME, javaUsername);
                credentialParameters.put(PasswordCredentialDescription.PASSWORD, password);
                credentials.put(JSchParameter.JSCH_CREDENTIAL, ...
                    PasswordCredentialDescription.INSTANCE.create(credentialParameters));
            end
        end

        % -------------------------------------------------------------------------
        % createMirrorFilesInfo
        % -------------------------------------------------------------------------
        % Creates a com.mathworks.toolbox.distcomp.clusteraccess.MirrorFilesInfo
        % for a particular job.
        function filesInfo = createMirrorFilesInfo(obj, job)
            [stateFiles, dataFiles] = obj.getFilesToUploadToRemote(job);
            excludeFromMirrorFiles = obj.getDoNotMirrorFiles(job, [stateFiles; dataFiles]);
            
            dctSchedulerMessage(6, '%s State files to upload for job %d:\n%s', ...
                obj.SchedulerMessagePrefix, job.ID, sprintf('\t%s\n', stateFiles{:}));
            dctSchedulerMessage(6, '%s Data files to upload for job %d:\n%s', ...
                obj.SchedulerMessagePrefix, job.ID, sprintf('\t%s\n', dataFiles{:}));
            dctSchedulerMessage(6, '%s Files to exclude from mirror for job %d:\n%s', ...
                obj.SchedulerMessagePrefix, job.ID, sprintf('\t%s\n', excludeFromMirrorFiles{:}));
                
            stateFileSet = iCellStringToSetString(stateFiles);
            dataFileSet = iCellStringToSetString(dataFiles);
            excludeFromMirrorSet = iCellStringToSetString(excludeFromMirrorFiles);
            excludeFromUploadSet = iCellStringToSetString({});
            
            scheduler = job.Parent;
            localDataLocation = scheduler.DataLocation;

            filesInfo = com.mathworks.toolbox.distcomp.clusteraccess.MirrorFilesInfo(job.Id, ...
                java.io.File(localDataLocation), ...
                obj.UnixSlashDataLocation, ...
                dataFileSet, ...
                stateFileSet, ...
                excludeFromUploadSet, ...
                excludeFromMirrorSet, ...
                obj.DoNotDeleteLocalIfRemoteDeleted, ...
                obj.DoNotDeleteLocalIfRemoteDeleted);
        end
    end

    
    methods (Static, Access = private) 
        % -------------------------------------------------------------------------
        % throwFailedMirrorActionError
        % -------------------------------------------------------------------------
        function throwFailedMirrorActionError(mirrorActionID, mirrorActionMessage, jobID, causingError)
            errorID = sprintf('distcomp:RemoteClusterAccess:FailedTo%sMirror', mirrorActionID);
            errorMessage = sprintf('Failed to %s mirror for job with ID %d.', mirrorActionMessage, jobID);
            
            ex = MException(errorID, errorMessage);
            if ~isempty(causingError)
                ex = ex.addCause(causingError);
            end
            throwAsCaller(ex);
        end

        % -------------------------------------------------------------------------
        % getClusterAccess
        % -------------------------------------------------------------------------
        function clusteraccess = getClusterAccess()
            clusteraccess = com.mathworks.toolbox.distcomp.clusteraccess.ClusterAccess.INSTANCE;
        end
        
        % -------------------------------------------------------------------------
        % getFilesToUploadToRemote
        % -------------------------------------------------------------------------
        % Returns the relative path to the files that need to be copied to the remote
        % location for the specified job.  
        % State files = the job's state files
        % Data files = all other files, including all task files in the JobX directory
        %               and the metadata file.
        function [stateFiles, dataFiles] = getFilesToUploadToRemote(job)
            scheduler = job.Parent;
            storage = scheduler.pReturnStorage;
            
            % Ask the file storage for the appropriate job file extension for state
            jobStateFile = strcat(job.pGetEntityLocation, storage.pGetExtensionsForFields('job', 'state'));
            % Get all the job files and remove the jobStateFiles from them.  The remainder are
            % considered "data" files.
            allJobFiles = strcat(job.pGetEntityLocation, storage.Extensions);
            dataFiles = allJobFiles(~strcmpi(allJobFiles, jobStateFile));
            % All the task files are considered to be data files
            taskFiles = '';
            if ~isempty(job.Tasks)
                taskFiles = job.pGetEntityLocation;
            end
            
            stateFiles = {jobStateFile};
            % Always include the metadata file in the mirroring.
            dataFiles = [dataFiles; taskFiles; storage.MetadataFilename];
        end
        
        % -------------------------------------------------------------------------
        % getDoNotMirrorFiles
        % -------------------------------------------------------------------------
        % Gets the files that should not be mirrored.  These include the metadata file
        % and those job files that contain the job properties that we do not wish to mirror
        % as well as any files that are being uploaded, but are (user) read-only in the 
        % location
        function doNotMirrorJobFiles = getDoNotMirrorFiles(job, filesToUpload)
            scheduler = job.Parent;
            storage = scheduler.pReturnStorage;

            % Find the files that we do not want to mirror.
            doNotMirrorJobExtensions = unique(storage.pGetExtensionsForFields('job', ...
                parallel.cluster.RemoteClusterAccess.DoNotMirrorJobProperties));
            doNotMirrorJobFiles = strcat(job.pGetEntityLocation, doNotMirrorJobExtensions);
            
            % Also remove any job files that do not have local user write permissions
            readOnlyFiles = parallel.cluster.RemoteClusterAccess.getReadOnlyFiles(scheduler.DataLocation, filesToUpload);
            
            % Always exclude the metadata file from the mirroring.  NB we assume that the 
            % metadata file lives in the root of the DataLocation
            doNotMirrorJobFiles = [doNotMirrorJobFiles; storage.MetadataFilename; readOnlyFiles];
        end

        % -------------------------------------------------------------------------
        % getReadOnlyFiles
        % -------------------------------------------------------------------------
        % Returns the readOnlyFiles relative the dirPrefix.
        function readOnlyFiles = getReadOnlyFiles(dirPrefix, filenames)
            readOnlyFiles = {};
            for ii = 1:numel(filenames)
                currFile = filenames{ii};
                currFullFile = fullfile(dirPrefix, currFile);
                if isdir(currFullFile)
                    listing = dir(currFullFile);
                    % Remove '.' and '..' from the listing
                    filesInDir = {listing.name};
                    filesInDir = filesInDir(~strcmp('.', filesInDir));
                    filesInDir = filesInDir(~strcmp('..', filesInDir));
                    % And recursively call this method to get the read only files
                    readOnlyInDir = parallel.cluster.RemoteClusterAccess.getReadOnlyFiles(currFullFile, filesInDir); 
                    % Make sure we put the current relative dir back onto the list of files
                    if ~isempty(readOnlyInDir)
                        readOnlyFiles = [readOnlyFiles; strcat(currFile, filesep, readOnlyInDir)]; %#ok<AGROW>
                    end
                else
                    [~, attribs] = fileattrib(currFullFile);
                    if isstruct(attribs) && ~attribs.UserWrite
                        readOnlyFiles = [readOnlyFiles; currFile];  %#ok<AGROW>
                    end
                end
            end
        end
        
        % -------------------------------------------------------------------------
        % waitForChoreToFinishOrError
        % -------------------------------------------------------------------------
        function waitForChoreToFinishOrError(chore, pollInterval)
            assert(isa(chore, 'com.mathworks.toolbox.distcomp.clusteraccess.RemoteMachineChore'), ...
                'distcomp:RemoteClusterAccess:InternalError', ...
                'Chore must be a RemoteMachineChore.');
               
            % use a default poll interval of 0.1s
            if nargin < 2
                pollInterval = 0.1;
            end
            
            % This function only returns normally when the chore has completed 
            % with no problems.
            % TODO - should save up errors until chore has actually ended?
            while true
                err = chore.getProblems;
                if ~isempty(err) && err.size > 0
                    errorMessage = sprintf('The following errors occurred in the %s:', class(chore));
                    for ii = 0:err.size-1
                        currentProblem = err.get(ii);
                        errorMessage = sprintf('%s\n\t%s\n%s', errorMessage, ...
                            char(currentProblem.getMessage()), char(currentProblem.getCause())); 
                    end
                    
                    % Always throw the errors using the first ID from the list of problems
                    firstProblem = err.get(0);
                    errorID = sprintf('distcomp:RemoteClusterAccess:%s', char(firstProblem.getErrorCode().getMatlabErrorId));
                    error(errorID, '%s', errorMessage);
                end
                if chore.hasEnded()
                    break;
                end
                pause(pollInterval);
            end
        end
        
        % -------------------------------------------------------------------------
        % solicitPassword
        % -------------------------------------------------------------------------
        % Prompts a user for a password.
        function password = solicitPassword(promptMsg)
            
            if com.mathworks.jmi.Support.useSwing()
                passwordField = javaObjectEDT('javax.swing.JPasswordField',40);
                result = javaMethodEDT('showConfirmDialog','javax.swing.JOptionPane', ...
                    [], passwordField, promptMsg, ...
                    javax.swing.JOptionPane.OK_CANCEL_OPTION, ...
                    javax.swing.JOptionPane.PLAIN_MESSAGE);
                if result == javax.swing.JOptionPane.OK_OPTION
                    passwordString =  java.lang.String(passwordField.getPassword());
                else
                    error('distcomp:RemoteClusterAccess:NoPassword', ...
                        'User did not enter a password.');
                end
            else
                passwordChars = parallel.internal.readPassword(promptMsg);
                
                %if passwordChars is a java.lang.Exception then error
                if isa(passwordChars, 'java.lang.Exception')
                    message = char(passwordChars.getMessage());
                    error('distcomp:RemoteClusterAccess:NoPassword', ...
                        'Problem getting password from command line. %s',message);
                end
                passwordString = java.lang.String(passwordChars);
            end
            
            password = com.mathworks.toolbox.distcomp.remote.Password(passwordString);
        end
    end
end

% -------------------------------------------------------------------------
% iCellStringToSetString
% -------------------------------------------------------------------------
% Convert a MATLAB cell array of strings into a Set of java Strings
function setOfStrings = iCellStringToSetString(cellOfStrings)
    setOfStrings = java.util.LinkedHashSet(numel(cellOfStrings));
    for ii = 1:numel(cellOfStrings)
        setOfStrings.add(cellOfStrings{ii});
    end
end