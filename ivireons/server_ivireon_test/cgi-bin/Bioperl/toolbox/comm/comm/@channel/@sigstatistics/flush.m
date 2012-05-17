function y = flush(h);
% Flush signal statistics object.
%
%   h  - Signal statistics object
%   y  - Buffer contents

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:20 $

% Overrides buffer flush method.

% Check number of arguments.
error(nargchk(1, 1, nargin,'struct'));
     
y = h.buffer_flush;

% Increment statistics count.
h.Count = h.Count + 1;

% Sampling period and sampling frequency of input signal.
Ts = h.SamplePeriod;
fs = 1/Ts;

% Currently uses only first channel for statistics.
Sig1 = y(:, 1);

% Autocorrelation
[AC1, h.Autocorrelation.Domain] = ...
    estimateAutocorrelation(Sig1, Ts, h.NumDelays);
h.Autocorrelation.Values = runningMean(...
    h.Autocorrelation.Values, AC1, h.Count);

% Power spectrum
[PS1, h.PowerSpectrum.Domain] = ...
    estimatePowerSpectrum(Sig1, fs, h.NumFrequencies);
h.PowerSpectrum.Values = runningMean(...
    h.PowerSpectrum.Values, PS1, h.Count);

% Other possible statistics:
%     Pz = abs(z).^2; % power of samples
%     meanPower = mean(Pz.')  % mean power
%     meanPower2 = fs*mean(SjEst)
%     % mean power based on estimated power spectrum

% Flag "statistics ready."
h.Ready = 1;

%--------------------------------------------------------------------------
function [ac, tdiff] = estimateAutocorrelation(z, Ts, Nt);
xcz = xcorr(real(z), Nt);
[maxx, idx] = max(xcz);
ac = xcz/maxx;
ac = ac(idx:idx+Nt-1);
tdiff = (0:Nt-1)*Ts;

%--------------------------------------------------------------------------
function [P, f] = estimatePowerSpectrum(z, fs, Nf, Nt);
% z: Complex fading process
% fs: Sampling frequency (Hz)
% Nf: Number of points for FFT (i.e., in frequency domain)
% P: Power spectrum
% f: Frequency domain
windowSize = 400;
%Alternative?: windowSize = min(1000, round(1/2*size(z,2)));
[Pw, fw] = pwelch(z.', hamming(windowSize), [], Nf, fs);
P = fftshift(Pw);
f = linspace(-fs/2, fs/2, length(P));

%--------------------------------------------------------------------------
function y = runningMean(y, x, N);
% y: Running mean.
% x: New data.
% N: Averaging index.
% This works only if N has incremented by 1 from last call.
y = 1/N * ((N-1)*y + x.');
