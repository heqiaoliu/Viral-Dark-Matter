%% Creating a Communications Channel for Target Connectivity
% This demo shows how to implement a communication channel for use with the
% Real-Time Workshop(R) product and your own custom target support package. 
%
% This communication channel enables exchange of data between different
% processes. This supports capabilities such as Processor-in-the-Loop (PIL)
% simulation that require exchange of data between the Simulink(R) software
% environment (running on your host machine) and deployed code (running on
% target hardware).
%
% You will learn about the rtiostream interface and how it provides a generic
% communication channel that you can implement in the form of target
% connectivity drivers for a range of different connection types. This demo
% explains how to use the default implementation via TCP/IP.
%
% You will learn how two entities, Station A and Station B can use the
% rtiostream interface to set up a communication channel and exchange data. For
% the purposes of this demo, both Station A and Station B are configured within
% the same process on your desktop computer.
% 
% You will learn how to use the target connectivity drivers to support an
% on-target PIL simulation. For on-target simulation, Station A and Station B
% represent the target and host computers that exchange data via the
% communication channel. On the host side, the target connectivity driver is
% implemented as a shared library that is loaded and called from within the
% MATLAB(R) product. On the target side, the driver must be source code or a
% library that is linked into the application that runs on the target.
%
% Additionally, this demo explains the steps required to:
%
% * Configure your own target-side driver for TCP/IP to operate with the default
%   host-side TCP/IP driver
% * Configure the supplied host-side driver for serial communications
% * Implement custom target connectivity drivers, e.g. using CAN or USB for both
%   host and target sides of the communication channel.
%
% See also <matlab:showdemo('rtwdemo_sil_pil_script') rtwdemo_sil_pil_script>,
% <matlab:showdemo('rtwdemo_custom_pil') rtwdemo_custom_pil>

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/11/13 04:56:18 $

