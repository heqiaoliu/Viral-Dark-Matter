function calcEyeLevel(this, verHistI, verHistQ, ...
    minAmp, ampRes, eyeLevelBoundary, refAmp)
%CALCEYELEVEL Calculate the eye levels
%   Eye levels are the distinct amplitude values of the constellation and are
%   measured around the EyeDelay.  The eye levels are assumed to be divided by
%   the boundaries defined by REFAMP.
%
%   This method assumes that the EyeDelay value has been calculated.

%   @commscope/@eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/01/10 21:08:36 $

% Clear previous measurements
this.PrivEyeLevel = [];
this.PrivEyeLevelStd = [];

% Convert percent eye level boundaries to numbers
eyeLevelBoundary = eyeLevelBoundary / 100;

% Calculate the eye level masurement band
symbolTime = diff(this.PrivCrossingTime, [], 2);
bandMin = floor(this.PrivEyeDelay - (symbolTime * (0.5 - eyeLevelBoundary(1))));
bandMax = ceil(this.PrivEyeDelay - (symbolTime * (0.5 - eyeLevelBoundary(2))));
band = bandMin:bandMax;

% Calculate reference amplitude indices
refAmp = round((refAmp - minAmp) / ampRes);

% Determine eye levels for the in-phase signal
[this.PrivEyeLevel(1,:) this.PrivEyeLevelStd(1,:) this.PrivEyeLevelN(1,:)] = ...
    findLevels(verHistI(:, band), refAmp(1,:));

% Determine eye levels for the quadrature signal
if ( ~isempty(verHistQ) )
    [this.PrivEyeLevel(2,:) this.PrivEyeLevelStd(2,:) ...
        this.PrivEyeLevelN(2,:)] = ...
        findLevels(verHistQ(:, band), refAmp(2,:));
end

% Calculate amplitude values
this.EyeLevel = (this.PrivEyeLevel-1) * ampRes + minAmp;
this.PrivEyeLevelStd = this.PrivEyeLevelStd * ampRes;

%-------------------------------------------------------------------------------
function [levels stdValues numSamps] = findLevels(levelPdf, refAmp)
% Find eye levels that are separated by the boundaries defined by refAmp

% Take the mean value of the pdfs
levelPdf = mean(levelPdf, 2);

% Calculate slots
slots = [1; refAmp; length(levelPdf)];

% Calculate mean value of the levels
numSamps = zeros(length(slots)-1, 1);
levels = zeros(length(slots)-1, 1);
stdValues = zeros(length(slots)-1, 1);
for p=1:length(slots)-1
    y = levelPdf(slots(p):slots(p+1));
    x = slots(p):slots(p+1);
    numSamps(p) = sum(y);
    y = y / numSamps(p);
    levels(p) = x*y;
    stdValues(p) = sqrt(((x.^2)*y) - levels(p)^2);
end

%-------------------------------------------------------------------------------
% [EOF]
