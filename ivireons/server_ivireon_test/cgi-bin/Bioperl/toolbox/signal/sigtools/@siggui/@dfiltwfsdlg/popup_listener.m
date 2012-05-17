function popup_listener(hObj, eventData)
%POPUP_LISTENER Listener to the filter name popup

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/28 19:13:02 $

h = get(hObj, 'Handles');

strs = get(h.combo, 'String');
if length(strs) > 1,
    strs = strs(2:end);
end
set(hObj, 'BackupNames', strs);

set(hObj, 'isApplied', 0);

% [EOF]
