function labels_listener(hObj, eventData)
%LABELS_LISTENER Listener to the labels property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:22:01 $

h = get(hObj, 'Handles');

hon = h.checkbox(1:length(hObj.Labels));
hoff = setdiff(h.checkbox, hon);

set(hon, 'Visible', hObj.Visible);
set(hoff, 'Visible', 'Off');

update_labels(hObj);

% [EOF]
