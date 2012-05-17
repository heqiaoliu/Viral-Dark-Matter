function counter = getCacheCounter()
; %#ok Undocumented
%getCacheCounter Static method that returns a counter that is updated every time
%we flush the cache.

%   Copyright 2007 The MathWorks, Inc.
    
ser = distcomp.configserializer.pGetInstance();
counter = ser.CacheCounter;
