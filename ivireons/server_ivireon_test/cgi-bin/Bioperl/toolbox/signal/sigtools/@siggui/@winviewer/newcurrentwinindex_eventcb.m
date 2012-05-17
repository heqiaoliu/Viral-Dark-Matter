function newcurrentwinindex_eventcb(hView, eventData)
%NEWCURRETWININDEX_EVENTCB 

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2009/03/09 19:35:39 $

% Callback executed by the listener to an event thrown by another component.
% The Data property stores an index of the selection
index = get(eventData, 'Data');

% Bold the current window
boldcurrentwin(hView, index);

% Measure the current window
[FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, index);

% Display the measurements
display_measurements(hView, FLoss, RSAttenuation, MLWidth);

% [EOF]
