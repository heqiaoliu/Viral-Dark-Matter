function calcEyeDelay(this, Fs)
%CALCEYEDELAY Calculate the eye delay
%   Eye delay is the time offset of the eye center with respect to the origin of
%   the time axis.  FS is the sampling frequency.
%
%   This method assumes that the CrossingTime value is valid.

%   @commscope/@eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:37 $

% Get EyeCrossing times
xPoints = this.PrivCrossingTime;

% Calculate EyeDelay in samples
this.PrivEyeDelay = mean(xPoints, 2);

% Convert to seconds
this.EyeDelay = (this.PrivEyeDelay - 1) / Fs;

%-------------------------------------------------------------------------------
% [EOF]
