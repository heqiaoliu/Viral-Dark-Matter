function autoHideTimerReset(dp)
% Reset the timer by stopping it and restarting it
% Doing this will NOT allow TimerFcn to fire, only StopFcn and StartFcn.
% This allows us to know we reset the watchdog before it timed-out.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:26 $

stop(dp.hAutoHideTimer);
start(dp.hAutoHideTimer);
