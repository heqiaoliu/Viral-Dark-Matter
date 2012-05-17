classdef Launcher < rtw.connectivity.Launcher
%LAUNCHER is a skeleton class for launching a PIL application
%
%   LAUNCHER(COMPONENTARGS,BUILDER) instantiates a LAUNCHER object that you can
%   use to control starting and stopping of an application on the target
%   processor. In this case, the target processor is a processor of your host
%   computer.
%
%   You can make this skeleton class into a full implementation of LAUNCHER by
%   uncommenting the lines tagged with "UNCOMMENT". This is explained further in
%   the demo RTWDEMO_CUSTOM_PIL.
%
%   See also RTW.CONNECTIVITY.LAUNCHER, RTWDEMO_CUSTOM_PIL
    
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
   
    properties
    
        % INSERT YOUR CODE HERE TO DEFINE CUSTOM PROPERTIES
    
        % ALTERNATIVELY UNCOMMENT THE FOLLOWING LINES TO IMPLEMENT A HOST-BASED
        % EXAMPLE. TO UNCOMMENT LINES IN THE MATLAB EDITOR, SELECT THE LINES AND
        % ENTER CTRL-T.

%        % For the host-based example, additional arguments  %UNCOMMENT
%        % may be provided when the executable is launched   %UNCOMMENT
%        % as a separate process on the host. For example,   %UNCOMMENT
%        % it may be required to specify a TCP/IP port       %UNCOMMENT
%        %  number.                                          %UNCOMMENT
%        ArgString = '';                                     %UNCOMMENT
%                                                            %UNCOMMENT        
%        % For the host-based example, it is necessary to    %UNCOMMENT
%        % keep track of the process ID of the executable    %UNCOMMENT
%        % so that this process can be killed when no longer %UNCOMMENT
%        % required                                          %UNCOMMENT
%        ExePid = '';                                        %UNCOMMENT
%                                                            %UNCOMMENT        
%        % For the host-based example, it is necessary to    %UNCOMMENT
%        % keep track a temporary file created by the        %UNCOMMENT
%        % process launcher so that it can be deleted when   %UNCOMMENT
%        % the process is terminated                         %UNCOMMENT
%        TempFile = '';                                      %UNCOMMENT
        
    end
    
    methods
        % constructor
        function this = Launcher(componentArgs, builder)
            error(nargchk(2, 2, nargin, 'struct'));
            % call super class constructor
            this@rtw.connectivity.Launcher(componentArgs, builder);
        end
        
        % destructor
        function delete(this) %#ok
            
            % This method is called when an instance of this class is cleared from memory,
            % e.g. when the associated Simulink model is closed. You can use
            % this destructor method to close down any processes, e.g. an IDE or
            % debugger that was originally started by this class. If the
            % stopApplication method already performs this housekeeping at the
            % end of each on-target simulation run then it is not necessary to
            % insert any code in this destructor method. However, if the IDE or
            % debugger may be left open between successive on-target simulation
            % runs then it is recommended to insert code here to terminate that
            % application.
                
            % INSERT YOUR CODE HERE TO CLEAN UP ALL PROCESSES ASSOCIATED
            % WITH EXECUTING THE APPLICATION ON THE TARGET

        end
        
        % INSERT YOUR CODE HERE TO IMPLEMENT CUSTOM METHODS FOR THE LAUNCHER 
        % CLASS
        
        % ALTERNATIVELY UNCOMMENT THE FOLLOWING LINES TO IMPLEMENT A HOST-BASED
        % EXAMPLE. TO UNCOMMENT LINES IN THE MATLAB EDITOR, SELECT THE LINES
        % AND ENTER CTRL-T.

