function name = getCurrentName()
; %#ok Undocumented
%A static method that returns the name of the current configurations.

%   Copyright 2007 The MathWorks, Inc.

ser = distcomp.configserializer.pGetInstance();
name = ser.Cache.current;

