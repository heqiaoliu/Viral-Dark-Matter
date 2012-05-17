function render_controls(hXP)
%RENDER_CONTROLS Render the controls for the export dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2007/03/13 19:50:30 $

% Render the individual components
render_target_popup(hXP);

if ~isempty(get(hXP, 'Objects')),
    render_exportas_popup(hXP);
end
render_variable_frame(hXP);
render_labels(hXP);
render_editboxes(hXP);

% Update the components
update_popup(hXP);

% Install Listeners
install_listeners(hXP);

% ---------------------------------------------------------------------
function render_exportas_popup(hXP)

h    = get(hXP,'Handles');
hFig = get(hXP,'FigureHandle');
sz   = export_gui_sizes(hXP);
cbs  = callbacks(hXP);

h.aframe = framewlabel(hFig, sz.aframe, 'Export As', 'exportas');

h.apopup = uicontrol(hFig, ...
    'Style', 'Popup', ...
    'Position', sz.apopup, ...
    'Tag', 'exportas_popup', ...
    'Callback', {cbs.exportas, hXP}, ...
    'String', set(hXP, 'ExportAs'));

setenableprop(h.apopup, hXP.Enable);

set(hXP, 'Handles', h);


% --------------------------------------------------------------------
function render_target_popup(hXP)

h    = get(hXP,'Handles');
hFig = get(hXP,'FigureHandle');
sz   = export_gui_sizes(hXP);
cbs  = callbacks(hXP);

% Render the popup frame
h.frame = framewlabel(hFig, sz.tframe, 'Export To', 'exportto', get(hFig, 'Color'));

% Render the popup.  Use the export options as the string
h.popup = uicontrol(hFig, ...
    'Style','Popup', ...
    'Position', sz.tpopup, ...
    'Tag', 'export_popup', ...
    'Callback', {cbs.popup, hXP}, ...
    'String', set(hXP,'ExportTarget'));

% Use setenableprop to gray out the background if necessary
setenableprop(h.popup, hXP.Enable);

set(hXP,'Handles',h);


% --------------------------------------------------------------------
function render_variable_frame(hXP)

h    = get(hXP, 'Handles');
hFig = get(hXP, 'FigureHandle');
sz   = export_gui_sizes(hXP);
lbls = get(hXP, 'Labels');
targ = get(hXP, 'TargetNames');
cbs  = callbacks(hXP);

% Render the frame and the checkbox
h.vframe = framewlabel(hFig, sz.nframe, 'Variable Names', 'vnames', get(hFig, 'Color'));
h.checkbox = uicontrol(hFig, ...
    'Position', sz.checkbox, ...
    'Style', 'Check', ...
    'Tag', 'export_checkbox', ...
    'Callback', {cbs.checkbox, hXP}, ...
    'String', 'Overwrite Variables');

set(hXP,'Handles',h);

% ---------------------------------------------------------------------
function install_listeners(hXP)

vprop = [hXP.findprop('Variables') hXP.findprop('Objects')];
lprop = [hXP.findprop('Labels') hXP.findprop('ObjectLabels')];
tprop = [hXP.findprop('TargetNames') hXP.findprop('ObjectTargetNames')];

ename = 'PropertyPostSet';

listeners = [ ...
        handle.listener(hXP, vprop, ename, @variables_listener); ...
        handle.listener(hXP, lprop, ename, @labels_listener); ...
        handle.listener(hXP, tprop, ename, @targetnames_listener); ...
        handle.listener(hXP, hXP.findprop('ExportTarget'), ename, @exporttarget_listener); ...
        handle.listener(hXP, hXP.findprop('ExportAs'), ename, @exportas_listener); ...
        handle.listener(hXP, hXP.findprop('Overwrite'), ename, @overwrite_listener); ...
        handle.listener(hXP, [vprop, lprop, tprop], 'PropertyPreSet', @preset_listener); ...
    ];

set(listeners, 'CallbackTarget', hXP);

set(hXP, 'WhenRenderedListeners', listeners);


% [EOF]
