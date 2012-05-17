classdef (Hidden = true) HostTCPIPCommunicator < rtw.connectivity.RtIOStreamHostCommunicator
%HOSTTCPIPCOMMUNICATOR implements a host-based TCP/IP communicator
%   HOSTTCPIPCOMMUNICATOR uses the TCP/IP implementation of the host-side
%   rtiostream API to provide a communications channel with the target
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/11/13 18:10:22 $

    methods
        % constructor
        function this = HostTCPIPCommunicator(componentArgs, ...
                launcher, rtiostreamLib)
            error(nargchk(3, 3, nargin, 'struct'));

            % call super class constructor
            this@rtw.connectivity.RtIOStreamHostCommunicator(componentArgs, ...
                                          launcher, ...
                                          rtiostreamLib);
        end

        
        % Open a TCPIP connection
        function initCommunications(this)
           % dynamically update the port number by processing the stdoutput
           % of the server
           launcher = this.getLauncher;
           outputFile = launcher.getOutputFile;
           commandLine = launcher.getCommandLine;
           
           nRetry=50;
           while nRetry > 0
               % check for file existence before calling fileread
               outputFileExists = exist(outputFile, 'file');
               if outputFileExists
                  % found output file
                  break;
               end
               % pause then try again
               pause(0.1);
               nRetry = nRetry - 1;               
           end                                 
           if ~outputFileExists
               rtw.connectivity.ProductInfo.error('target', 'MissingOutputFile', ...
                     outputFile);
           end
	   
                      
           nRetry=50;
           while nRetry > 0
                outputFileContents = fileread(outputFile);
                portCell = regexp(outputFileContents, ...
                                  'Server Port Number: (\d*)', 'tokens', 'once');
                if ~isempty(portCell)
                    % found server port number
                    break;
                end
                % Pause then try again
                pause(0.1);
                nRetry = nRetry - 1;               
           end                                           
           if isempty(portCell)
               rtw.connectivity.ProductInfo.error('target', 'UnknownServerPort', ...
                   outputFileContents, commandLine);
           end
           
           % Set TCP/IP port number arguments for opening the rtiostream
           argPair = {'-port', portCell{1}};
           this.setOpenRtIOStreamArgPair(argPair);
           
           % Call superclass method
           initCommunications@rtw.connectivity.RtIOStreamHostCommunicator(this)

   
        end
        
    end

end
