function constrainedbands_listener(hObj, eventData)
%CONSTRAINEDBANDS_LISTENER Listener to the ConstrainedBands property

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:21:59 $

update_labels(hObj);

h = get(hObj, 'Handles');

cb = get(hObj, 'ConstrainedBands');
set(h.checkbox(cb), 'Value', 1);
set(setdiff(h.checkbox, h.checkbox(cb)), 'Value', 0);

if isempty(cb),
    enab = 'Off';
else
    enab = hObj.Enable;
end

setenableprop(h.units, enab);

% [EOF]
