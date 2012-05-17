function constants = getInteractiveConstants()
; %#ok Undocumented
%getInteractiveConstants  Return the constants used in interactiveclient and interactivelab.

% Copyright 2006-2007 The MathWorks, Inc.


% The timeout to wait between sending the stop signal to the server and 
% destroying the job.
clientTimeBetweenStopAndDestroyJob = 30;
% The SO_TIMEOUT we use for the regular sockets.  In milliseconds.
socketSoTimeout = 10;
% The SO_TIMEOUT we use for the server socket.  In milliseconds.
serverSocketSoTimeout = 2000;
% The server socket backlog is used in construction of the client's
% ServerSocket, and also the labs ensure that no more than this number of
% simultaneous connections are attempted.
connectionBacklog = 20;
% The time in seconds we wait the first time we find that the pmode port is
% unavailable.  We will double the wait time on every failed attempt.
startWaitTimeForPort = 0.1;
% The number of times we try to create a server socket on the pmodeport.
maxTriesForPort = 7;

constants = struct( ...
    'clientTimeBetweenStopAndDestroyJob', clientTimeBetweenStopAndDestroyJob,...
    'socketSoTimeout', socketSoTimeout, ...
    'serverSocketSoTimeout', serverSocketSoTimeout, ...
    'connectionBacklog', connectionBacklog, ...
    'startWaitTimeForPort', startWaitTimeForPort, ...
    'maxTriesForPort', maxTriesForPort);
