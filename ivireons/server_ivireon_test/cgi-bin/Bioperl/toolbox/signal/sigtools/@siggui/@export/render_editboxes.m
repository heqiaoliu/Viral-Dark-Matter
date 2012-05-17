function render_editboxes(hXP)
%RENDER_EDITBOXES Render the export edit boxes

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2009/01/05 18:00:42 $

h    = get(hXP, 'Handles');
hFig = get(hXP, 'FigureHandle');
sz   = export_gui_sizes(hXP);
cbs  = callbacks(hXP);

enabState = get(hXP,'Enable');

% Delete the old edit boxes if they exist.
if isfield(h,'edit')
    delete(h.edit(ishghandle(h.edit)));
    h.edit = [];
end

% Loop over the number of target names and render an appropriate number of edit boxes
for i = 1:max([length(get(hXP, 'TargetNames')), length(get(hXP, 'ObjectTargetNames'))])
    h.edit(i)   = uicontrol(hFig, ...
        'Position', sz.nedit - (i-1) * [0 sz.uh+sz.uuvs 0 0], ...
        'Style', 'Edit', ...
        'Backgroundcolor', [1 1 1], ...
        'HorizontalAlignment', 'Left', ...
        'Tag', ['export_editbox' num2str(i)], ...
        'Userdata', i, ...
        'Enable', enabState, ...
        'Callback', {cbs.edit, hXP});
end

set(hXP, 'Handles', h);

update_editboxes(hXP);

% [EOF]
