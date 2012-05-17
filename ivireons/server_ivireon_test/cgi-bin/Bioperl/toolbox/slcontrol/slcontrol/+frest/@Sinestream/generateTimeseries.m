function out = generateTimeseries(obj)
% GENERATETIMESERIES Generate MATLAB timeseries for the specified
% sinestream input signal
%
%   insig = generateTimeseries(in) generates the MATLAB timeseries object
%   which captures the actual data corresponding to the specified
%   sinestream input signal in.
%
%   See also frestimate, frest.Sinestream

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2009/11/09 16:35:05 $

% Start by computing the periods,sample times and final times
T = 1./unitconv(obj.Frequency,obj.FreqUnits,'Hz');
ts = T./obj.SamplesPerPeriod;
% Individual final times (time for each frequency starts from zero
tfinals = (obj.NumPeriods+obj.RampPeriods).*T-ts;
ts = ts(:);tfinals = tfinals(:);
ti = cumsum([0;tfinals(1:end-1)] + [0;ts(1:end-1)]);
% Preallocate time & data
datalens = (obj.NumPeriods+obj.RampPeriods).*obj.SamplesPerPeriod;
% Handle if NumPeriods,RampPeriods,SamplesPerPeriod are all scalars
if isscalar(datalens)
    datalens = datalens*ones(size(obj.Frequency));
end
datalens = datalens(:);
time = zeros(1,sum(datalens));
data = zeros(size(time));
% Calculate start and end indices when placing time and data in the loop
start_ind = cumsum([1;datalens(1:end-1)]);
end_ind = start_ind+datalens-1;
% Scalar expand amplitudes,rampPeriods as we will operate on
% individual elements of these parameters.
if isscalar(obj.Amplitude)
    obj.Amplitude_ = obj.Amplitude*ones(size(obj.Frequency));
end
if isscalar(obj.RampPeriods)
    obj.RampPeriods_ = obj.RampPeriods*ones(size(obj.Frequency));
end
for ct = 1:length(obj.Frequency)
    y = obj.Amplitude(ct)*sin(unitconv(obj.Frequency(ct),obj.FreqUnits,'rad/s')*(0:ts(ct):tfinals(ct)));
    if (obj.RampPeriods(ct) == 0)
        data(start_ind(ct):end_ind(ct)) = y;
    else
        % Account for ramping
        data(start_ind(ct):end_ind(ct)) = min(1,(0:ts(ct):tfinals(ct))*...
            (unitconv(obj.Frequency(ct),obj.FreqUnits,'Hz'))./obj.RampPeriods(ct)).*y;        
    end
    % Write the time
    time(start_ind(ct):end_ind(ct)) = ti(ct)+(0:ts(ct):tfinals(ct));
end
% Wrap up in a time series object
out = timeseries(data(:),time);
out.Name = ctrlMsgUtils.message('Slcontrol:frest:TimeseriesName','Sinestream');
out.DataInfo.Interpolation.Name = 'Zero-order hold';
end

