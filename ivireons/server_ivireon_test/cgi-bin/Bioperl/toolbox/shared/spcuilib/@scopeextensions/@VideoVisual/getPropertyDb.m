function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/01/25 22:47:04 $

hPropDb = uiscopes.AbstractAxesVisual.getPropertyDb;
hPropDb.add('ColorMapExpression', 'string', 'gray(256)');
hPropDb.add('UseDataRange', 'bool', false);
hPropDb.add('DataRangeMin', 'double', 0);
hPropDb.add('DataRangeMax', 'double', 255);

% [EOF]
