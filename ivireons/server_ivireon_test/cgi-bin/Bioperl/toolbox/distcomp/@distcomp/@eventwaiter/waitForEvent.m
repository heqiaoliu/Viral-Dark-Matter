function OK = waitForEvent(obj, timeout)
; %#ok Undocumented

% Copyright 1984-2009 The MathWorks, Inc.

% $Revision: 1.1.8.7 $  $Date: 2009/04/15 22:58:22 $

if nargin > 1
    obj.Timeout = timeout;
end

USE_TIMER = obj.Timeout < Inf;

if USE_TIMER
    t = timer('TimerFcn',{@iTimerFcn obj});
    try
        % Start in timeout seconds time
        startat(t, now + obj.Timeout/86400);
    catch err
        % Check for a very short timeout and signal accordingly
        if strcmpi(err.identifier, 'MATLAB:timer:startat:startdelaynegative')
            iTimerTriggered(obj); 
        else
            rethrow(err);
        end
    end
end

% Block waiting for a change in Mutex to true
waitfor(obj, 'Mutex', true);
OK = obj.EventReceived;

if USE_TIMER
    stop(t);
    delete(t); 
end

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iTimerFcn(timer, event, obj) %#ok<INUSL>
iTimerTriggered(obj);

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
function iTimerTriggered(obj)
obj.EventReceived = false;
obj.eventTriggered;
