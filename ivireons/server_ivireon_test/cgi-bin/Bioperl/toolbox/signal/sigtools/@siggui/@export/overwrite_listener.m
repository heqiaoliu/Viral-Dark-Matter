function overwrite_listener(hXP, eventData)
%OVERWRITE_LISTENER Listener to the Overwrite property of the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:22:49 $

% This is a WhenRenderedListener

% Sync the check box and the property
update_checkbox(hXP)

set(hXP, 'isApplied', 0);

% [EOF]