function extentInterval = getExtent(h)

% Copyright 2005 The MathWorks, Inc.

%% Gets the full time interval (in the plot TimeUnits) occupied by all the
%% time series 

%% Default is [0 1]
if isempty(h.Waves)
    extentInterval = [0 1];
    return
end

extentInterval = [inf -inf];
for k=1:length(h.Waves)
    tinfo = h.Waves(k).DataSrc.Timeseries.TimeInfo;
    if strcmp(h.AbsoluteTime,'on') && ~isempty(h.StartDate) && ~isempty(tinfo.StartDate)
        abstimeshift = (datenum(tinfo.StartDate)-datenum(h.StartDate)) *...
            tsunitconv(h.TimeUnits,'days');
    else
        abstimeshift = 0;
    end
    
    newInterval = [tinfo.Start,tinfo.End];
    if length(newInterval)<2
        extentInterval = [0 1];
        return
    end
    newInterval = newInterval*...
        tsunitconv(h.TimeUnits,tinfo.Units)+...
        abstimeshift;
    extentInterval(1) = min(extentInterval(1),newInterval(1));
    extentInterval(2) = max(extentInterval(2),newInterval(2));
end

%% Prevent zero length intervals
if diff(extentInterval)<eps
    extentInterval = [extentInterval(1)-10*eps extentInterval(1)+10*eps];
end
        