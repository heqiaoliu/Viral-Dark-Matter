function attachnotificationlistener(hParent)
%ATTACHNOTIFICATIONLISTENER

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2010/01/25 22:53:22 $

hAllChildren = allchild(hParent);

% Add a listener to a local function.  Creating function handles for
% external MATLAB files is very slow.  Local functions is much faster.
hListener = handle.listener(hAllChildren, 'Notification', @lclnotification_listener);
set(hListener, 'CallbackTarget', hParent);

set(hParent, 'NotificationListener', hListener);

% -----------------------------------------------------------
function lclnotification_listener(hObj, eventData, varargin)

notification_listener(hObj, eventData, varargin{:});

% [EOF]
