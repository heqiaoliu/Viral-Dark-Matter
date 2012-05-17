function currentwin_listener(hManag, eventData)
%SELECTION_LISTENER Callback executed by listener to the currentwin property.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:34:25 $

newpos = get(hManag, 'Currentwin');
winlist = get(hManag, 'Window_list');

% Send an event
hEventData = sigdatatypes.sigeventdata(hManag, 'NewCurrentwin', winlist(newpos));
send(hManag, 'NewCurrentwin', hEventData);


% [EOF]
