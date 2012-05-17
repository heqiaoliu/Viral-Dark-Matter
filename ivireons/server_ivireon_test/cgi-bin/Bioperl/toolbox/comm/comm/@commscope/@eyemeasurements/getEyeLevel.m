function getEyeLevel(this, eyeDiagram)
%GETEYELEVEL Calculate the eye level and determine is stable
%   GETEYELEVEL(THIS, EYEDIAGRAM) calculates eye crossing times and eye levels.
%   These eye level values are used to determine reference amplitude levels for
%   rise and fall time measurements.  This method also determines if the eye
%   levels are stable.

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/23 13:57:29 $

Fs = eyeDiagram.SamplingFrequency;

% Try to estimate the eye levels if maximum number of histogram hits is at
% least 4 and symbols per trace is 2.  Note that the measurements are can
% only be performed if symbols per trace is 2.
if all(max(eyeDiagram.PrivHorHistRe, [], 2) > 4) ...
        && (eyeDiagram.SymbolsPerTrace == 2)
    try
        calcEyeCrossingTime(this, ...
            eyeDiagram.PrivHorHistRe, ...
            eyeDiagram.PrivHorHistIm, eyeDiagram.SymbolsPerTrace, Fs, ...
            eyeDiagram.SamplesPerSymbol);

        calcEyeDelay(this, Fs);

        calcEyeLevel(this, ...
            eyeDiagram.PrivVerHistRe, ...
            eyeDiagram.PrivVerHistIm, ...
            eyeDiagram.MinimumAmplitude, ...
            eyeDiagram.AmplitudeResolution, ...
            eyeDiagram.MeasurementSetup.EyeLevelBoundary, ...
            eyeDiagram.MeasurementSetup.ReferenceAmplitude);

        confidenceCoeff = this.PrivEyeLevelStd ...
            ./ sqrt(this.PrivEyeLevelN);

        if ( any(confidenceCoeff < 1) )
            this.PrivEyeLevelStable = 1;
        end
    catch
    end

end