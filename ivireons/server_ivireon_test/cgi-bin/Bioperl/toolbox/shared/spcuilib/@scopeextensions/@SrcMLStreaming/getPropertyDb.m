function hPropDb = getPropertyDb
%GETPROPERTYDB Get the propertyDb.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/31 18:41:58 $

hPropDb = uiscopes.AbstractBufferingSource.getPropertyDb;
hPropDb.add('ShowSnapShotButton','bool',true);


