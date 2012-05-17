classdef (Hidden = true) Utils < handle
%UTILS provides general utility methods.
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $

    methods (Static = true) % static methods

        function validateArg(arg, expectedClass)
            % utility function to validate argument types
            error(nargchk(2, 2, nargin, 'struct'));
            if ~ischar(expectedClass)
                rtw.connectivity.ProductInfo.error('target', 'InvalidCharArgument', ...
                    class(expectedClass));
            end
            if ~isa(arg, expectedClass)
                rtw.connectivity.ProductInfo.error('target', 'InvalidArgument', ...
                    expectedClass, class(arg));
            end
        end
        
        function validateTimerDataType(arg, expectedDataType)
            % utility function to validate timer  datatype
            error(nargchk(2, 2, nargin, 'struct'));
            
            if ~any(strmatch(arg, expectedDataType, 'exact'))
                rtw.connectivity.ProductInfo.error('target', 'InvalidTimerDataType',...
                       arg, sprintf('%s ', expectedDataType{:}));
            end
        end
        
        % Check if the specified process is alive
        function [alive] = isAlive(pid)
            alive = psUtils('isalive', pid);
        end
        
        function origEnvVars = setEnvVars(envVars)
            origEnvVars = envVars;
            for i=1:length(envVars)
                origEnvVars(i).value = getenv(envVars(i).name);
                setenv(envVars(i).name,envVars(i).value);
            end
        end

        % Launches an executable via a temporary script file and directs
        % executable stdout & stderr to a temporary file.
        %
        % Returns PID for the executable
        % Returns a file for output from the executable
        %
        % tempname is used to create the temporary scriptFile and
        % exeOutputFile files.   tempname generates time dependent
        % temporary names so there will not be any clashes between
        % multiple calls to launchProcess from the same MATLAB instance or
        % from multiple MATLAB's.
        function [exePID, ...
                  exeOutputFile] = launchProcess(exe, argString, envVars)
            
            if nargin < 3
                envVars = '';
            end
            scriptFile = [tempname '.bat'];
            rtw.connectivity.Utils.cleanTempFile(scriptFile);
            exeOutputFile = [tempname '.out'];
            rtw.connectivity.Utils.cleanTempFile(exeOutputFile);
            origEnvVars = rtw.connectivity.Utils.setEnvVars(envVars);
            c = onCleanup(@() rtw.connectivity.Utils.setEnvVars(origEnvVars));
            if ispc
                fid = fopen(scriptFile, 'w');
                % launch the exe and capture stdout and stderr
                fprintf(fid, '"%s" %s > "%s" 2>&1', exe, argString, exeOutputFile);
                fclose(fid);
                % start the script
                % 
                % scriptPID will remain active until it is terminated or until 
                % exePID terminates (forced or otherwise) giving scriptPID the
                % chance to terminate normally.
                commandLine = '';
                scriptPID = psUtils('winlaunchproc', scriptFile, commandLine);
                % get the PID of the exe so we can terminate it later
                % timeout to allow child process to start
                timeout = 5;
                try 
                    exePID = rtw.connectivity.Utils.getChildPidWithTimeout(scriptPID, timeout);
                catch exc
                    rethrow(exc)
                end
            else % Unix
                fid = fopen(scriptFile, 'w');
                % launch the exe and capture stdout and stderr
                fprintf(fid, '#!/bin/sh\n'); % specify shell to use
                fprintf(fid, '"%s" %s > "%s" 2>&1 & \n', exe, argString, exeOutputFile);
                fprintf(fid, 'echo $!\n'); % specify shell to use
                fclose(fid);
                
                valid_pid = 0;
                fileattrib(scriptFile,'+x');
                [~,w]=system(scriptFile);
                lf=10; % linefeed character
                lfi=find(w==lf);
                if (length(lfi)>=1)
                    exePID=str2double(w(1:lfi(1)));
                    if ~isnan(exePID)
                        valid_pid=1;
                    end
                end
                
                if valid_pid==0
                    rtw.connectivity.ProductInfo.error('target', 'ProcessStart', ...
		          exe);
                end
            end
            % Cleanup now the script file
            rtw.connectivity.Utils.cleanTempFile(scriptFile);
        end

        % Kills a process given the PID and file argument provided by
        % launchProcess
        function killProcess(exePID, ...
                             exeOutputFile)
            % Use psUtils to kill the executable
            if psUtils('isalive', exePID)
                psUtils('kill', exePID);
            end
            % Wait until the process has terminated
            timeout = 5;
            pause_amt = 0.1;            
            numRetries = timeout / pause_amt;
            exeIsAlive = true;
            for i=1:numRetries
               if ~psUtils('isalive', exePID)
                   exeIsAlive = false;    
                   break;
               end
               pause(pause_amt);               
            end          
            if exeIsAlive
               % warn
               rtw.connectivity.ProductInfo.warning('target', ...
                                                    'ExeIsAlive', ...
                                                    exePID);
            else
                % allow process to fully free up its exeOutputFile
                % resource so that we can delete it successfully                
                exeOutputFileExists = true;
                % disable delete warning
                origWarningState = warning('off', 'MATLAB:DELETE:Permission');
                c = onCleanup(@()warning(origWarningState));
                for i=1:numRetries
                    rtw.connectivity.Utils.cleanTempFile(exeOutputFile);
                    if ~exist(exeOutputFile, 'file')
                        exeOutputFileExists = false;
                        break;
                    end                    
                    pause(pause_amt);                    
                end
                if exeOutputFileExists
                    % warn
                    rtw.connectivity.ProductInfo.warning('target', ...
                                                         'ExeOutputFileExists', ...
                                                          exeOutputFile);
                end                                
            end                                    
        end  
        
        function isOpenNagForModel = isOpenNagForModel(model)
            % find Simulink diagnostic viewer
            nagCtrl = find_dv;
            % check its title string references the model
            if ~isempty(nagCtrl) && ...
                    nagCtrl.Visible && ...
                    ~isempty(strfind(nagCtrl.Title, model))
                isOpenNagForModel = true;
            else
                isOpenNagForModel = false;
            end
        end        
    end

    methods (Static = true, Access = 'private')
        
        % delete temporary file / dir
        function cleanTempFile(fileName)
            if exist(fileName, 'file')
                delete(fileName);
            else
                if exist(fileName, 'dir')
                    [status, message, messageid] = rmdir(fileName,'s');
                    if ~status
                        % rethrow
                        error(messageid, message);
                    end
                end
            end
        end

        % This code is modified from:
        % matlab\toolbox\distcomp\@distcomp\@mpiexec\pSubmitParallelJob.m
        %
        % getChildPidWithTimeout - wait for the given parent PID to launch a child
        % process and return its PID
        function child = getChildPidWithTimeout(parent, timeout)
            timeWaited = 0;
            child = [];
            pause_amt = 0.1;
            while psUtils('isalive', parent) && ...
                    isempty(child) && ...
                    timeWaited < timeout
                pause(pause_amt);
                timeWaited = timeWaited + pause_amt;
                try
                    child = psUtils('winchildren', parent);
                    % winchildren should return no children or a single
                    % child
                    assert(isempty(child) || (length(child) == 1));                    
                catch e
                   switch e.identifier
                       case 'TargetCommon:psfcns:NoProcess'
                           % parent must have terminated during this loop
                           % iteration
                           continue;
                       otherwise
                           rethrow(e);
                   end
                end
            end
            % If we never find the child, just return the parent process.
            if isempty(child)
                child = parent;
            end
        end
    end
end
