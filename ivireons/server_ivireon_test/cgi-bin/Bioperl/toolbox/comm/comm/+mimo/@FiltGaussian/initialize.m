function initialize(h)
%INITIALIZE  Initialize filtered Gaussian source object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:54:57 $

fc = h.CutoffFrequency;

if fc>0
    
    [fcmax, ifcmax] = max(fc);
    fcmin = min(fc);
    
    % Use minimum sampling period across all Doppler spectra. It
    % corresponds to the largest cutoff frequency.
    Ts = h.OutputSamplePeriod(ifcmax); 
    % Or: Ts = max(h.OutputSamplePeriod);
    
    % Set impulse response.
    h.LockImpulseResponse = 0;
    % Force all impulse responses to be of equal length.
    % TimeDomain should span the largest time domain across all Doppler
    % spectra.
    fcLen = length(fc);
    hLen = length( -50/(2*pi*fcmin):Ts:50/(2*pi*fcmin) );
    h.ImpulseResponse = zeros(fcLen, hLen);
    h.TimeDomain = zeros(fcLen, hLen);
    for i_chan = 1:fcLen
        IRFcn = h.ImpulseResponseFcn{i_chan};
        IRFcn(h,i_chan);
    end
    h.LockImpulseResponse = 1;
   
    pd = h.PrivateData;  % Use PrivateData for speed
    
    % Calculate autocorrelation and power spectrum.
    Sj = zeros(fcLen, pd.NumFrequencies);
    f = zeros(fcLen, pd.NumFrequencies);
    for i_chan = 1:fcLen
        [ac(i_chan,:), tdiff(i_chan,:), Sj(i_chan,:), f(i_chan,:)] = ...
            filterACandPS(pd.ImpulseResponse(i_chan,:), pd.TimeDomain(i_chan,:), pd.NumFrequencies);
    end
    
    % (Re)-create autocorrelation and power spectrum objects.
    for i_chan = 1:length(fc)
        tempAutocorrelation(i_chan) = mimo.SigResponse; %#ok<AGROW>
        tempPowerSpectrum(i_chan) = mimo.SigResponse;
    end    
    h.Autocorrelation = copy(tempAutocorrelation);
    h.PowerSpectrum = copy(tempAutocorrelation);
    
    % Initialize Autocorrelation and PowerSpectrum objects.
    for i_chan = 1:length(fc)
        h.Autocorrelation(i_chan).Values = ac(i_chan,:);
        h.Autocorrelation(i_chan).Domain = tdiff(i_chan,:);
        h.PowerSpectrum(i_chan).Values = Sj(i_chan,:);
        h.PowerSpectrum(i_chan).Domain = f(i_chan,:);
    end

    % Save current enable status.
    oldEnable = zeros(1, fcLen);
    for i_chan = 1:length(h.Statistics)  
        oldEnable(i_chan) = h.Statistics(i_chan).Enable; 
    end    
        
    % (Re)-create Statistics objects.
    defaultStatsLength = 1000;
    defaultNF = pd.NumFrequencies;  % Number of frequencies.
    for i_chan = 1:length(fc)
        tempStatistics(i_chan) = mimo.SigStatistics(Ts, defaultStatsLength, 1, defaultNF); %#ok<AGROW>
    end    
    h.Statistics = copy(tempStatistics);
    % If there was previously one SigStatistics object per channel, each
    % SigStatistics had only one channel. If this is changed for one
    % SigStatistics object for all channels, then the Sigstatistics object
    % must be updated to have NumChannels channels.
    if length(h.Statistics)==1    
        h.Statistics.NumChannels = pd.NumChannels;   
    end

    % Initialize Statistics property.
    for i_chan = 1:length(fc)
        h.Statistics(i_chan).NumDelays = length(tdiff(i_chan,:));
        if isscalar(oldEnable)
            h.Statistics(i_chan).Enable = oldEnable;
        else    
            h.Statistics(i_chan).Enable = oldEnable(1);  % Set to previous enable status.
        end    
    end
        
else
    % Note: If fc==0, SigResponse objects are not set.
    
    % Set filter time domain and impulse response.
    h.LockImpulseResponse = 0;
    h.ImpulseResponse = zeros(length(fc), 1);
    h.TimeDomain = zeros(length(fc), 1);
    h.LockImpulseResponse = 1;
    
    % Initialize SigResponse objects.
    for i_chan = 1:length(fc)
        tempAutocorrelation(i_chan) = mimo.SigResponse; %#ok<AGROW>
        tempPowerSpectrum(i_chan) = mimo.SigResponse;
    end    
    h.Autocorrelation = copy(tempAutocorrelation);
    h.PowerSpectrum = copy(tempAutocorrelation);
    
    % Initialize Statistics property.
    for i_chan = 1:length(fc)
        tempStatistics(i_chan) = mimo.SigStatistics; %#ok<AGROW>
    end    
    h.Statistics = copy(tempStatistics);

end

% Reset filtered gaussian source object (superclass).
h.reset;

%--------------------------------------------------------------------------
function [ac, tdiff, Sj, f] = filterACandPS(h, t, Nf)
% Compute autocorrelation and power spectrum of filter.
%     h: Normalized filter impulse response
%     t: Time domain vector (s)
%    ac: Autocorrelation function.
% tdiff: Time domain for autocorrelation function.
%    Sj: Power spectrum.
%     f: Frequency domain.

% Time and frequency domain parameters.
% Assumes that t has uniformly spaced elements.
dt = t(2)-t(1);
tmax = t(end);
fs = 1/dt;
f = linspace(-fs/2, fs/2, Nf);

% Doppler spectrum, based on Doppler filter.
Sj = fftshift(abs(dt*fft(h, Nf)).^2);

% Autocorrelation function.
tdiff = 0:dt:tmax-dt;
Ltdiff = length(tdiff);
% Shorten time domain for autocorrelation if it is too large
if Ltdiff>Nf 
    Ltdiff = Nf;
    tdiff = 0:dt:Ltdiff*dt-dt;
end    
h2 = ifft(fftshift(Sj))./(dt^2);  % Expected, based on filter response.
ac = real(h2(1:Ltdiff));
