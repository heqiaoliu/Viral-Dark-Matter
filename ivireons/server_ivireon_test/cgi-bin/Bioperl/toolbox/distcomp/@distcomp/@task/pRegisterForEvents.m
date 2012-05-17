function pRegisterForEvents(obj)
; %#ok Undocumented
%pRegisterForEvents register for events with the root object
%
%  pRegisterForEvents(OBJ)

%  Copyright 2007 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2007/04/20 20:07:28 $ 

% We are going to have to do something a little different if we are filling
% up a TaskInfo object rather than a proxyobject
HAS_TASKINFO = ~isempty(obj.TaskInfo);

registrationCount = obj.ProxyToUddAdaptorRegistrationCount;
% Check to see if we think we have already registered for events - if we
% haven't then really register
if registrationCount == 0
    root = distcomp.getdistcompobjectroot;
    % It is possible that the ProxyToUddAdaptor doesn't exist (on a worker
    % node) or that this might throw an error. Silently swallow the error for
    % the time being
    try
        if HAS_TASKINFO
            % Create a ListenerInfo array from the ProxyToUddAdaptor and
            % put it in the TaskInfo holder
            listenerInfoArray = root.ProxyToUddAdaptor.createListenerInfoArrayForAllEvents;
            obj.TaskInfo.setListenerInfo(listenerInfoArray);
        else
            % Otherwise use the attachToListenableObject to listen for
            % events on the already created task
            root.ProxyToUddAdaptor.attachToListenableObject(obj.ProxyObject, obj.UUID);
        end
    catch
    end
end
% Increment the number of times we have registered
obj.ProxyToUddAdaptorRegistrationCount = registrationCount + 1;

