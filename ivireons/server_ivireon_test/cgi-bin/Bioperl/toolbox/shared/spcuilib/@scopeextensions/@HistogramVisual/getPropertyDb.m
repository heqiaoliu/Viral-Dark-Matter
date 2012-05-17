function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:41:30 $

hPropDb = uiscopes.AbstractAxesVisual.getPropertyDb;
hPropDb.add('ShowLegend','bool',false);


% [EOF]
