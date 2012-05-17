function calcEyeSNR(this)
%CALCEYESNR Calculate the eye signal-to-noise ratio (SNR)
%   The eye SNR is defined as the ratio of EyeAmplitude to the sum of
%   eye level standard deviation values. 

%   @commscope/@eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:43 $

% Calculate (mean2-mean1)/(std2+std1)
noise = (this.PrivEyeLevelStd(:, 1:end-1) + this.PrivEyeLevelStd(:, 2:end));
this.EyeSNR = this.EyeAmplitude ./ noise;

%-------------------------------------------------------------------------------
% [EOF]
