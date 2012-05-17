function [id, msg] = pProcessConnectException(obj, exception, sockAddr) %#ok Obj never used.
; %#ok Undocumented
%pProcessConnectException Rewrite the communication errors in connect.

%   This is a 1:1 copy of @interactiveclient/pProcessConnectException.m

%   Copyright 2006-2007 The MathWorks, Inc.
    


clientHostname = char( sockAddr.getHostName );
port = sockAddr.getPort;

id = exception.identifier;
msg = exception.message;
[isjava, exceptionType] = isJavaException(exception);
if ~isjava
    return;
end
cfg = pctconfig();
thisHostname = cfg.hostname;
if any(strcmp(exceptionType, {'java.net.ConnectException', ...
                        'java.net.SocketException'}))
    id = 'distcomp:pmode:FailedToConnect';
    msg = sprintf(...
        ['Lab %d on host %s failed to connect to the MATLAB client\n'...
         'on host %s, port %d.'], labindex, thisHostname, ...
        clientHostname, port);
end
if any(strcmp(exceptionType, {'java.net.UnknownHostException', ...
                        'java.nio.channels.UnresolvedAddressException'}))
    id = 'distcomp:pmode:FailedToConnect';
    msg = sprintf(...
        ['Lab %d on host %s failed to recognize the host name \n'...
         '%s where the MATLAB client is running.'], labindex,  ...
        thisHostname, clientHostname);
end
