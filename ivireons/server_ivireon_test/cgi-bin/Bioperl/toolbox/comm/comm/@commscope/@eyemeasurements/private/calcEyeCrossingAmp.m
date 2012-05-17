function calcEyeCrossingAmp(this, verHistI, verHistQ, minAmp, ampRes)
%CALCEYECROSSINGAMP Calculates the crossing amplitudes of the eye diagram
%   CALCEYECROSSING(H, VERHISTI, VERHISTQ, MINAMP, AMPRES) calculates the
%   crossing amplitudes on both the in-phase and quadrature components of the
%   signal.  VERHISTI and VERHISTQ are the horizontal histograms of the level
%   crossing points for in-phase and quadrature signals, respectively.  MINAMP
%   is the minimum amplitude captured in the vertical histogram.  AMPRES is the
%   amplitude resolution of the vertical histogram.
%
%   CALCEYECROSSING(H, VERRHISTI, [], MINAMP, AMPRES)
%   calculates crossing amplitude on only the in-phase component of the signal.
%
%   This method assumes that the CrossingTime value has been calculated.

%   @commscope/@eyemeaurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:34 $

% Clear previous measurements
this.PrivCrossingAmp = [];

% Calculate eye crossing amplitude for in-phase signal
y = verHistI(:, round(this.PrivCrossingTime(1, :)));
x = 1:length(y);
this.PrivCrossingAmp(1, :) = (x*y) ./ sum(y);

% Calculate eye crossing amplitude for quadrature signal
if ~isempty(verHistQ)
    y = verHistQ(:, round(this.PrivCrossingTime(2, :)));
    x = 1:length(y);
    this.PrivCrossingAmp(2, :) = (x*y) ./ sum(y);
end

% Convert to amplitude
this.EyeCrossingAmplitude = ...
    (this.PrivCrossingAmp-1) * ampRes + minAmp;

%-------------------------------------------------------------------------------
% [EOF]
