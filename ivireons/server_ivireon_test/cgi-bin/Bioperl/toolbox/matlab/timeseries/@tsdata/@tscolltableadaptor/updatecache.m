function updatecache(h,row,varargin)

% Copyright 2006-2009 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;

% Refresh the table cache for the tscollection for a group of rows which
% includes the input argument row.
 
% Get timeseries data and params
thisTsColl = h.Timeseries;
absTimeFlag = ~isempty(thisTsColl.TimeInfo.StartDate);

% Calculate cache params
if row>thisTsColl.TimeInfo.Length
    row = 0;
end
cacheStart = max(row-100,0);
cacheLength = min(thisTsColl.TimeInfo.Length-cacheStart,200);

% Find times,row numbers,events,and event times within the cache range
tableTimes  = thisTsColl.Time;
tableTimes = tableTimes(cacheStart+1:cacheStart+cacheLength);

% Create the new cache
thisCache = TimeSeriesArrayEditorTableCache(cacheStart,cacheLength,0,0);

% Evaluate repeaded access variables
if absTimeFlag
    dayConvFactor = tsunitconv('days',thisTsColl.TimeInfo.Units);
    dayOffset = datenum(thisTsColl.TimeInfo.StartDate);
end

% Add data to the cache within its range
format = 0;
if absTimeFlag && tsIsDateFormat(thisTsColl.timeInfo.Format)
    format = thisTsColl.timeInfo.Format;
end   
for row=1:cacheLength
    if absTimeFlag
        thisCache.addTimedData(cacheStart+row,...
            datestr(dayOffset+dayConvFactor*tableTimes(row),format),...
            [],[]);   
    else
         thisCache.addTimedData(cacheStart+row,...
            tableTimes(row),[],[]);                  
    end
end

% Update the table model
thisCache.numTableRows = thisTsColl.length;
thisCache.numTableColumns = 1;
h.TableModel.setCache(thisCache);
