function isemptyselection_eventcb(hWT, eventData)
%ISEMPTYSELECTION_EVENTCB Enable/Disable the Full View Analysis.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:45:06 $

% Callback executed by the listener to an event thrown by another object.
% The Data property stores a vector of handles of winspecs objects
s = eventData.Data;
selectedwin = s.selectedwindows;

% Get the handles to the Full View Analysis toolbar button and menu
hndls = get(hWT, 'Handles');
hFullButton = hndls.htoolbar(4);
hFullMenu = hndls.hmenus(10);
hFull = [hFullButton;hFullMenu];

if isempty(selectedwin),
    set(hFull, 'Enable', 'off');
else
    set(hFull, 'Enable', 'on');
end


% [EOF]
