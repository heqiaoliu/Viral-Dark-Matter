%labSendReceive - simultaneously send to and receive from other labs
%   received = labSendReceive( labTo, labFrom, data ) sends "data" to labTo,
%   and receives "received" from labFrom. "labTo" and "labFrom" must be
%   scalars, or empty. This function is conceptually equivalent to the
%   following sequence of calls:
%   
%   labSend( data, labTo );
%   received = labReceive( labFrom );
%   
%   with the important exception that both the sending and receiving of data
%   will happen concurrently. This can eliminate deadlocks that may occur if
%   the equivalent call to labSend would block.
%   
%   received = labSendReceive( labTo, labFrom, data, tag ) uses the
%   specified tag for the communication.
%
%   If labTo is empty, then the send is not performed. If labFrom is empty,
%   then the receive is not performed, and the data returned will be
%   empty. In the special case where labTo==labFrom==labindex, then no
%   communication will be performed, and the data returned will be data to
%   be sent.
%   
%   Example:
%   mydata    = magic( labindex );
%   labTo     = mod( labindex, numlabs ) + 1; % one lab to the right
%   labFrom   = mod( labindex - 2, numlabs ) + 1; % one lab to the left
%   otherdata = labSendReceive( labTo, labFrom, mydata );
%   
%   See also labSend, labReceive.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 22:41:11 $
