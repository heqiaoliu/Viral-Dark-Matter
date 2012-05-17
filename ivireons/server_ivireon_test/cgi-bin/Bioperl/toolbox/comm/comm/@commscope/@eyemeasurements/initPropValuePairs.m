function this = initPropValuePairs(this, varargin)
%INITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
%   for the object THIS. Odd elements of VARARGIN are property names; even
%	elements are property values. Set which properties are read only.

%	@commscope\@eyemeasurements

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:30 $

% list of read only properties
readOnlyProperties = {'EyeCrossingTime', ...
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

baseInitPropValuePairs(this, readOnlyProperties, varargin{:});
%-------------------------------------------------------------------------------
% [EOF]