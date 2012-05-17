function onStateEventHandler(this, event) 
%ONSTATEEVENTHANDLER React to Event from timer
% Call subclassed handlers if any

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2010/01/25 22:47:39 $

%call subclassed handlers if any
shouldUpdate = true;
switch event.Type
    case 'sourceStop'
        stopEventHandler(this,event);
    case 'sourceRun'
        runEventHandler(this,event);
    case 'sourcePause'
        pauseEventHandler(this,event);      
    case 'sourceContinue'
        continueEventHandler(this,event);
    case 'sourceClose'
        closeEventHandler(this,event);
        shouldUpdate = false;
    otherwise
        event.Type = '';        
end

%update GUI, but not yet if we are connecting or closing.
if shouldUpdate && ~this.Application.IsConnecting
    update(this.controls);
end

% rebroadcast for others (on application)
send(this.Application, event.Type);
% [EOF]
