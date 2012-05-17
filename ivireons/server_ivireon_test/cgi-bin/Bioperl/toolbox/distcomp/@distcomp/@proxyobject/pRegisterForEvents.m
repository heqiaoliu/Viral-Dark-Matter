function pRegisterForEvents(obj)
; %#ok Undocumented
%pRegisterForEvents register for events with the root object
%
%  pRegisterForEvents(OBJ)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:38:35 $ 

registrationCount = obj.ProxyToUddAdaptorRegistrationCount;
% Check to see if we think we have already registered for events - if we
% haven't then really register
if registrationCount == 0
    root = distcomp.getdistcompobjectroot;
    root.registerForEvents(obj.ProxyObject, obj.UUID);
end
% Increment the number of times we have registered
obj.ProxyToUddAdaptorRegistrationCount = registrationCount + 1;

