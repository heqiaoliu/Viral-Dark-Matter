function render_labels(hXP)
%RENDER_LABELS Render the labels for the Export Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2009/01/05 18:00:43 $

h    = get(hXP, 'Handles');
hFig = get(hXP, 'FigureHandle');
sz   = export_gui_sizes(hXP);

enabState = get(hXP,'Enable');

% Remove and delete the old labels
if isfield(h,'labels'),
    delete(h.labels(ishghandle(h.labels)));
    h.labels = [];
end

for i = 1:max([length(get(hXP, 'Labels')) length(get(hXP, 'ObjectLabels'))]);
    
    h.labels(i) = uicontrol(hFig, ...
        'Position', sz.nlabel - (i-1) * [0 sz.uh+sz.uuvs 0 0], ...
        'Style', 'Text', ...
        'Enable', enabState, ...
        'Tag', 'export_label', ...
        'HorizontalAlignment', 'Left');
end

set(hXP, 'Handles', h);
update_labels(hXP);

% [EOF]
