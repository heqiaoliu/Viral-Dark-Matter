function newcurrentwinindex_eventcb(hManag, eventData)
%NEWCURRETWININDEX_EVENTCB 

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:34:13 $

% Callback executed by the listener to an event thrown by another component.
% The Data property stores an index of the selection
index = get(eventData, 'Data');

% Set the Currentwin property
set_currentwin(hManag, index);


% [EOF]
