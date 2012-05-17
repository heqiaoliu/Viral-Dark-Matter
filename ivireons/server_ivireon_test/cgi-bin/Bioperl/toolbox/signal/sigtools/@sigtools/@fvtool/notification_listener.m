function notification_listener(hObj, eventData)
%NOTIFICATION_LISTENER Listener to the Notification event

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/11/21 15:34:45 $

send(hObj, 'Notification', eventData);

NTypes = set(eventData, 'NotificationType');
NType  = get(eventData, 'NotificationType');

hFVT = getcomponent(hObj, 'fvtool');

% Switch on the Notification type
switch NType
case NTypes{1}, % 'ErrorOccurred'
    error(hFVT, 'FVTool Error', eventData.Data.ErrorString);
case NTypes{2}, % 'WarningOccurred'
    warning(hFVT, 'FVTool Warning', eventData.Data.WarningString);
case NTypes{3}, % 'StatusChanged'
    % NO OP.  FVTool has no way of doing this
case NTypes{4}, % File Dirty
    % NO OP.  FVTool has no sessions.
otherwise
    error(hFVT, 'FVTool Error', ...
        ['Unhandled notification ''' NType ''' sent from ' class(eventData.Source) '.']);
end

% [EOF]
