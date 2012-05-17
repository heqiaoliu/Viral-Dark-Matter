function calcEyeRiseFallTime(this, horHistI, horHistQ, nSym, Fs)
%CALCEYERISEFALLTIME Calculates rise and fall times of the eye diagram
%   CALCEYERISEFALLTIME(H, HORHISTI, HORHISTQ, NSYM, FS)
%   calculates crossing times on both the in-phase and quadrature components of
%   the signal.  HORHISTI and HORHISTQ are the horizontal histogram if level
%   crossing points for in-phase and quadrature signals.  NSYM is the number of
%   symbols in a single trace of the eye diagram.  FS is the sampling frequency
%   of the signal.
%
%   CALCEYECROSSING(H, HORHISTI, [], NSYM, FS)
%   calculates crossing times on only the in-phase component of the signal.

%   @commscope/@eyemeaurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/11 15:38:13 $

if ~isempty(horHistI)
    
    midPoint = this.PrivEyeDelay;
    
    [eyeRiseTime(1,1) eyeFallTime(1,1)] = ...
        calcRiseFallTimes(this, horHistI, nSym*2, midPoint(1,1));
    
    if ~isempty(horHistQ)
        [eyeRiseTime(2,1) eyeFallTime(2,1)] = ...
            calcRiseFallTimes(this, horHistQ, nSym*2, midPoint(2,1));
    end
    
    % Convert to seconds
    this.EyeRiseTime = eyeRiseTime / Fs;
    this.EyeFallTime = eyeFallTime / Fs;
else
    error([this.getErrorId ':EyeLevelNotStable'], ['Eye level measurements '...
        'are not stable.  Cannot determine rise and fall times.  Provide '...
        'more data to stabilize eye level measurements.']);
end

%-------------------------------------------------------------------------------
function [riseTime fallTime] = calcRiseFallTimes(this, crossingPdf, ...
    numCrossingPoints, midPoint)

% Determine each crossing time for the quadrature signal for high and low
% boundaries
crossTimesHigh = findCrossingTimes(crossingPdf(1,:), numCrossingPoints,...
    midPoint);
crossTimesLow = findCrossingTimes(crossingPdf(2,:), numCrossingPoints, ...
    midPoint);

% Calculate rise and fall times
rise(1,1) = crossTimesHigh(2) - crossTimesLow(1);
rise(1,2) = crossTimesHigh(4) - crossTimesLow(3);
fall(1,1) = crossTimesLow(2) - crossTimesHigh(1);
fall(1,2) = crossTimesLow(4) - crossTimesHigh(3);

if any(isnan(rise))
    warning([this.getErrorId ':LHTransitionNotFound'], ['At least one low '...
        'to high transition cannot be found.\nMeasurements may not be ' ...
        'accurate.']);
    rise(isnan(rise)) = [];
end
riseTime = mean(rise);
if any(isnan(fall))
    warning([this.getErrorId ':HLTransitionNotFound'], ['At least one high '...
        'to low transition cannot be found.\nMeasurements may not be ' ...
        'accurate.']);
    fall(isnan(fall)) = [];
end
fallTime = mean(fall);

%-------------------------------------------------------------------------------
function crossingTime = findCrossingTimes(crossingPdf, ...
    numCrossingPoints, midPoint)

% Initialize.  Since we already know the eye delay, we can start without looking
% for course peaks.
crossingPdfLen = size(crossingPdf, 2);
slotLen = crossingPdfLen/numCrossingPoints;
slot = reshape(1:crossingPdfLen, slotLen, numCrossingPoints)';
crossingTime = zeros(numCrossingPoints, 1);

offset = round(crossingPdfLen/2 - midPoint);

% Add offset to make the first slot full size and take the mean value of the
% pdfs
crossingPdf = circshift(crossingPdf, [0 offset]);

% Calculate fine crossingPoints
for p=1:numCrossingPoints
    y = crossingPdf(slot(p,:));
    x = slot(p,:);
    crossingTime(p, 1) = (x*y')/sum(y);
end;

%-------------------------------------------------------------------------------
% [EOF]
