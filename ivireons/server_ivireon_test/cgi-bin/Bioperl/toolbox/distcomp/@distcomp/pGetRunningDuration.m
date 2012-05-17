function [runningDuration startdate] = pGetRunningDuration(obj)
; %#ok Undocumented
% Gets the common display structure for a job object. outputs at least ONE
% display structure with a header as entries in the output cell array.

% Copyright 2006-2008 The MathWorks, Inc.

% $Revision: 1.1.6.3 $  $Date: 2008/11/04 21:15:11 $

% initialise outputs
runningDuration = '';
startdate = obj.StartTime;
if isempty(startdate) % just still has not started
    % return if job has not started execution
    return;
end

try
    SDF = java.text.SimpleDateFormat('E MMM dd H:m:s z yyyy', java.util.Locale.US);

    finishdate = obj.FinishTime;
    if isempty(finishdate)
        % get the current time
        JDATEFinish = java.util.Date;
    else
        JDATEFinish = SDF.parse(finishdate);
    end

    JDATEStart = SDF.parse(startdate);
    % Note that getTime returns milliseconds so need to divide by 1000
    diffInSecs = floor((JDATEFinish.getTime - JDATEStart.getTime)/1000);
    if diffInSecs > 0
        secPerMin = 60;
        secPerHour = 60*60;
        secPerDay = 24*secPerHour;

        days = floor(diffInSecs/secPerDay);
        diffInSecs = diffInSecs - days*secPerDay;

        hours = floor(diffInSecs/secPerHour);
        diffInSecs = diffInSecs - hours*secPerHour;

        mins = floor(diffInSecs/secPerMin);

        secs = diffInSecs - mins*secPerMin;
        runningDuration = sprintf('%d days %dh %dm %ds', days, hours, mins, secs);
    end
catch err %#ok<NASGU>
end
