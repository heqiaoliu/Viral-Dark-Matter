function propertyDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:43 $

propertyDb = extmgr.PropertyDb;
propertyDb.add('PointsPerSignal', 'double', 50000);

% [EOF]
