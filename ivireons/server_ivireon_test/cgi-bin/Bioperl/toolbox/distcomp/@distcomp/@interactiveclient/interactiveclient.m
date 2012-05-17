function obj = interactiveclient
; %#ok Undocumented

%   Copyright 2006-2009 The MathWorks, Inc.

obj = distcomp.interactiveclient;

obj.UserName = distcomp.pGetDefaultUsername();
obj.JobStartupTimeout = Inf;
obj.Tag = 'Created_by_pmode';
obj.IsStartupComplete = false;