%% View Source Code for the Default TCP/IP Implementation
% The file rtiostream_tcpip.c implements both client-side and server-side TCP/IP
% communication; a startup parameter is used to configure the driver to operate
% in either client or server mode. You may use this source file as a starting
% point for a custom implementation. Note that, in general, each side of the
% communication channel only requires one or other of the server or client
% implementations; if the client and server drivers will run on different
% architectures, it may be convenient to place the driver code for each
% architecture in a separate source file.
%
% The header file rtiostream.h contains prototypes for the functions
% rtIOStreamOpen/Send/Recv/Close. It must always be included (using #include) by
% any custom implementation.

% Location of TCP/IP driver source code
rtiostreamtcpip_dir=fullfile(matlabroot,'rtw','c','src','rtiostream',...
                              'rtiostreamtcpip');

% View rtiostream_tcpip.c
edit(fullfile(rtiostreamtcpip_dir,'rtiostream_tcpip.c'));

% View rtiostream.h
edit(fullfile(matlabroot,'rtw','c','src','rtiostream.h'));


%% Location Of Shared Library Files
% To access the target connectivity drivers from the MATLAB product they must be
% compiled to a shared library. The shared library must be located on your
% system path. A shared library for the default TCP/IP drivers is located in
% matlabroot/bin/$ARCH (where $ARCH is your system architecture, e.g. win64)

% The shared library filename extension and location depends on your operating
% system.
sharedLibExt=system_dependent('GetSharedLibExt');
if ispc
    prefix = '';
else
    prefix='libmw';
end

% Shared library for both Station A and Station B
libTcpip = [prefix 'rtiostreamtcpip' sharedLibExt];
disp(libTcpip)

%% Testing the Target Connectivity Drivers
% If you are implementing a custom target connectivity driver, it is helpful to
% be able to test it from within the MATLAB product. The following example shows
% how to load the default TCP/IP target connectivity drivers and use them for
% data exchange between Station A and Station B.
%
% To access the drivers you can use the MEX-file rtiostream_wrapper. This
% MEX-file allows you to load the shared library and access the rtiostream
% functions to open/close an rtiostream channel and send/receive data.
%
% In this example, both Station A and Station B are running on the host
% computer. Station A is configured as a TCP/IP server and Station B as a TCP/IP
% client. For host to target communication, the host is typically configured as
% a TCP/IP client and the target as a TCP/IP server.

% Choose a port number for TCP
if usejava('jvm')
    % Find a free port
    tempSocket = java.net.ServerSocket(0);
    port = num2str(tempSocket.getLocalPort);
    tempSocket.close;
else
    % Resort to a hard-coded port
    port = '14646';
end

% Open the Station A rtiostream as a TCP/IP server
stationA = rtiostream_wrapper(libTcpip,'open',...
                                 '-client', '0',...
                                 '-blocking', '0',...
                                 '-port',port);

% If the communication channel was successfully opened, the return value is a
% handle to the connection; a return value of -1 indicates an error.
assert(stationA~=(-1)) % Test for expected return value

% Open the Station B rtiostream as a TCP/IP client
stationB = rtiostream_wrapper(libTcpip,'open',...
                                 '-client','1',...
                                 '-blocking', '0',...
                                 '-port',port,...
                                 '-hostname','localhost');
% If the communication channel was successfully opened, the return value is a
% handle to the connection; a return value of -1 indicates an error.
assert(stationB~=(-1)) % Test for expected return value 

%% Send Some Data from Station B to Station A
% The target connectivity drivers are designed to send a stream of data in 8-bit
% bytes. For processors that are not byte-addressable the data is sent in the
% smallest addressable word size.

% Send Some Data from Station B to Station A
msgOut = uint8('Station A, this is Station B. Are you there? OVER');

[retVal sizeSent] = rtiostream_wrapper(libTcpip,...
                                       'send',...
                                       stationB,...
                                       msgOut,...
                                       length(msgOut));
assert(retVal==0); % A return value of zero indicates success
assert(sizeSent==length(msgOut)); % Check that all bytes in the message were sent

% Allow time to ensure data transmission is complete
pause(0.2)

% Receive data on the Station A
[retVal msgRecvd sizeRecvd] = rtiostream_wrapper(libTcpip,...
                                                 'recv',...
                                                 stationA,...
                                                 100);
assert(retVal==0); % A return value of zero indicates success
assert(sizeRecvd==sizeSent); % Check that all bytes in the message were received

% Display the received data
disp(char(msgRecvd))

%% Send a Response from Station A to Station B

% Send data from Station A to Station B
msgOut = uint8('Station B, this is Station A. Yes, I''m here! OVER.');
[~, sizeSent] = rtiostream_wrapper(libTcpip,... %#ok
                                       'send',...
                                       stationA,...
                                       msgOut,...
                                       length(msgOut));
% Allow time to ensure data transmission is complete
pause(0.2)

% Receive data on Station B
[~, msgRecvd, sizeRecvd] = rtiostream_wrapper(libTcpip,... %#ok
                                                 'recv',...
                                                 stationB,...
                                                 100);

% Display the received data
disp(char(msgRecvd))

%% Close Connection and Unload the Shared Libraries

% Close rtiostream on the Station B
retVal = rtiostream_wrapper(libTcpip,'close',stationB);
assert(retVal==0); % A return value of zero indicates no error

% Close rtiostream on the Station A
retVal = rtiostream_wrapper(libTcpip,'close',stationA);
assert(retVal==0) % A return value of zero indicates no error

% Unload the shared library
rtiostream_wrapper(libTcpip, 'unloadlibrary');

%% Using the Host-Side Driver for Serial Communications
% You can use the supplied host-side driver for serial communications as an
% alternative to the drivers for TCP/IP. You can configure the serial driver
% using a similar approach to the TCP/IP driver. For example, to open a serial
% rtiostream channel, on COM8, enter the command
%
%     stationA = rtiostream_wrapper('rtiostreamserial.dll','open','-port','COM8')
%
% The syntax for the 'send', 'recv', 'close' and 'unload' operations is the same
% as for the TCP/IP driver.

% Note that the serial driver is only available on the Windows platform only.


%% Next Steps to Configure Your Own Target-Side Driver
% If your target has an ethernet connection and you have a TCP/IP stack
% available, follow these steps:
% 
% 1. Write a wrapper for your TCP/IP stack that makes it available via the 
%    rtiostream interface defined in rtiostream.h.
% 2. Write a test application for your target that sends and receives some 
%    data, similar to the example above.
% 3. You can use the rtiostream_wrapper MEX-file and host-side TCP/IP driver
%    to test your driver software running on the target.
% 4. When you have a working target-side driver you must include driver source
%    files in the build for your code generated by the Real-Time Workshop
%    product.
%
% Note that the default host-side driver used by PIL mode is configured as a
% TCP/IP client; this means that your target-side driver need only be configured
% to operate as a TCP/IP server.
%
% If you need to use a communications channel that is not already supported 
% on the host-side, you will have to write drivers for both host and
% target. In this case you can still use the rtiostream_wrapper MEX-file
% for testing your rtiostream drivers.

%% Next Steps to Configure Your Own Host-Side Driver
% You can implement the target connectivity drivers using many different
% communication channels. For example, you may need to implement host-target
% communications via a special serial connection. In this case you must provide
% drivers for both the host and target.
%
% On the host-side, you can test the drivers using the rtiostream_wrapper
% MEX-file. Note that if your driver includes diagnostic output using printf
% these must be replaced with mexPrintf if the shared library is being loaded by
% rtiostream_wrapper.
%
% When you have a working host-side device driver you must make it available
% within the Simulink software environment. For PIL simulation, you can do this
% by registering the shared host-side shared library via sl_customization.

displayEndOfDemoMessage(mfilename)
