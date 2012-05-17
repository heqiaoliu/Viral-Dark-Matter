function disp(this)
%DISP Display properties of the eye measurements object
%   DISP(H) displays relevant properties of the eye measurements object H.  The
%   measurements can be displayed either optimized for real signals or optimized
%   for complex signals.  When display is optimized for complex signals, first
%   column represents the in-phase or real signal measurements, while the second
%   column represents the quadrature or imaginary signal measurements. The
%   following display represents the results of the analysis of a complex
%   signal.   
%
%                        Type: 'Eye Diagram Measurements'
%                 DisplayMode: 'Optimized for Complex Signal'
%             EyeCrossingTime: [2x2 double]
%        EyeCrossingAmplitude: [2x2 double]
%                    EyeDelay: [0.0100 0.0100]
%                    EyeLevel: [2x2 double]
%                EyeAmplitude: [2.8040 2.8036]
%                   EyeHeight: [2.1903 2.1855]
%       EyeCrossingPercentage: [50.7335 49.7801]
%          EyeOpeningVertical: [2.3290 2.2586]
%                      EyeSNR: [13.7075 13.6082]
%                    EyeWidth: [0.0078 0.0078]
%        EyeOpeningHorizontal: [0.0066 0.0069]
%                JitterRandom: [0.0031 0.0023]
%         JitterDeterministic: [3.0612e-004 7.6950e-004]
%                 JitterTotal: [0.0034 0.0031]
%                   JitterRMS: [0.0101 0.0101]
%            JitterPeakToPeak: [0.0017 0.0017]
%                 EyeRiseTime: [0.0065 0.0065]
%                 EyeFallTime: [0.0065 0.0065]
%
%   If display is optimized for real signals, the first and second rows
%   represent the in-phase and quadrature signal measurements, respectively.
%   The following display represents the results of the analysis of a real
%   signal.   
% 
%                        Type: 'Eye Diagram Measurements'
%                 DisplayMode: 'Optimized for Real Signal'
%             EyeCrossingTime: [0.0050 0.0150]
%        EyeCrossingAmplitude: [0.0189 0.0205]
%                    EyeDelay: 0.0100
%                    EyeLevel: [-1.4016 1.4022]
%                EyeAmplitude: 2.8038
%                   EyeHeight: 2.1885
%       EyeCrossingPercentage: 50.6913
%          EyeOpeningVertical: 2.2938
%                      EyeSNR: 13.6704
%                    EyeWidth: 0.0078
%        EyeOpeningHorizontal: 0.0068
%                JitterRandom: 0.0026
%         JitterDeterministic: 5.4633e-004
%                 JitterTotal: 0.0032
%                   JitterRMS: 0.0101
%            JitterPeakToPeak: 0.0016
%                 EyeRiseTime: 0.0065
%                 EyeFallTime: 0.0065
%
%   See also COMMSCOPE.EYEMEASUREMENTS, COMMSCOPE.EYEMEASUREMENTS/ANALYZE,
%   COMMSCOPE.EYEMEASUREMENTS/RESET.

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/06/11 15:56:59 $

% Define the fields to be displayed in order
fieldNames = {'Type', ...
    'DisplayMode', ...
    'EyeCrossingTime', ...
    'EyeCrossingAmplitude', ...
    'EyeDelay', ...
    'EyeLevel', ...
    'EyeAmplitude', ...
    'EyeHeight', ...
    'EyeCrossingPercentage', ...
    'EyeOpeningVertical', ...
    'EyeSNR', ...
    'QualityFactor', ...
    'EyeWidth', ...
    'EyeOpeningHorizontal', ...
    'JitterRandom', ...
    'JitterDeterministic', ...
    'JitterTotal', ...
    'JitterRMS', ...
    'JitterPeakToPeak', ...
    'EyeRiseTime', ...
    'EyeFallTime'};

% If this is a scalar, display properties in a predefined way, otherwise use the
% built-in display method
excludedFieldNames = {};
if isscalar(this)
    that = copy(this);
    if ( strcmp(this.DisplayMode, 'Optimized for Complex Signal') )
        for p=1:length(fieldNames)
            dummy = get(that, fieldNames{p});
            set(that, fieldNames{p}, transpose(dummy));
        end
    end
    baseDisp(that, fieldNames, excludedFieldNames);
else
    baseDisp(this, fieldNames, excludedFieldNames);
end

%-------------------------------------------------------------------------------
% [EOF]
