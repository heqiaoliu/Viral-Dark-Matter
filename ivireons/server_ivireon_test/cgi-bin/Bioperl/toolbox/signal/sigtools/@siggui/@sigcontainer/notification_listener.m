function notification_listener(hObj, eventData)
%NOTIFICATION_LISTENER Listener notification events

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:03:14 $

% The default notification_listener simply rethrows the notification.
% Individual subclasses must overload notification_listener if they want to
% intercept the event.

send(hObj, 'Notification', eventData);

% [EOF]
