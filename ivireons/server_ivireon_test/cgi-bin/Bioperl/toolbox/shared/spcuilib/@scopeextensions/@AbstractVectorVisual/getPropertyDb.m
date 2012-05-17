function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/06 20:46:36 $

hPropDb = uiscopes.AbstractLineVisual.getPropertyDb;

hPropDb.add('FrameNumber', 'bool', true);
hPropDb.add('Persistent',  'bool', false);

% [EOF]
