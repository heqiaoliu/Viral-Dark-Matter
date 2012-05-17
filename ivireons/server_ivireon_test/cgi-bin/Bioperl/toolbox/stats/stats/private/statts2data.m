function [data,ts,samples] = statts2data(ts)
%STATTS2DATA Convert timeseries to raw data and times.
%   DATA is the data suitable for computing row statistics, TS is the
%   timeseries or empty, and SAMPLES is the x axis variable.  Used by
%   control chart functions.

% Copyright 2005 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:32 $

if ~isa(ts,'timeseries')
    % If the input is not a time series, return it unchanged
    data = ts;
    samples = (1:size(data,1))';
    ts = [];
else
    % Extract data from time series, make sure the time dimension is the
    % leading dimension, and combine all other dimensions
    data = ts.data;
    if ~ts.IsTimeFirst
        data = permute(data,[ndims(data),(1:ndims(data)-1)]);
    end
    if ndims(data)>2
        sz = size(data);
        data = reshape(data,sz(1),prod(sz(2:end)));
    end

    % Now get time as numbers, and if possible as a cell array of strings
    if isempty(ts.TimeInfo.StartDate)
        samples = ts.Time;
    else
        samples = datenum(getabstime(ts));
    end
end

    