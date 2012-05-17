function thisTimeInfo = getTimeProperty(h,prop)

% Copyright 2005 The MathWorks, Inc.

%% Access method used by timereset panel to get the timemetadata properties

thisTimeInfo = h.Timeseries.TimeInfo;
