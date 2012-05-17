classdef (Hidden = true) HostDemoConnectivityConfig < rtw.connectivity.Config
%HOSTDEMOCONNECTIVITYCONFIG is a target connectivity configuration class for PIL
%   HOSTDEMOCONNECTIVITYCONFIG(COMPONENTARGS) creates instances of
%   MAKEFILEBUILDER, HOSTLAUNCHER, HOSTTCPIPCOMMUNICATOR and collects them
%   together into a connectivity configuration class for PIL.
%
%   See also RTW.CONNECTIVITY.CONFIG, RTW.CONNECTIVITY.MAKEFILEBUILDER,
%   RTW.CONNECTIVITY.HOSTLAUNCHER and RTW.CONNECTIVITY.HOSTTCPIPCOMMUNICATOR
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $

    methods
        % Constructor
        function this = HostDemoConnectivityConfig(componentArgs)
            % Create an instance of rtw.connectivity.MakefileBuilder; this
            % class provides configuration data required by the build process
        
            % A target application framework specifies additional source
            % files and libraries required for building the PIL application
            targetApplicationFramework = ...
                rtw.pil.HostDemoApplicationFramework(componentArgs);
            
            % Filename extension for executable on the target system
            if ispc % Windows
                exeExtension = '.exe';
            else % Unix
                exeExtension = '';
            end
            
            builder = rtw.connectivity.MakefileBuilder(componentArgs, ...
                                                       targetApplicationFramework,...
                                                       exeExtension);
            % launcher with port 0 argument to start TCP/IP server on free port
            launcher = rtw.connectivity.HostLauncher(componentArgs, builder);
            launcher.setArgString('-port 0 -blocking 1');                         
            
            % Evaluate name of the shared library to use for rtiostream communications
            sharedLibExt=system_dependent('GetSharedLibExt');
            if ispc
                prefix = '';
            else
                prefix='libmw';
            end
            rtiostreamLibTcpip = [prefix 'rtiostreamtcpip' sharedLibExt];

            % Configure the rtiostream via TCP/IP to operate in "blocking" mode; this avoids
            % loading the CPU when the host process is waiting for data from the
            % target.
            blockingArg = '1';
            
            % Note that the communicator dynamically determines the TCP/IP port via the
            % launcher
            rtIOStreamOpenArgs = {...
                '-hostname', 'localhost', ...
                '-client', '1', ...
                '-blocking', blockingArg, ...
                   };

            communicator = rtw.connectivity.HostTCPIPCommunicator(componentArgs, ...
                                                        launcher, ...
                                                        rtiostreamLibTcpip);
            communicator.setOpenRtIOStreamArgList(rtIOStreamOpenArgs);
            
            % call super class constructor to register components
            this@rtw.connectivity.Config(componentArgs, builder, launcher, communicator);
                                     
            % register timer 
            if ~isempty(getenv('MW_SIL_EXECUTION_PROFILING_ENABLED'))
                timer = rtw.pil.HostTimer(targetApplicationFramework);
                this.setTimer(timer);
            end
            
        end
    end
end

