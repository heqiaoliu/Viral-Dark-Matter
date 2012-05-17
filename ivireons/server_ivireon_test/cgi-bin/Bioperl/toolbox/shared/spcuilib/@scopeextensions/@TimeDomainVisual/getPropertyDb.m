function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/29 16:09:07 $

hPropDb = uiscopes.AbstractLineVisual.getPropertyDb;

% Add an enumeration and a property for what type of processing we'll do on
% the input.  Either frame/column based or sample/element based.
if isempty(findtype('BlockInputProcessing'))
    schema.EnumType('BlockInputProcessing', {'FrameProcessing', 'SampleProcessing'});
end

hPropDb.add('InputProcessing', 'BlockInputProcessing');
hPropDb.add('TimeRangeFrames', 'string', '10');
hPropDb.add('TimeRangeSamples', 'string', '10');
hPropDb.add('TimeDisplayOffset', 'string', '0');

% [EOF]
