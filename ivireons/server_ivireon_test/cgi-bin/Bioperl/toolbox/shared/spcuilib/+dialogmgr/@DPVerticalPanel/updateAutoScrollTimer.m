function updateAutoScrollTimer(dp,timerShouldRun)
% Manage auto-scroll timer state.
% If timerShouldRun=true, the timer is started if currently stopped.
% Similarly, if timerShouldRun=false, the timer is stopped if running

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:33 $

hTimer = dp.hAutoScrollTimer;
if timerShouldRun
    if strcmpi(hTimer.Running,'off')
        start(hTimer);
    end
else
    if ~strcmpi(hTimer.Running,'off')
        stop(hTimer);
    end
end
