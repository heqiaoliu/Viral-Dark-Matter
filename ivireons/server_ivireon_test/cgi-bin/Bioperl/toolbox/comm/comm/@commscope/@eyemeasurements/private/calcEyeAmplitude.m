function calcEyeAmplitude(this)
%CALCEYEAMPLITUDE Calculate the eye amplitude
%   Eye amplitude is the distance between two neighboring eye levels

%   @commscope/@eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:33 $

this.EyeAmplitude = diff(this.EyeLevel, [], 2);

%-------------------------------------------------------------------------------
% [EOF]
