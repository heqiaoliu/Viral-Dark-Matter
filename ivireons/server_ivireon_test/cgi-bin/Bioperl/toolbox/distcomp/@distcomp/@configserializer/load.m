function allValues = load(configName)
; %#ok Undocumented
%Static method that loads and returns all values of the specified configuration.
%  Throws an error if no such configuration exists on disk.

%   Copyright 2007 The MathWorks, Inc.
    
ser = distcomp.configserializer.pGetInstance();
% pGetID throws an error if configName is invalid.
allValues = ser.Cache.configurations(ser.pGetID(configName)).Values;
