function pUnregisterForEvents(obj)
; %#ok Undocumented
%pUnregisterForEvents unregister events with the root object
%
%  pUnRegisterForEvents(OBJ)

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/04/20 20:07:29 $ 

% We are going to have to do something a little different if we are filling
% up a TaskInfo object rather than a proxyobject
HAS_TASKINFO = ~isempty(obj.TaskInfo);

registrationCount = obj.ProxyToUddAdaptorRegistrationCount;
% First check we aren't decrementing a zero event count
if registrationCount < 1
    warning('distcomp:proxyobject:InvalidState', 'Attempting to unregister for events before registering'); 
    return
end

registrationCount = registrationCount - 1;
% If the registration count has reached zero then unregister with the root
if registrationCount == 0
    root = distcomp.getdistcompobjectroot;
    % It is possible that the ProxyToUddAdaptor doesn't exist (on a worker
    % node) or that this might throw an error. Silently swallow the error for
    % the time being
    try
        if HAS_TASKINFO
            obj.TaskInfo.setListenerInfo([]);
        else
            root.ProxyToUddAdaptor.detachFromListenableObject(obj.ProxyObject);
        end
    catch
    end
end

obj.ProxyToUddAdaptorRegistrationCount = registrationCount;