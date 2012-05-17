function newchannel(h, chan)
%NEWCHANNEL  Store new multipath channel data in multipath axes object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/09/14 15:58:13 $

% Note: newchannel in base class is not used.

% Delays of underlying multipath components
tz = chan.PathDelays;
h.PathDelays = tz;  
nDelays = length(tz);

% Gains (linear scale) of underlying multipath components
h.AvgPathGainVector = chan.AvgPathGainVector;

% Get previous channel data.
newData = h.NewChannelData;

% Rayleigh fading, filtered Gaussian source, and statistics objects
r = chan.RayleighFading;
fg = r.FiltGaussian;
nStats = length(fg.Statistics);

% Maximum Doppler shift
fd = r.MaxDopplerShift;
fc = r.CutoffFrequency;
newData.MaxDopplerShift = fd;
newData.CutoffFrequency = fc;

% Sampling frequency of Gaussian process and Doppler filter 
[fcmax, ifcmax] = max(fc);
fsDF = fcmax * fg.OversamplingFactor(ifcmax);

% Theoretical values.
theoryDomain = zeros(nDelays,length(fg.PowerSpectrum(1).Domain));
theoryVals = zeros(nDelays,length(fg.PowerSpectrum(1).Domain));
for i = 1:nDelays
    if nStats == 1
        % One PowerSpectrum object for all paths
        theoryDomain(i,:) = fg.PowerSpectrum.Domain;
        theoryVals(i,:) = fg.PowerSpectrum.Values * fsDF;
    else
        % One PowerSpectrum object per path
        theoryDomain(i,:) = fg.PowerSpectrum(i).Domain;
        theoryVals(i,:) = fg.PowerSpectrum(i).Values * fsDF;
    end
end

% Doppler spectrum domain.
newData.Frequencies = [theoryDomain; theoryDomain];

% Size of new data.
newSize = size(newData.Frequencies);

% Set FirstPlot flag if one of the following is true:
% (a) NewChannelData being loaded for the first time;
% (b) Haven't updated axes object yet (update will set FirstPlot to false);
% (c) New buffer size.
h.FirstPlot = ...
    isempty(h.NewChannelData) || ...
    h.FirstPlot || ...
    ~isequal(size(h.NewChannelData.SpectrumValues), newSize);

% Determine whether measurements are ready.  If so, MeasurementsToBePlotted
% is set to true.  Note that MeasurementsToBePlotted will retain the true
% value even if ready is false next time around.  The update method will
% set MeasurementsToBePlotted to false.
ready = fg.Statistics(1).Ready;
if (ready)
    newData.MeasurementsToBePlotted = true;
end

% If this is the first plot *and* there is no measured data to plot, want
% to plot *only* the theoretical curve.
if (h.FirstPlot && ~newData.MeasurementsToBePlotted)
    measDomain = zeros(nDelays,length(fg.Statistics(1).PowerSpectrum.Domain));
    measVals = zeros(nDelays,length(fg.Statistics(1).PowerSpectrum.Domain));
    for i = 1:nDelays
        if nStats == 1
            % One PowerSpectrum object for all paths
            measDomain(i,:) = fg.Statistics.PowerSpectrum.Domain;
            measVals(i,:) = fg.Statistics.PowerSpectrum.Values;
        else
            % One PowerSpectrum object per path
            measDomain(i,:) = fg.Statistics(i).PowerSpectrum.Domain;
            measVals(i,:) = fg.Statistics(i).PowerSpectrum.Values;
        end
    end
    if ~all(measVals)  % No measured data available.
        uNaN = NaN;
        measVals = uNaN(ones(size(theoryVals)));
    else
        checkdomains(theoryDomain, measDomain);
    end
    newData.SpectrumValues = [theoryVals; measVals];
end

% If new measurements are ready, assign to newData.
if (ready)
    for i = 1:nDelays
        if nStats == 1
            % One PowerSpectrum object for all paths
            measDomain(i,:) = fg.Statistics.PowerSpectrum.Domain;
            measVals(i,:) = fg.Statistics.PowerSpectrum.Values;
        else
            % One PowerSpectrum object per path
            measDomain(i,:) = fg.Statistics(i).PowerSpectrum.Domain;
            measVals(i,:) = fg.Statistics(i).PowerSpectrum.Values;            
        end
    end
    checkdomains(theoryDomain, measDomain);
    newData.SpectrumValues = [theoryVals; measVals];
end

% Note: Old channel data property not used.

h.NewChannelData = newData;

%--------------------------------------------------------------------------
function checkdomains(td, md)
if ( ~isequal(size(md), size(td)) || any(any(abs(md-td) > repmat(max(td,[],2)/1e6,1,size(td,2)) )))
    error('comm:channel:mpscatteraxes:SameDomainRqd',['Domains of theoretical and measured Doppler spectra ' ...
            'must be the same.']);
end
