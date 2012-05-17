function names = getAllNames()
; %#ok Undocumented
%getAllNames Static method that returns the names of all configurations.

%   Copyright 2007 The MathWorks, Inc.
    
ser = distcomp.configserializer.pGetInstance();
names = {ser.Cache.configurations.Name};
