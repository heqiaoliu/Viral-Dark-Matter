function save(obj)
; %#ok Undocumented
%save Saves all the properties in this configuration.
%

%  Copyright 2007 The MathWorks, Inc.

allValues = obj.pGetStruct();
distcomp.configserializer.save(obj.ActualName, allValues);
