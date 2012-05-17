function newcurrentwin_eventcb(hSpecs, eventData)
%NEWCURRETWIN_EVENTCB

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/12/26 22:22:33 $

% Callback executed by the listener to an event thrown by another component.
% The Data property stores a handle of a winspecs object
currentwin = get(eventData, 'Data');

% Set the state of winSpecs object
if ~isempty(currentwin),
    state = getstate(currentwin);
    setstate(hSpecs, state);
    set(hSpecs, 'isModified', 0);
end


% [EOF]
