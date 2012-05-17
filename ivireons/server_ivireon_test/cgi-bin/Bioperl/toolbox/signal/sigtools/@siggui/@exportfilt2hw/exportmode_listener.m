function exportmode_listener(hEH, eventdata)
%EXPORTMODE_LISTENER Listener to the exportmode property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:07:58 $

h = get(hEH, 'Handles');

indx = find(strcmpi(hEH.ExportMode, get(h.popup, 'String')));

set(h.popup, 'Value', indx);

updatecheckbox(hEH);

% [EOF]
