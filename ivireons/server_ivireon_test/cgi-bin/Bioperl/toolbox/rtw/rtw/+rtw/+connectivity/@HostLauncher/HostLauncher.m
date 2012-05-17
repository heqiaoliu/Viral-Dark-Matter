classdef (Hidden = true) HostLauncher < rtw.connectivity.Launcher
%HOSTLAUNCHER starts or stops an application on the host computer
%   HOSTLAUNCHER(COMPONENTARGS,BUILDER) instantiates a HOSTLAUNCHER object that
%   you can use to control starting and stopping of an application on the host
%   computer.
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $

    properties(SetAccess = 'protected', GetAccess = 'protected')
        exe;
        exePID;
        exeOutputFile;
        % default empty argument string
        argString = '';
        RTWVerbose;
    end

    methods
        % constructor
        function this = HostLauncher(componentArgs, builder)
            error(nargchk(2, 2, nargin, 'struct'));
            
            % call super class constructor
            this@rtw.connectivity.Launcher(componentArgs, builder);

            
            this.RTWVerbose=this.getComponentArgs.getParam('RTWVerbose');
            
        end

        % destructor
        function delete(this)
            % don't leave zombie processes
            this.stopApplication;
        end

        % specify command line arguments
        function setArgString(this, argString)
            this.argString = argString;
        end
        
        % Start the application
        function startApplication(this)
            % kill any running application
            this.i_stopApplication;
            % get exe to start
            this.exe = this.getBuilder.getApplicationExecutable;
            
            % Retrieve any setup commands for the launch environment 
            % (e.g. related to code coverage tool setup); these setup
            % commands may be specified by build hooks attached to the 
            % model
            envVars = this.getLaunchEnvironmentVars;
            
            componentPath = this.getComponentArgs.getComponentPath;
            disp(['### Starting SIL ' ...
                'simulation for component: ' componentPath])
            % cleanup now the process has stopped
            this.exePID = [];
            this.exeOutputFile = [];
            
            % Launch the target application
            [this.exePID this.exeOutputFile] = ...
                rtw.connectivity.Utils.launchProcess(this.exe, ...
                                                     this.argString,...
                                                     envVars);                                              
            if strcmp(this.RTWVerbose,'on')
                disp(['rtw.connectivity.HostLauncher: started '...
                      'executable with host process identifier ' ...
                      this.getPIDAsLink]);              
            end
        end

        % Stop the application
        function stopApplication(this)
            if ~isempty(this.exePID)
                
                pidAsLink = i_stopApplication(this);
                
                % We have to use the cached RTWVerbose setting as stopApplication may be called
                % from the destructor when the model is already in the process
                % of being closed; get_param would fail in this situation
                if strcmp(this.RTWVerbose,'on')
                    disp(['rtw.connectivity.HostLauncher: stopped '...
                          'executable with host process identifier ' ...
                          pidAsLink]);
                end
                
                componentPath  = this.getComponentArgs.getComponentPath;
                disp(['### Stopping SIL '...
                    'simulation for component: ' componentPath])
            end
        end   

        % get the path to the stdout / stderr redirection 
        % file associated with the application
        function outputFile = getOutputFile(this)
            outputFile = this.exeOutputFile;
        end
        
        % get the command line associated with the application
        function commandLine = getCommandLine(this)
            commandLine = [this.exe ' ' this.argString];
        end
    end

    methods (Access = 'private')
        
        % Stop the application
        function pidAsLink = i_stopApplication(this)
            if ~isempty(this.exePID)
                
                % Allow process to terminate itself gracefully
                waitCount=20;
                while waitCount>0 && rtw.connectivity.Utils.isAlive(this.exePID)
                    waitCount = waitCount-1;
                    pause(0.1);
                end
                
                % Kill the process (if it is still alive) and clean up
                % the temporary output file
                rtw.connectivity.Utils.killProcess(this.exePID, ...
                    this.exeOutputFile);
                
                pidAsLink = this.getPIDAsLink;
                
                % cleanup now the process has stopped
                this.exePID = [];
                this.exeOutputFile = [];
            end
        end
        
        function link = getPIDAsLink(this)
            commandText = ['disp('' '');' ...
                'disp(''Executable command line: ' this.getCommandLine ''');' ...
                'disp(''Executable temporary output file: ' this.exeOutputFile ''');' ...
                'disp('' '');'];
            link = targets_hyperlink_manager('new', int2str(this.exePID), commandText);
        end
    end
end
