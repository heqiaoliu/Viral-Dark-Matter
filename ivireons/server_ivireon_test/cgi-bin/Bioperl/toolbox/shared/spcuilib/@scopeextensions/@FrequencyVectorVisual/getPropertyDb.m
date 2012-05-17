function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/06 20:46:44 $

hPropDb = scopeextensions.AbstractVectorVisual.getPropertyDb;

if isempty(findtype('FrequencyVectorFrequencyRange'))
    schema.EnumType('FrequencyVectorFrequencyRange', ...
        {'[0...Fs/2]', '[-Fs/2...Fs/2]', '[0...Fs]'});
end

if isempty(findtype('FrequencyVectorYAxisScaling'))
    schema.EnumType('FrequencyVectorYAxisScaling', {'Magnitude', 'dB'});
end

hPropDb.add('NormalizedFrequencyUnits', 'bool', false);
hPropDb.add('FrequencyRange', 'FrequencyVectorFrequencyRange');
hPropDb.add('InheritSampleTime', 'bool', true);
hPropDb.add('SampleTime', 'double', 1);
hPropDb.add('YAxisScaling', 'FrequencyVectorYAxisScaling', 'dB');

% [EOF]
