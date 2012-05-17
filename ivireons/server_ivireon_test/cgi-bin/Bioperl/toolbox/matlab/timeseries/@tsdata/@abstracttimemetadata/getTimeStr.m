function dispmsg = getTimeStr(timeInfo)

% Copyright 2005 The MathWorks, Inc.

%% Generates a string describing the time vector

%% Create the current time vector string
if ~isempty(timeInfo.StartDate)
    if tsIsDateFormat(timeInfo.Format)
        try
            startstr = datestr(datenum(timeInfo.StartDate,timeInfo.Format)+timeInfo.Start*tsunitconv('days',...
                timeInfo.Units),timeInfo.Format);
            endstr = datestr(datenum(timeInfo.StartDate,timeInfo.Format)+timeInfo.End*tsunitconv('days',...
                 timeInfo.Units),timeInfo.Format);
        catch
             startstr = datestr(datenum(timeInfo.StartDate)+timeInfo.Start*tsunitconv('days',...
                timeInfo.Units));
             endstr = datestr(datenum(timeInfo.StartDate)+timeInfo.End*tsunitconv('days',...
                timeInfo.Units));
        end
    else
        startstr = datestr(datenum(timeInfo.StartDate)+timeInfo.Start*tsunitconv('days',...
            timeInfo.Units),'dd-mmm-yyyy HH:MM:SS');
        endstr = datestr(datenum(timeInfo.StartDate)+timeInfo.End*tsunitconv('days',...
            timeInfo.Units),'dd-mmm-yyyy HH:MM:SS');
    end
    dispmsg = sprintf('Current time: %s to %s',startstr,endstr);
else
    if isnan(timeInfo.Increment)
        dispmsg = sprintf('Current time: non-uniform %.4g to %.4g %s',...
            timeInfo.Start,timeInfo.End,timeInfo.Units);
    else
        dispmsg = sprintf('Current time: uniform %.4g to %.4g %s',...
            timeInfo.Start,timeInfo.End,timeInfo.Units);
    end
end