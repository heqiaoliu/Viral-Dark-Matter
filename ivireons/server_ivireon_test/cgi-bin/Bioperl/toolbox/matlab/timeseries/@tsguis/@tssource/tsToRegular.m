function [data,Ts,varargout] = tsToRegular(src)

% Copyright 2005-2007 The MathWorks, Inc.

%% Resamples a time series on a unform time vector with the same start and
%% end times and the same number of observations. Also removes NaNs. Used
%% by periodogram to obtain a power spec

%% If there are two time series they must be sampled at the same times
twotimeseries = false;
if numel(src.Timeseries2)>=1 && (src.Timeseries2~=src.Timeseries)
    if src.Timeseries.TimeInfo.Length~=src.Timeseries2.TimeInfo.Length
        error('tssource:tsToRegular:mismatchLengths',...
            'Two time series must have the same lengths.')
    else
        twotimeseries = true;
    end
end

%% Deal with scalars
if src.TimeSeries.TimeInfo.Length==1
    data = src.TimeSeries.Data;
    if twotimeseries
        varargout{1} = src.TimeSeries2.Data;
    end
    Ts = 1;
    return
end

%% Deal with non-scalars
if twotimeseries
    [data,Ts,data2,Ts2] = localInterpolate2(src.Timeseries,src.Timeseries2);
    varargout{1} = data2;
    varargout{2} = Ts2;
else
   [data, Ts] = localInterpolate(src.TimeSeries);
end
       
                
function [data,Ts] = localInterpolate(ts)

%% Interpolate the time series on a uniform time vector to remove any NaNs

if isempty(ts)
    data = [];
    Ts = [];
    return
end

%% Trim start and end NaNs
[startInd,endInd] = utTrimNans(ts);

time = ts.Time(startInd:endInd);
tuniform = linspace(time(1),time(end),length(time));

%% Note: Do not use resample to perform the interpolation since this
%% function may be recalled using transactions which cannot reverse time
%% series construction
data = ts.dataInfo.Interpolation.interpolate(...
    ts.time,ts.data,tuniform(:));
Ts = tuniform(2)-tuniform(1);

function [data1,Ts1,data2,Ts2] = localInterpolate2(ts1,ts2)

%% Interpolate a pair of time series on uniform time vector to remove any NaNs

%% Trim start and end NaNs
[startInd,endInd] = utTrimNans({ts1,ts2});

%% Get the uniform time vectors
time1 = ts1.Time(startInd:endInd);
tuniform1 = linspace(time1(1),time1(end),length(time1));
time2 = ts2.Time(startInd:endInd);
tuniform2 = linspace(time2(1),time2(end),length(time2));

%% Note: Do not use resample to perform the interpolation since this
%% function may be recalled using transactions which cannot reverse time
%% series construction
data1 = ts1.dataInfo.Interpolation.interpolate(ts1.time,ts1.data,tuniform1(:));
Ts1 = tuniform1(2)-tuniform1(1);
data2 = ts2.dataInfo.Interpolation.interpolate(ts2.time,ts2.data,tuniform2(:));
Ts2 = tuniform2(2)-tuniform2(1);

