function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/01/25 22:47:28 $

hPropDb = uiscopes.AbstractAxesVisual.getPropertyDb;

hPropDb.add('Grid',    'bool', true);
hPropDb.add('Legend',  'bool', false);
hPropDb.add('Compact', 'bool', false);

hPropDb.add('AutoDisplayLimits', 'bool', true);

hPropDb.add('MinXLim', 'string', '0');
hPropDb.add('MaxXLim', 'string', '1');

hPropDb.add('YLabel',  'string', 'Amplitude');
hPropDb.add('MinYLim', 'string', '-10');
hPropDb.add('MaxYLim', 'string', '10');

hPropDb.add('LineProperties', 'mxArray');

% hPropDb.add('LineNames',        'mxArray', {});
% hPropDb.add('LineVisibilities', 'string');
% hPropDb.add('LineMarkers',      'string');
% hPropDb.add('LineStyles',       'string');
% hPropDb.add('LineColors',       'string');

% [EOF]
