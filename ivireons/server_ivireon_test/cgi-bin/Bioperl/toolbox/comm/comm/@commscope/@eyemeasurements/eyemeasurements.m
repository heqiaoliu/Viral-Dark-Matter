function this = eyemeasurements(varargin)
%EYEMEASUREMENTS Construct an eye diagram measurements object
%
%   H = COMMSCOPE.EYEMEASUREMENTS constructs a default eye diagram measurements
%   object H. 
%
%   H = COMMSCOPE.EYEMEASUREMENTS(PROPERTY1, VALUE1, ...) constructs an eye
%   diagram measurements object H with properties as specified by
%   PROPERTY/VALUE pairs. 
%
%   An eye diagram measurements object has the following properties. All the
%   properties are read-only except for the ones explicitly noted otherwise.
%   Type "doc commscope.eyemeasurements" for a detailed explanation of each
%   measurement.
%
%   Property Name          Description
%   -----------------------------------------------------------------------
%   Type                 - Type of the object ('Eye Diagram Measurements').
%   DisplayMode          - Display mode of the object.  This property is 
%                          writable.  The choices are:
%                          'Optimized for Real Signal'    - Measurement results 
%                                           of in-phase and quadrature signals
%                                           are displayed in the first and
%                                           second row, respectively.
%                          'Optimized for Complex Signal' - Measurement results 
%                                           of in-phase and quadrature signals
%                                           are display in the first and second
%                                           column, respectively.
%   EyeCrossingTime       - The mean value of time in seconds at which the eye
%                           diagram crosses the amplitude level defined by the
%                           ReferenceAmplitude property of the
%                           EYEMEASUREMENTSETUP object.
%   EyeCrossingAmplitude  - The mean amplitude value of the eye diagram at the
%                           eye crossing time.  
%   EyeDelay              - The distance of the mid-point of the eye to the time
%                           origin, which is the leftmost point of the time axis.  
%                           Eye delay is measured in seconds.
%   EyeLevel              - The mean value of distinct eye levels at the eye
%                           delay value.  The eye levels are calculated in a 
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
%                           performed at two edge values defined by the
%                           AmplitudeThreshold property of the
%                           EYEMEASUREMENTSETUP object.
%   EyeFallTime           - Fall time of the eye in seconds.  The measurement is
%                           performed at two edge values defined by the
%                           AmplitudeThreshold property of the
%                           EYEMEASUREMENTSETUP object.
%
%   H = COMMSCOPE.EYEMEASUREMENTS constructs an eye diagram measurements object
%   H with default properties and is equivalent to:
%   H = COMMSCOPE.EYEMEASUREMENTS('DisplayMode', 'Optimized for Real Signal');
%
%   An eye diagram measurements object is equipped with three methods for
%   simulation, analysis, object management, and visualization.  To get detailed
%   help on these methods either click on the method name or type "help
%   commscope.eyemeasurements/<METHOD>" on the command line, where METHOD is one
%   of the methods listed below. 
%
%   commscope.eyemeasurements methods:
%     analyze    - Execute eye measurements
%     disp       - Display properties of an eye measurements object
%     reset      - Reset the eye measurements object
%
%   Note: 
%   Eye diagram measurements object is intended to be used within the eye
%   diagram object.  The ANALYZE method of the eye diagram object calls the
%   ANALYZE method of the eye diagram measurements object with proper arguments.
%
%   Example: 
%
%   % Construct an eye diagram object and optimize the measurements object
%   % display for complex signals.  See the eye measurements demo for a more
%   % detailed example.  Type "demo toolbox comm" and choose "Analysis and
%   % Visualization" subcategory.
%   h = commscope.eyediagram;
%   h.Measurements.DisplayMode = 'Optimized for Complex Signal';
%   h.Measurements
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEMEASUREMENTSETUP.

%   @commscope/eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/01/10 21:08:34 $

% Create the object
this = commscope.eyemeasurements;

% Set default properties
this.Type = 'Eye Diagram Measurements';

% If there are arguments, initialize the object accordingly
if nargin ~= 0
    initPropValuePairs(this, varargin{:});
end

%-------------------------------------------------------------------------------
% [EOF]
