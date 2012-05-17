function backupnames_listener(hObj, eventData)
%BACKUPNAMES_LISTENER Listener to the backupnames property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/06/27 19:58:37 $

h    = get(hObj, 'Handles');

strs = get(hObj, 'BackupNames');
if length(strs) > 1,
end

if length(strs) == 1,
    set(h.editbox, ...
        'String', strs{1}, ...
        'Visible', 'On');
    set(h.combo, 'Visible', 'Off');
else
    strs = {'Apply to All', strs{:}};
    set(h.combo, ...
        'String', strs, ...
        'Visible', 'On');
    set(h.editbox, 'Visible', 'Off');
end

% [EOF]
