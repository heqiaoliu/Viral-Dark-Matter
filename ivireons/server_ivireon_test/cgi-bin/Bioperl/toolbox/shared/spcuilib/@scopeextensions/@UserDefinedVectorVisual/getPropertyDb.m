function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/06 20:47:00 $

hPropDb = scopeextensions.AbstractVectorVisual.getPropertyDb;

hPropDb.add('DisplayBuffer',          'double', 1);
hPropDb.add('XLabel',                 'string', 'Samples');
hPropDb.add('InheritSampleIncrement', 'bool',   false);
hPropDb.add('XOffset',                'double', 0);
hPropDb.add('IncrementPerSample',     'double', 1);

% [EOF]
