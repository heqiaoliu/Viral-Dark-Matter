function attachnotificationlistener(hFDA)
%ATTACHNOTIFICATIONLISTENER

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2010/01/25 22:53:30 $

hChildren = allchild(hFDA);

% Add a listener to a local function.  Creating function handles for
% external MATLAB files is very slow.  Local functions is much faster.
hListener = handle.listener([hFDA; hChildren(:)], 'Notification', @lclnotification_listener);
set(hListener, 'CallbackTarget', hFDA);

set(hFDA, 'NotificationListener', hListener);

% -----------------------------------------------------------
function lclnotification_listener(hObj, eventData, varargin)

notification_listener(hObj, eventData, varargin{:});

% [EOF]
