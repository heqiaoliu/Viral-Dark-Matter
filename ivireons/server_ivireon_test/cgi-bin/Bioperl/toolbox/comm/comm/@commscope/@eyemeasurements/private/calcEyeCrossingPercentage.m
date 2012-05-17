function calcEyeCrossingPercentage(this)
%CALCEYECROSSINGPERCENTAGE Calculate the crossing percentage
%   Crossing percentage is the location of the reference crossing level as a
%   percentage of the eye amplitude. 

%   @commscope/@eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:35 $

% Calculate (CrossingAmplitude-EyeLevel(lower)) / EyeAmplitude
eyeLevels = this.EyeLevel;
this.EyeCrossingPercentage = 100 * ...
    (mean(this.EyeCrossingAmplitude, 2) - eyeLevels(:, 1:end-1)) ...
    ./ this.EyeAmplitude;

%-------------------------------------------------------------------------------
% [EOF]
