function updateHorHist(this, y, horRef, hysteresis)
%UPDATEHORHIST Update the horizontal histogram entries
%   UPDATEHORHIST(THIS, Y, HORREF, HYSTERESIS) updates the horizontal histogram 
%   entries based on the input Y, horizontal reference HORREF and HYSTERESIS.
%   HORREF values are the crossing levels that we use to calculate the
%   crossing times.  HYSTERESIS is used to create a guard band that is used to
%   avoid multiple level crossings due to noise.  The crossing time is
%   calculated by linear interpolation around a level crossing using a point
%   just above the guard band and a point just below the guard band.

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:19:14 $

% Get parameters
period = this.PrivPeriod;
horBins = this.PrivHorBinEdges;
L = length(horBins);
horHistRe = this.PrivHorHistRe;
horHistIm = this.PrivHorHistIm;

% Get history
lastSampRe = this.PrivLastValidSampleRe;
lastSampIdxRe = this.PrivLastValidSampleIdxRe;
lastSampIm = this.PrivLastValidSampleIm;
lastSampIdxIm = this.PrivLastValidSampleIdxIm;

% Update horizontal histograms
numRef = size(horRef, 2);

% Remove NaNs
y = y(~isnan(y));

% For each reference level normalize so that crossing point is zero and compute
% histogram
for p=1:numRef
    % Find the crossing times of the in-phase signal.  Normalize the
    % input signal so that the crossings will occur at level zero.
    [crossTime lastSampRe(p) lastSampIdxRe(p)] = ...
        findCrossingTimes(real(y) - horRef(1, p), ...
        lastSampRe(p), lastSampIdxRe(p), hysteresis);

    % Update the horizontal histogram of the in-phase signal
    data = histc(mod(crossTime+this.PrivLastSampleIndex, period)', horBins, 2);
    % Since bins are from -0.5:1:period-0.5, we need to add the last bin's
    % values to the first bin.
    data(1) = data(1) + data(L);
    horHistRe(p, :) = horHistRe(p, :) + data(1:L-1);

    % If the operation mode is "Complex Signal"
    if ( this.PrivOperationMode )
        % Find the crossing times of the quadrature signal.  Normalize the
        % input signal so that the crossings will occur at level zero.
        [crossTime lastSampIm(p) lastSampIdxIm(p)] = ...
            findCrossingTimes(imag(y) - horRef(2, p), ...
            lastSampIm(p), lastSampIdxIm(p), hysteresis);

        % Update the horizontal histogram of the quadrature signal
        data = histc(mod(crossTime+this.PrivLastSampleIndex, period)', horBins, 2);
        % Since bins are from -0.5:1:period-0.5, we need to add the last bin's
        % values to the first bin.
        data(1) = data(1) + data(L);
        horHistIm(p, :) = horHistIm(p, :) + data(1:L-1);
    end
end

this.PrivHorHistRe = horHistRe;
this.PrivHorHistIm = horHistIm;

% Store history
this.PrivLastValidSampleRe = lastSampRe;
this.PrivLastValidSampleIdxRe = lastSampIdxRe;
this.PrivLastValidSampleIm = lastSampIm;
this.PrivLastValidSampleIdxIm = lastSampIdxIm;

%-------------------------------------------------------------------------------
function [crossTime lastSamp lastSampIdx] = findCrossingTimes(yNorm, ...
    lastSamp, lastSampIdx, hysteresis)

% Generate a vector that represents the sign of the data if it is outside of
% the guardband created by the hysteresis and zero if it is inside the
% guardband.
yNorm((yNorm<hysteresis) & (yNorm>-hysteresis)) = 0;
signInfo = sign(yNorm);

% Find the index of all the points outside of the guardband
idx = find(signInfo);

if ~isempty(idx)

    % Find the crossing points such that the input signal crosses from one side
    % of the guard band to the other side.
    crossPoint = find(diff(signInfo(idx)));
    idx1 = idx(crossPoint);     % Valid data index before crossing
    idx2 = idx(crossPoint+1);	% Valid data index after crossing
    y1 = yNorm(idx1);               % Get the signal value at idx1
    y2 = yNorm(idx2);               % Get the signal value at idx2

    % Find the crossing time using linear interpolation.
    crossTime = ((idx1 - y1.*(idx2-idx1)./(y2-y1))-1);

    % Also check if there was a transition from last frame to this frame
    dummy = [lastSamp yNorm(idx(1))];
    signInfo = (dummy>hysteresis) - (dummy<-hysteresis);
    if diff(signInfo(signInfo~=0))
        crossTimeFirst = ((lastSampIdx - lastSamp.*(idx(1)-lastSampIdx)...
            ./(yNorm(idx(1))-lastSamp))-1);
    else
        crossTimeFirst = [];
    end

    % Update crossing times
    crossTime = [crossTimeFirst; crossTime];

    % Store history
    lastSampIdx = idx(end) - length(yNorm);
    lastSamp = yNorm(idx(end));     % last symbol which may result in a
                                    % qualified crossing point
else
    crossTime = NaN;
end


%-------------------------------------------------------------------------------
% [EOF]
