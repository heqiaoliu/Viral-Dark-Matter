function [ts, I] = getTimeSeries(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Extacts time series objects from the plot @Data as a cell array (if
%% no name is specified) or as a single @timeseries if a name is specified

I = [];
ts = [];
if ~isempty(h.Responses)
    if nargin ==1 % Get both time series in the datasrc
        if ~isempty(h.Responses(1).DataSrc.Timeseries2) && ...
            ~isequal(h.Responses(1).DataSrc.Timeseries,h.Responses(1).DataSrc.Timeseries2)
            ts = {h.Responses(1).DataSrc.Timeseries h.Responses(1).DataSrc.Timeseries2};
        else
            ts = {h.Responses(1).DataSrc.Timeseries };
            I = 1;
        end
    else % By name
        if ~isempty(h.Responses.DataSrc.Timeseries) && ...
                strcmp(h.Responses(1).DataSrc.Timeseries.Name,varargin{1})
            I = 1;
            ts = h.Responses(1).DataSrc.Timeseries;
        elseif ~isempty(h.Responses.DataSrc.Timeseries2) && ...
                strcmp(h.Responses.DataSrc.Timeseries2.Name,varargin{1})
            I = 1;
            ts = h.Responses(1).DataSrc.Timeseries2;
        end
    end
end