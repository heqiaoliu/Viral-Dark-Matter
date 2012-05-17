function ajakes(h, i)
%AJAKES  Use ajakes Doppler filter impulse response.
%
%   Inputs:
%     h - channel.filtgaussian object

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:00:46 $

% Use smallest sample period across all Doppler spectra
Ts = min(h.OutputSamplePeriod);
fc = h.CutoffFrequency(i);
fcmin = min(h.CutoffFrequency);
freqMinMax = h.DopplerSpectrum(i).FreqMinMaxAJakes;
Noversampling = 1/(Ts*fc)/2;

% Time domain for filter response
tmax = 50/(2*pi*fcmin); % Use largest time domain across all Doppler spectra
t = -tmax:Ts:tmax;

% Set filter time domain and impulse response.
h.ImpulseResponse(i,:) = ajakesir(fc, freqMinMax, Noversampling, t);
h.TimeDomain(i,:) = t;