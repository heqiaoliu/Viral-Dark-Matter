function pSetCallbackFcn(obj, eventType, val)
; %#ok Undocumented
%PSETCALLBACKFCN private function to define setting the EventListeners
%
%  PSETCALLBACKFCN(OBJ, EVENTTYPE, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.3 $    $Date: 2006/06/27 22:34:43 $ 

% Which listener are we addressing
l = obj.CallbackListeners.find('EventType', eventType);

if isempty(val)
    % Note: you are not allowed a callback string of '' so disable the
    % listener and set the callback to something innocuous
    l.Enabled = 'off';
    l.Callback = 'disp';
else
    l.Enabled = 'on';
    l.Callback = val;
end