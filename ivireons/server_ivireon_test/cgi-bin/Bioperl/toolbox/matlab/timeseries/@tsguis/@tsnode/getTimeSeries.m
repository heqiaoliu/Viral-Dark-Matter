function tsList = getTimeSeries(h,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

%% Interface method to get the list of @timeseries to be plotted. For
%% @tsnode this is always the single @timeseries represented by this node
if nargin == 2
    tsList = h.Timeseries;
else
    tsList = get(h,{'Timeseries'});
end
