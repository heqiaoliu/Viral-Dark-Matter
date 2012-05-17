classdef ConnectivityConfig < rtw.connectivity.Config
%CONNECTIVITYCONFIG is a skeleton PIL configuration class
%
%   CONNECTIVITYCONFIG(COMPONENTARGS) creates instances of MAKEFILEBUILDER,
%   LAUNCHER, RTIOSTREAMHOSTCOMMUNICATOR and collects them together into a
%   connectivity configuration class for PIL.
%
%   You can make this skeleton class into a full implementation of CONFIG for
%   host-based PIL by uncommenting the lines tagged with "UNCOMMENT". This is
%   explained further in the demo RTWDEMO_CUSTOM_PIL.
%
%   See also RTW.CONNECTIVITY.CONFIG, RTW.CONNECTIVITY.MAKEFILEBUILDER,
%   RTW.MYPIL.TARGETAPPLICATIONFRAMEWORK, RTW.MYPIL.LAUNCHER,
%   RTW.CONNECTIVITY.RTIOSTREAMHOSTCOMMUNICATOR, RTWDEMO_CUSTOM_PIL
    
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
    
    methods
        % Constructor
        function this = ConnectivityConfig(componentArgs)
            
            % An executable framework specifies additional source files and
            % libraries required for building the PIL executable
            targetApplicationFramework = ...
                rtw.mypil.TargetApplicationFramework(componentArgs);
            
            % Filename extension for executable on the target system (e.g.
            % '.exe' for Windows or '' for Unix
            if ispc
                exeExtension = '.exe';
            else
                exeExtension = '';
            end
            
            % Create an instance of MakefileBuilder; this works in
            % conjunction with your template makefile to build the PIL
            % executable
            builder = rtw.connectivity.MakefileBuilder(componentArgs, ...
                targetApplicationFramework, ...
                exeExtension);
            
            % Launcher
            launcher = rtw.mypil.Launcher(componentArgs, builder);
            
            % File extension for shared libraries (e.g. .dll on Windows)
            sharedLibExt=system_dependent('GetSharedLibExt'); 

            % Evaluate name of the rtIOStream shared library
            if ispc
                prefix = '';
            else
                prefix='libmw';
            end
            rtiostreamLib = [prefix 'rtiostreamtcpip' sharedLibExt];
            
            hostCommunicator = rtw.connectivity.RtIOStreamHostCommunicator(...
                componentArgs, ...
                launcher, ...
                rtiostreamLib);
            
            % For some targets it may be necessary to set a timeout value
            % for initial setup of the communications channel. For example,
            % the target processor may take a few seconds before it is
            % ready to open its side of the communications channel. If a
            % non-zero timeout value is set then the communicator will
            % repeatedly try to open the communications channel until the
            % timeout value is reached.
            hostCommunicator.setInitCommsTimeout(0); 
            
            % Configure a timeout period for reading of data by the host 
            % from the target. If no data is received with the specified 
            % period an error will be thrown.
            timeoutReadDataSecs = 60;
            hostCommunicator.setTimeoutRecvSecs(timeoutReadDataSecs);

            % INSERT YOUR CODE HERE TO CUSTOMIZE THE CONNECTIVITY 
            % CONFIGURATION FOR YOUR TARGET. ALTERNATIVELY UNCOMMENT THE 
            % FOLLOWING LINES TO IMPLEMENT A HOST-BASED EXAMPLE. TO 
            % UNCOMMENT LINES IN THE MATLAB EDITOR, SELECT THE LINES AND
            % ENTER CTRL-T.
            
%            % Specify a fixed TCP/IP port number (for both host and    %UNCOMMENT
%            % target)                                                  %UNCOMMENT
%            portNumStr = '14646';  % cubed root of pi                  %UNCOMMENT
%                                                                       %UNCOMMENT
%            % Specify additional arguments when starting the           %UNCOMMENT
%            % executable (this configures the target-side of the       %UNCOMMENT
%            % communications channel)                                  %UNCOMMENT
%            launcher.setArgString(['-port ' portNumStr ' -blocking 1'])%UNCOMMENT
%                                                                       %UNCOMMENT   
%            % Custom arguments that will be passed to the              %UNCOMMENT
%            % rtIOStreamOpen function in the rtIOStream shared         %UNCOMMENT
%            % library (this configures the host-side of the            %UNCOMMENT
%            % communications channel)                                  %UNCOMMENT
%            rtIOStreamOpenArgs = {...                                  %UNCOMMENT
%                '-hostname', 'localhost', ...                          %UNCOMMENT
%                '-client', '1', ...                                    %UNCOMMENT
%                '-blocking', '1', ...                                  %UNCOMMENT
%                '-port',portNumStr,...                                 %UNCOMMENT
%                };                                                     %UNCOMMENT
%            hostCommunicator.setOpenRtIOStreamArgList(...              %UNCOMMENT
%                rtIOStreamOpenArgs);                                   %UNCOMMENT
            
            % call super class constructor to register components
            this@rtw.connectivity.Config(componentArgs,...
                                         builder,...
                                         launcher,...
                                         hostCommunicator);
        end
    end
end

