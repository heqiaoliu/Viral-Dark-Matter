function this = wintool
%WINTOOL Constructor for the wintool class.

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/13 00:31:04 $

% Instantiate the object
this = sigtools.wintool;

% Add components
addcomponent(this, siggui.winmanagement);
addcomponent(this, siggui.winspecs);
addcomponent(this, siggui.winviewer);

l.notification = handle.listener(this, 'Notification', @notification_listener);
set(l.notification, 'CallbackTarget', this);
set(this, 'Listeners', l);

% Set up the default
set(this, 'Version', 1);

% [EOF]
