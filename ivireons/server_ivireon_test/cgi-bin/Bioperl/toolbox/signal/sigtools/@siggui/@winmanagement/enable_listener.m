function enable_listener(hManag, eventData)
%ENABLE_LISTENER Overload the siggui superclass's enable listener

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2008/05/31 23:28:27 $

enabState = get(eventData, 'NewValue');
h = handles2vector(hManag);
set(h, 'Enable', enabState)

if strcmpi(enabState, 'on'),
    % Fire listener to update the state of the listbox
    set(hManag, 'Window_list', get(hManag, 'Window_list'));
    % Fire listener to update the state of the buttons
    set(hManag, 'Selection', get(hManag, 'Selection'));
else
    % Turn the backgroundcolor of the listbox
    hFig = get(hManag, 'FigureHandle');
    hndls = get(hManag, 'Handles');
    set(hndls.listbox, 'BackgroundColor', get(hFig, 'Color'));
end


% [EOF]
