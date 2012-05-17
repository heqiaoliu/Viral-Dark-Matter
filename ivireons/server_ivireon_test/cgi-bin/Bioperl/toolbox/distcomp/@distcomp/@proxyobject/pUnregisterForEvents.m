function pUnregisterForEvents(obj)
; %#ok Undocumented
%pUnregisterForEvents unregister events with the root object
%
%  pUnRegisterForEvents(OBJ)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:38:40 $ 

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
    root.unregisterForEvents(obj.ProxyObject, obj.UUID);
end

obj.ProxyToUddAdaptorRegistrationCount = registrationCount;