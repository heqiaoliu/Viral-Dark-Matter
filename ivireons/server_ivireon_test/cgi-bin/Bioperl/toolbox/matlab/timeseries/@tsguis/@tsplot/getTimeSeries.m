function [ts, I] = getTimeSeries(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Extacts time series objects from the timeplot @Data as a cell array (if
%% no name is specified) or as a single @timeseries if a name is specified

I = [];
if isempty(h.Waves)
    ts  = {};
    return
end
srcList = cell2mat(get(h.Waves,{'DataSrc'}));
tsList = get(srcList,{'Timeseries'});

if nargin ==1 % Get all time series
    ts = {};
    for k = 1:length(h.Waves)
        if numel(tsList{k})>0
           ts = [ts; {tsList{k}}];
           I = [I; k];
        end
    end
else % Get time series by name
    ts = [];
    for k = 1:length(h.Waves)
        if numel(tsList{k})>0 && ...
                any(strcmp(tsList{k}.Name,varargin{1}))
           ts = tsList{k};
           I = k;
           break
        end
    end
end