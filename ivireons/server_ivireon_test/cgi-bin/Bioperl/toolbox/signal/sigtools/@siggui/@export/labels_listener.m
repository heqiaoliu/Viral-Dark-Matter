function labels_listener(hXP, eventData)
%LABELS_LISTENER Listener to the labels property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:22:52 $

h    = get(hXP,'Handles');
lbls = get(hXP,'Labels');

% If the # of labels rendered is not equal to the # of labels in the property, rerender.
if length(h.labels) ~= length(lbls),
    render_labels(hXP);
end

% Update the popup and the labels.  The popup handles the enable state
update_popup(hXP);
update_labels(hXP);

set(hXP, 'isApplied', 0);

% [EOF]
