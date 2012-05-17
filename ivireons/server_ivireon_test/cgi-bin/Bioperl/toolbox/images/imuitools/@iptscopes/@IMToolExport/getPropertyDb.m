function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/09/18 02:09:36 $

hPropDb = extmgr.PropertyDb;

hPropDb.add('NewIMTool', 'bool', true);

% [EOF]
