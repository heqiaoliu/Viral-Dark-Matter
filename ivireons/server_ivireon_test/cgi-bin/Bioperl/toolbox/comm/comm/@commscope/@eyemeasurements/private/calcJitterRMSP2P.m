function calcJitterRMSP2P(this, horHistI, horHistQ, Fs)
%CALCJITTERRMSP2P Calculate the RMS and peak-to-peak jitter values.

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/12 21:23:39 $

% Adjust the histogram so that the eye opening is in the middle
refAmpIdx = (size(horHistI, 1)+1)/2;
midPoint = this.EyeDelay*Fs;
histLen = size(horHistI, 2);

% Calculate for in-phsae signal
[jitterRMS(1,1) jitterP2P(1,1)] = ...
    rmsP2PJitter(horHistI(refAmpIdx, :), histLen, midPoint(1,1));

% If required, calculate for the quadrature signal
if ~isempty(horHistQ)
    [jitterRMS(2,1) jitterP2P(2,1)] = ...
        rmsP2PJitter(horHistQ(refAmpIdx, :), histLen, midPoint(2,1));
end

this.JitterRMS = jitterRMS / Fs;
this.JitterPeakToPeak = jitterP2P / Fs;

%-------------------------------------------------------------------------------
function [jitterRMS jitterP2P] = rmsP2PJitter(horHistI, histLen, midPoint)
histLen2 = histLen/2;

histI = circshift(horHistI, [0 round(histLen2-midPoint)]);

% Calculate the RMS jitter
idx1 = 1:histLen2;
histI1 = histI(idx1)/sum(histI(idx1));
rms1 = sqrt(sum(histI1.*idx1.^2) - sum(histI1.*idx1)^2);
idx2 = histLen2+1:histLen;
histI2 = histI(histLen2+1:end)/sum(histI(histLen2+1:end));
rms2 = sqrt(sum(histI2.*idx2.^2) - sum(histI2.*idx2)^2);
jitterRMS =  (rms1 + rms2)/2;

% Calculate peak-to-peak jitter
idx = find(histI > 0);
peak2PeakL = max(idx(idx < histLen2)) - min(idx(idx < histLen2));
peak2PeakR = max(idx(idx < histLen2)) - min(idx(idx < histLen2));
jitterP2P = max(peak2PeakL, peak2PeakR);

%-------------------------------------------------------------------------------
% [EOF]
