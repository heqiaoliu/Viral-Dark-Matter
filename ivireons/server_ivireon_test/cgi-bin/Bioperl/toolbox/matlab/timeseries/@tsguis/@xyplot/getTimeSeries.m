function [ts, I] = getTimeSeries(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Extacts time series objects from the plot @Data as a cell array (if
%% no name is specified) or as a single @timeseries if a name is specified

I = [];
ts = [];
if ~isempty(h.Responses)
    if nargin ==1 % Get both time series in the datasrc
        ts = {h.Responses(1).DataSrc.Timeseries h.Responses(1).DataSrc.Timeseries2};
        I = [1 2];
    else % By name
        if numel(h.Responses.DataSrc.Timeseries) && ...
                any(strcmp(h.Responses(1).DataSrc.Timeseries.Name,varargin{1}))
            I = 1;
            ts = h.Responses.DataSrc.Timeseries;
        elseif numel(h.Responses.DataSrc.Timeseries2) && ...
                any(strcmp(h.Responses.DataSrc.Timeseries2.Name,varargin{1}))
            I = 1;
            ts = h.Responses(1).DataSrc.Timeseries2;
        end
    end
end