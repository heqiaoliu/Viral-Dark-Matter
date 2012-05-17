function propout = setTs(h,eventData)

% Copyright 2004-2005 The MathWorks, Inc.

if ~isempty(h.Timeseries) && ishandle(h.Timeseries)
   h.Timeseries.TimeInfo.Increment = eventData;
end
propout = [];
