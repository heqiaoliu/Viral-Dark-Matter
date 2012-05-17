function status = isTimeseriesViewed(h,node)

% Copyright 2005 The MathWorks, Inc.

%% Search through all views to decide if the specified time series is
%% plotted

status = false;

%% Get the views and the time series under this node
allViews = h.Viewsnode.find('-isa','tsguis.viewnode');
allTsNodes = node.find('-isa','tsguis.tsnode','-depth',inf);
if ~isempty(allTsNodes)
    allTimeseries = get(allTsNodes,{'Timeseries'});
else
    return;
end

%% Are any os the time series in the views equal to any of the time series
%% unser this node
for k=1:length(allViews)
    theseTs = allViews(k).getTimeSeries;
    for j=1:length(theseTs)
        for ind=1:length(allTimeseries)
            if isequal(allTimeseries{ind},theseTs{j})
                status = true;
                return
            end
        end
    end
end
