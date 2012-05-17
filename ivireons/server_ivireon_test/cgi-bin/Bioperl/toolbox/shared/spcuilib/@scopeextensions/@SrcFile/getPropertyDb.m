function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/17 22:40:36 $

hPropDb = extmgr.PropertyDb;
% Name of most recent file opened by user
hPropDb.add('LastConnectFileOpened','string',fullfile(pwd,filesep));

% [EOF]