%        % Specify command line arguments; for example, you may %UNCOMMENT
%        % need to provide a TCP/IP port number to override the %UNCOMMENT
%        % default port number. If your Launcher does not       %UNCOMMENT
%        % require any dynamic parameter configuration then     %UNCOMMENT
%        % this method may not be required.                     %UNCOMMENT
%        function setArgString(this, argString)                 %UNCOMMENT
%            disp('EXECUTING METHOD SETARGSTRING')              %UNCOMMENT
%            stack = dbstack;                                   %UNCOMMENT
%            disp(['SETARGSTRING called from line '...          %UNCOMMENT
%                  int2str(stack(2).line) ' of ' ...            %UNCOMMENT
%                  stack(2).file ])                             %UNCOMMENT
%                                                               %UNCOMMENT
%            this.ArgString = argString;                        %UNCOMMENT
%        end                                                    %UNCOMMENT
        
        % Start the application
        function startApplication(this)
            % get name of the executable file
            exe = this.getBuilder.getApplicationExecutable; %#ok
            
            % INSERT YOUR CODE HERE TO DOWNLOAD THE EXECUTABLE AND START
            % EXECUTION ON THE TARGET
            
            % ALTERNATIVELY UNCOMMENT THE FOLLOWING LINES TO IMPLEMENT A HOST-BASED
            % EXAMPLE. TO UNCOMMENT LINES IN THE MATLAB EDITOR, SELECT THE LINES
            % AND ENTER CTRL-T.

%            % launch                                                 %UNCOMMENT
%            disp('DEMO: startApplication')                           %UNCOMMENT
%            [this.ExePid, this.TempFile] = ...                       %UNCOMMENT
%                rtw.connectivity.Utils.launchProcess(...             %UNCOMMENT
%                    exe, ...                                         %UNCOMMENT
%                    this.ArgString);                                 %UNCOMMENT
%            % Pause to ensure that server-side of TCP/IP connection  %UNCOMMENT
%            % is established and ready to accept a client connection %UNCOMMENT
%            pause(0.4)                                               %UNCOMMENT
%            if ~rtw.connectivity.Utils.isAlive(this.ExePid)          %UNCOMMENT
%                disp('')                                             %UNCOMMENT
%                disp(['Process is not alive, displaying contents '...%UNCOMMENT
%                     'of log file:'])                                %UNCOMMENT
%                disp('')                                             %UNCOMMENT
%                type(this.TempFile)                                  %UNCOMMENT
%                disp('')                                             %UNCOMMENT
%                error(['Failed to start process with PID = '...      %UNCOMMENT
%                    num2str(this.ExePid) ' using arguments '...      %UNCOMMENT
%                    this.ArgString '. '...                           %UNCOMMENT
%                    'The process may have failed to start '...       %UNCOMMENT
%                    'correctly, for example, because an existing '...%UNCOMMENT
%                    'process is already bound to the same TCP/IP '...%UNCOMMENT
%                    'port. Check that there are no other '...        %UNCOMMENT
%                    'processes running on this machine that are '... %UNCOMMENT
%                    'bound to this TCP/IP port.'])                   %UNCOMMENT
%            end                                                      %UNCOMMENT
%            disp(['Started new process, pid = ' ...                  %UNCOMMENT
%                  int2str(this.ExePid) ])                            %UNCOMMENT

        end
        
        % Stop the application
        function stopApplication(this) %#ok
            
            % INSERT YOUR CODE HERE TO STOP EXECUTION ON THE TARGET
            
            % ALTERNATIVELY UNCOMMENT THE FOLLOWING LINES TO IMPLEMENT A HOST-BASED
            % EXAMPLE. TO UNCOMMENT LINES IN THE MATLAB EDITOR, SELECT THE LINES
            % AND ENTER CTRL-T.

%            disp('DEMO: stopApplication')                                  %UNCOMMENT
%            if ~isempty(this.ExePid)                                       %UNCOMMENT
%                rtw.connectivity.Utils.killProcess(this.ExePid, ...        %UNCOMMENT
%                                                   this.TempFile);         %UNCOMMENT
%                disp(['Terminated process, pid = ' int2str(this.ExePid)]); %UNCOMMENT
%            end                                                            %UNCOMMENT
%            this.ExePid = '';                                              %UNCOMMENT
%            %                                                              %UNCOMMENT
            
        end
    end
end
