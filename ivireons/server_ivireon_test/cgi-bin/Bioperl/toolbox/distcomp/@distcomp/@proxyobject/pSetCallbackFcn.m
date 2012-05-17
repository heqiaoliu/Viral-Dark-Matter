function pSetCallbackFcn(obj, eventType, val)
; %#ok Undocumented
%PSETCALLBACKFCN private function to define setting the EventListeners
%
%  PSETCALLBACKFCN(OBJ, EVENTTYPE, VAL)

%  Copyright 2000-2007 The MathWorks, Inc.

%  $Revision $    $Date: 2007/04/20 20:07:27 $ 

% Which listener are we addressing
l = obj.CallbackListeners.find('EventType', eventType);

if isempty(val)
    % Note: you are not allowed a callback string of '' so disable the
    % listener and set the callback to something innocuous
    l.Enabled = 'off';
    l.Callback = 'disp';
    % If no callbacks are enabled then turn off eventing
    if all(strcmp(get(obj.CallbackListeners, 'enabled'), 'off'))
        obj.pUnregisterForEvents;
    end
else
    % Make sure that if we have not hooked up to events that we do now
    if all(strcmp(get(obj.CallbackListeners, 'enabled'), 'off'))
        obj.pRegisterForEvents;
    end
    l.Enabled = 'on';
    l.Callback = val;
end