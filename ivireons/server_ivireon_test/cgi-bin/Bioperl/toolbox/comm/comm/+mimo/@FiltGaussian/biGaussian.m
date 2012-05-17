function biGaussian(h, i)
%biGaussian  Use biGaussian Doppler filter impulse response.
%
%   Inputs:
%     h - mimo.FiltGaussian object

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 05:54:52 $

% Use smallest sample period across all Doppler spectra
Ts = min(h.OutputSamplePeriod);
fc = h.CutoffFrequency(i);
fcmin = min(h.CutoffFrequency);
sigmaGaussian1      = h.DopplerSpectrum(i).SigmaGaussian1;
sigmaGaussian2      = h.DopplerSpectrum(i).SigmaGaussian2;
centerFreqGaussian1 = h.DopplerSpectrum(i).CenterFreqGaussian1;
centerFreqGaussian2 = h.DopplerSpectrum(i).CenterFreqGaussian2;
gainGaussian1       = h.DopplerSpectrum(i).GainGaussian1;
gainGaussian2       = h.DopplerSpectrum(i).GainGaussian2;
Noversampling = 1/(Ts*fc)/2;

% Time domain for filter response
tmax = 50/(2*pi*fcmin); % Use largest time domain across all Doppler spectra
t = -tmax:Ts:tmax;

% Set filter time domain and impulse response.
h.ImpulseResponse(i,:) = bigaussianir(fc, sigmaGaussian1, sigmaGaussian2, ...
    centerFreqGaussian1, centerFreqGaussian2, gainGaussian1, gainGaussian2,...
         Noversampling, t);
h.TimeDomain(i,:) = t;
