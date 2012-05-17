function [e,ts] = getevents(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Create a sorted list of all events (and their parent timeseries)
%% in the view 

%% Get the events for all time series in the view
e = [];
ts = {};
convertedEventTime = [];
if ~isempty(h.Plot) && ishandle(h.Plot)
    tslist = h.Plot.getTimeSeries;
    for k=1:length(tslist)
        newEvents = tslist{k}.Events(:);
        e = [e(:); newEvents];
        ts = [ts; repmat(tslist(k),length(newEvents),1)];
        for j=1:length(tslist{k}.Events(:))
           convertedEventTime = [convertedEventTime; ...
               tslist{k}.Events(j).Time*tsunitconv(h.Plot.TimeUnits,tslist{k}.TimeInfo.Units)];
        end
    end
end

%% Sort events in time
[junk,I] = sort(convertedEventTime);
e = e(I);
ts = ts(I);
    