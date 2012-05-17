function schans = pGetSockets(obj)
; %#ok Undocumented

% Copyright 2006-2008 The MathWorks, Inc.

% $Revision: 1.1.6.3 $    $Date: 2008/06/24 17:01:33 $

% Loop whilst waiting for the job to connect back - this means
% we aren't blocking on the accept, as this ServerSocket has had its
% setSoTimeout set to a finite value.
startTime = clock();

% The following code mirrors the behaviour in @matlabpoollab/connectToClient
% for the sake of the labBarriers. If one day labBarrier(2:numlabs) is supported,
% replace the try clause with: socks = obj.pGetSockets(numlabs - 1);


% The connections occur in batches which are separated by labBarriers (see
% @matlabpoollab/connectToClient.m for details). The following loop
% imitates that behaviour by calling labBarrier every batchSize step.
constants = distcomp.getInteractiveConstants;
batchSize = constants.connectionBacklog - 1;

schans = [];
% BKN -- is this use of numlabs problematic? If yes, replace by
%        count = 0; numlabs = ?; while count < nlabs, ... count++ ...
for ii = 1:numlabs
    if ii > 1
        [currChan, nlabs, labidx] = iGetSingleSocket(obj, startTime);
        % EME -- should we assert nlabs==numlabs-1?
        if isempty(schans)
            schans = javaArray('java.nio.channels.SocketChannel', nlabs);
        end
        schans(labidx) = currChan; %#ok<AGROW> Deferred instantiation above
    end
    if mod(ii, batchSize) == 0 || ii == numlabs
        labBarrier;
    end
end
labBarrier;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [currChan, nlabs, labidx] = iGetSingleSocket(obj, startTime)
WAITING_FOR_SOCKET = true;

accepted = [];

while WAITING_FOR_SOCKET

    accepted           = obj.ConnectionManager.activelyAccept();
    WAITING_FOR_SOCKET = isempty( accepted );

    if WAITING_FOR_SOCKET && etime(clock, startTime) > obj.JobStartupTimeout
        iThrowTimeoutError(obj);
    end
    
    if WAITING_FOR_SOCKET
        pause( 0.01 );
    else
        dctSchedulerMessage(2, 'Received a socket connection.');
    end

end % while WAITING_FOR_SOCKET

currChan = accepted.socketChannel;
labidx   = accepted.processInstance.getLabIndex();
nlabs    = accepted.extraInfo;

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function iThrowTimeoutError(obj)
error('distcomp:interactive:TimeoutExceeded', ...
    ['The labs did not connect to the client within the allowed time ' ...
     'of %d seconds.\n'], ...
    obj.JobStartupTimeout);
