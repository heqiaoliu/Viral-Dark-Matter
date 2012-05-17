function pos = getpanelpos(this)
%GETPANELPOS   Get the panel position.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:27 $

% % Disable the listeners so that we don't fire the callback to the
% % ResizeEvent and force extra updates.
% l = get(this, 'Panel_Listeners');
% set(l, 'Enabled', 'Off');

hp = get(this, 'Panel');

oldResizeFcn = get(hp, 'ResizeFcn');
set(hp, 'ResizeFcn', '');

origUnits = get(hp, 'Units');    set(hp, 'Units', 'Pixels');
pos       = get(hp, 'Position'); set(hp, 'Units', origUnits);

set(hp, 'ResizeFcn', oldResizeFcn);
% set(l, 'Enabled', 'On');

% [EOF]
