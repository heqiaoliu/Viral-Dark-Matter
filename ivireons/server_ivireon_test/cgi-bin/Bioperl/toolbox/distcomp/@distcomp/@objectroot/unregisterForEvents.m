function unregisterForEvents(obj, proxyObject, UUID)
; %#ok Undocumented

% Copyright 2004-2006 The MathWorks, Inc.

% It is possible that the ProxyToUddAdaptor doesn't exist (on a worker
% node) or that this might throw an error. Silently swallow the error for
% the time being
try
    obj.ProxyToUddAdaptor.detachFromListenableObject(proxyObject, UUID);
catch
end