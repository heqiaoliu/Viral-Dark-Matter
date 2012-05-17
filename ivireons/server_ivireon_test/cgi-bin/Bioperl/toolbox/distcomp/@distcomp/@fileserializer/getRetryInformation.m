function [pauseDuration, pauseMultiplier, numRetries] = getRetryInformation(obj)
; %#ok Undocumented
%getRetryInformation get information relevant to retrying load and save
%
% [pauseDuration, pauseMultiplier, numRetries] = getRetryInformation(obj)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/03/31 17:07:22 $

persistent timeLastCalled;

timeNow = clock;    
% We want to scale the number of retries down a bit if this function has
% been called recently so that multiple calls to getField don't block for
% so long
MORE_THAN_2_SECS_SINCE_LAST_CALL = isempty(timeLastCalled) || etime(timeNow, timeLastCalled) > 2;

timeLastCalled = timeNow;

pauseDuration = 0.1;
pauseMultiplier = 1.5;


if MORE_THAN_2_SECS_SINCE_LAST_CALL
    numRetries = 5;
else
    numRetries = 2;
end    
