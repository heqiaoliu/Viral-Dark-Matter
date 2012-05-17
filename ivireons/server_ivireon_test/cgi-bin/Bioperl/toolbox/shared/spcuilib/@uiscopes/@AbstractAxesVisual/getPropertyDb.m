function propertyDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:47:15 $

propertyDb = extmgr.PropertyDb;

propertyDb.add('AxesProperties', 'mxArray');

% [EOF]
