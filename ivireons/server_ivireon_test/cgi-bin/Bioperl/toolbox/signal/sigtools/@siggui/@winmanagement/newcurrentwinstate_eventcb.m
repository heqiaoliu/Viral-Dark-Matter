function newcurrentwinstate_eventcb(hManag, eventData)
%NEWCURRETWINSTATE_EVENTCB 

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:34:10 $

% Callback executed by the listener to an event thrown by another component.
% The Data property stores the state of a winspecs object
state = get(eventData, 'Data');

% Sets the state of the current window
set_currentwin_state(hManag, state);


% [EOF]
