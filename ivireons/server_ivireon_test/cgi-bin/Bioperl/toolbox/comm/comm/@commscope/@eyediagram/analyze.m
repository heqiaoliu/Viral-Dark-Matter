function analyze(this)
%ANALYZE  Execute eye diagram measurements
%   ANALYZE(H) executes the eye diagram measurements on the collected data of
%   the eye diagram scope object H.  The results of the measurements are stored
%   in the Measurements property of H.  
%
%   Following measurements are available:
%
%   EyeCrossingTime       - The mean value of time in seconds at which the eye
%                           diagram crosses the amplitude level defined by the
%                           ReferenceAmplitude property of the
%                           EYEMEASUREMENTSETUP object.
%   EyeCrossingAmplitude  - The mean amplitude value of the eye diagram at the
%                           eye crossing time.  
%   EyeDelay              - The distance of the mid-point of the eye to the time
%                           origin, which is the leftmost of the time axis.  
%                           Eye delay is measured in seconds.
%   EyeLevel              - The mean value of distinct eye levels around the
%                           eye delay value.  The eye levels are calculated in a
%                           band, which is defined by the EyeLevelBoundary 
%                           property of the EYEMEASUREMENTSETUP object, around
%                           the eye delay.
%   EyeAmplitude          - The distance between EyeLevel values. 
%   EyeHeight             - The vertical distance between two amplitude levels
%                           that are three standard deviations from the mean eye
%                           level towards the center of the eye. 
%   EyeCrossingPercentage - The eye crossing amplitude value as a percentage of
%                           the eye amplitude.
%   EyeOpeningVertical    - Vertical eye opening value measured at a BER value
%                           defined by the BERThreshold property of the
%                           EYEMEASUREMENTSETUP object.
%   EyeSNR                - Signal-to-noise ratio of the eye diagram.
%   QualityFactor         - Quality factor of the eye.
%   EyeWidth              - The horizontal distance between two points that are
%                           three standard deviations from the mean eye crossing
%                           times towards the center of the eye. 
%   EyeOpeningHorizontal  - Horizontal eye opening value measured at a BER value
%                           defined by the BERThreshold property of the
%                           EYEMEASUREMENTSETUP object. 
%   JitterRandom          - Random jitter measured at the amplitude value
%                           defined by the ReferenceAmplitude property of the
%                           EYEMEASUREMENTSETUP object.  The measurement is
%                           performed for a BER value defined by the
%                           BERThreshold property of the EYEMEASUREMENTSETUP
%                           object.  
%   JitterDeterministic   - Deterministic jitter at the amplitude value
%                           defined by the ReferenceAmplitude property of the
%                           EYEMEASUREMENTSETUP object.
%   JitterTotal           - Total jitter, which is the sum of random and
%                           deterministic jitter values.
%   JitterRMS             - RMS jitter measured at the amplitude value
%                           defined by the ReferenceAmplitude property of the
%                           EYEMEASUREMENTSETUP object.  
%   JitterPeakToPeak      - Peak-to-peak jitter measured at the amplitude 
%                           value defined by the ReferenceAmplitude property of
%                           the EYEMEASUREMENTSETUP object.  
%   EyeRiseTime           - Rise time of the eye in seconds.  The measurement is
%                           performed between two edge values, defined by the
%                           AmplitudeThreshold property of the
%                           EYEMEASUREMENTSETUP object.
%   EyeFallTime           - Fall time of the eye in seconds.  The measurement is
%                           performed between two edge values, defined by the
%                           AmplitudeThreshold property of the
%                           EYEMEASUREMENTSETUP object.
%
%   To get a detailed explanation of the available measurements, type 'doc
%   commscope.eyemeasurements'.
%
%   See also COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEDIAGRAM/CLOSE,
%   COMMSCOPE.EYEDIAGRAM/COPY, COMMSCOPE.EYEDIAGRAM/DISP,
%   COMMSCOPE.EYEDIAGRAM/EXPORTDATA, COMMSCOPE.EYEDIAGRAM/PLOT,
%   COMMSCOPE.EYEDIAGRAM/RESET, COMMSCOPE.EYEDIAGRAM/UPDATE.

%
%   @commscope/@eyediagram
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 07:49:02 $

if ~this.PrivAnalysisUpToDate
    % Check if there was clipping.
    checkClipping(this);
    
    % Call the analyze method of the eyemeasurements
    this.Measurements.analyze(this);

    % Flag that analysis is updated
    this.PrivAnalysisUpToDate = true;
end

%-------------------------------------------------------------------------------
% [EOF]
