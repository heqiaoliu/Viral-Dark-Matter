%LABSEND - send data to another lab
%   labSend( data, destination ) sends the data to the specified
%   destination, with a tag of 0
%
%   labSend( data, destination, tag ) sends the data to the specified
%   destination with the specified tag
%
%   data can be any MATLAB data type.
%   destination must be either a scalar or a vector of integers between 1 and
%   numlabs; it cannot be labindex.
%   tag can be any integer >= 0.
%
%   This method may or may not return before a corresponding labReceive
%   completes.
%
%   See also labBarrier, labBroadcast, labReceive, labSendReceive, labindex, numlabs.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2009/09/23 13:59:26 $
