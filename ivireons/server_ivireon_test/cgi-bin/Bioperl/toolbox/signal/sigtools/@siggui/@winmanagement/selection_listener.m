function selection_listener(hManag, eventData)
%SELECTION_LISTENER Callback executed by listener to the selection property.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/12/26 22:22:29 $ 

winlist = get(hManag, 'Window_list');
select = get(hManag, 'Selection');

% Update the GUI
if isrendered(hManag),
    hndls = get(hManag,'Handles');
    hlistbox = hndls.listbox;
    pb_hndls = hndls.pbs;
    if isempty(select),
        % Disable delete copy and save buttons when the selection is empty
        set(pb_hndls(2:4), 'Enable', 'off');
    else
        set(pb_hndls(2:4), 'Enable', 'on');
    end
    set(hlistbox, 'Value', select);
end

% By default, the current window is the first of selection
if isempty(select),
    set(hManag, 'Currentwin', []);
else
    currentwin = get(hManag, 'Currentwin');
    if isempty(currentwin) | all(currentwin~=select),
        % Reset the currentwin property
        set(hManag, 'Currentwin', select(end));
    end
end


% Send an event
s.selectedwindows = winlist(select);
s.selection = select;
s.currentindex = get(hManag, 'Currentwin');
hEventData = sigdatatypes.sigeventdata(hManag, 'NewSelection', s);
send(hManag, 'NewSelection', hEventData);

% [EOF]
