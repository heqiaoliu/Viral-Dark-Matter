function pDispatchJavaEvent(obj, src, event)
; %#ok Undocumented
%pDispatchJavaEvent private function to dispatch java events to udd objects
%
%  

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.4 $    $Date: 2006/06/27 22:36:46 $ 

import com.mathworks.toolbox.distcomp.distcompobjects.DistcompListenable;

switch double(event.getID)
    case DistcompListenable.EVENT_QUEUED_STATE
        eventName = 'PostQueue';
    case DistcompListenable.EVENT_RUNNING_STATE
        eventName = 'PostRun';
    case DistcompListenable.EVENT_FINISHED_STATE
        eventName = 'PostFinish';
    otherwise
        return
end

% Eventually we might want to create a sensible event data class to
% send with this, but for the time being we'll just send the
% object
send(obj, eventName);
