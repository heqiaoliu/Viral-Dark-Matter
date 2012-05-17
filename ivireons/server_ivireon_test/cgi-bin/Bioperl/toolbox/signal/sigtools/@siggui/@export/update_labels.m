function update_labels(hObj)
%UPDATE_LABELS Update the labels in the Export Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2009/01/05 18:00:45 $

% This should be private

h    = get(hObj, 'Handles');

if ~ishghandle(h.labels(1)),
    render_labels(hObj);
    return;
end

if iscoeffs(hObj),
    lbls = get(hObj, 'Labels');
else
    lbls = get(hObj, 'ObjectLabels');
end

% Sync the Labels
for i = 1:length(lbls),
    set(h.labels(i), 'String', lbls{i}, 'Visible', 'On');
end

set(h.labels(length(lbls)+1:length(h.labels)), 'Visible', 'Off');

% [EOF]
