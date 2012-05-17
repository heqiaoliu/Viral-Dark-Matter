function exporttarget_listener(hXP, eventData)
%EXPORTTARGET_LISTENER Listener to the exporttarget property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:22:55 $

update_popup(hXP);
update_checkbox(hXP);
update_editboxes(hXP);

set(hXP, 'isApplied', 0);

% [EOF]
