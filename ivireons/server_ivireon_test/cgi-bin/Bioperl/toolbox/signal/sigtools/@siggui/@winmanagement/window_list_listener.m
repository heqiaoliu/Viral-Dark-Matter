function window_list_listener(hManag, eventData)
%WINDOW_LIST_LISTENER Callback executed by listener to the Window_list property.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:33:49 $

% Get the names of all the windows
newlist = get(hManag, 'Window_list');
names = get(newlist, 'Name');

% Update the listbox string
hndls = get(hManag,'Handles');
hlistbox = hndls.listbox;
if isempty(names),
    names = ' ';
    hFig = get(hManag, 'FigureHandle');
    color = get(hFig, 'Color');
    % Disable listbox
    set(hlistbox, 'Enable', 'off');
else
    color = 'White';
    set(hlistbox, 'Enable', 'on');
end
set(hlistbox, 'String', names, 'BackgroundColor', color);


% [EOF]
