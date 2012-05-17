function render_controls(this)
%RENDER_CONTROLS Render the controls for the dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2009/01/05 18:00:33 $

render_settings(this);
render_management(this);
attachlisteners(this);
index_listener(this);
backupnames_listener(this);

% ---------------------------------------------------------------------
function render_management(this)

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = dfiltwfsdlg_gui_sizes(this);

lbl = 'Filter name:';
sz.mlabel(3) = largestuiwidth({lbl});

h.mframe = uicontrol(hFig, 'style', 'frame', 'Position', sz.mframe);
h.combo  = sigcombobox('Parent', hFig, ...
    'Position', sz.popup, ...
    'String', {'Test'}, ...
    'Max', 0, ...
    'Callback', {@popup_cb, this});
h.editbox = uicontrol(hFig, ...
    'Style', 'edit', ...
    'Position', sz.popup - [0 3*sz.pixf sz.rbwTweak -3*sz.pixf], ...
    'String', 'Test', ...
    'HorizontalAlignment', 'Left', ...
    'Max', 0, ...
    'Callback', {@edit_cb, this});
h.poplbl = uicontrol(hFig, ...
    'style', 'text', ...
    'HorizontalAlignment', 'Left', ...
    'Position', sz.mlabel, ...
    'String', lbl);

setenableprop(h.editbox, 'On');

set(this, 'Handles', h);

% ---------------------------------------------------------------------
function render_settings(this)

h    = get(this, 'Handles');
hFig = get(this, 'FigureHandle');
sz   = dfiltwfsdlg_gui_sizes(this);

h.sframe = uicontrol(hFig, 'Style', 'Frame', 'Position', sz.sframe);

hfs = getcomponent(this, '-class', 'siggui.fsspecifier');
render(hfs, hFig, sz.fsspec);
set(hfs, 'Visible', 'On');
delete(hfs.Handles.fstitle);

lbls = {xlate('Save as Default'), xlate('Restore Original Defaults')};

width(1) = largestuiwidth(lbls(1), 'pushbutton')+sz.pixf;
width(2) = largestuiwidth(lbls(2), 'pushbutton')+sz.pixf;

b1pos = [sz.button width(1) sz.bh];
b2pos = [sz.button+[width(1)+sz.hfus 0] width(2) sz.bh];

h.button = uicontrol(hFig, ...
    'Style', 'PushButton', ...
    'Position', b1pos, ...
    'String', lbls{1}, ...
    'Callback', {@saveas_cb, this});

h.button(2) = uicontrol(hFig, ...
    'Style', 'PushButton', ...
    'Position', b2pos, ...
    'String', lbls{2}, ...
    'Callback', {@restore_cb, this});

set(this, 'Handles', h);

% ---------------------------------------------------------------------
function attachlisteners(this)

h = get(this, 'Handles');

hfs  = getcomponent(this, '-class', 'siggui.fsspecifier');

l = [ ...
        handle.listener(this, this.findprop('BackupFs'), ...
        'PropertyPostSet', @lclbfs_listener); ...
        handle.listener(this, this.findprop('BackupNames'), ...
        'PropertyPostSet', @lclbnames_listener); ...
        handle.listener(this, this.findprop('Index'), ...
        'PropertyPreSet', @lclindex_listener); ...
        handle.listener(hfs, 'UserModifiedSpecs', @lclfs_listener); ...
    ];

this.PopupListener = addlistener(h.combo, 'String', 'PostSet', ...
    @(h, ev) popup_listener(this, ev));

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% ---------------------------------------------------------------------
%   Callbacks
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
function edit_cb(hcbo, eventStruct, this)

setname(this, get(hcbo, 'String'), 1);

% ---------------------------------------------------------------------
function popup_cb(hcbo, eventStruct, this)

val = get(hcbo, 'Value') - 1;

set(this, 'Index', val);

% ---------------------------------------------------------------------
function saveas_cb(hcbo, eventStruct, this)

hfs = getcomponent(this, '-class', 'siggui.fsspecifier');
fs  = getfs(hfs);
if isempty(fs.value)
    fs = [];
else
    fs  = convertfrequnits(fs.value, fs.units, 'Hz');
end

setpref('SignalProcessingToolbox', 'DefaultFs', fs);

% ---------------------------------------------------------------------
function restore_cb(hcbo, eventStruct, this)

restore(this);


% ---------------------------------------------------------------------
%   Listeners
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
function lclindex_listener(this, eventData)

index_listener(this, eventData);

% ---------------------------------------------------------------------
function lclfs_listener(this, eventData)

fs_listener(this, eventData);

% ---------------------------------------------------------------------
function lclbfs_listener(this, eventData)

backupfs_listener(this, eventData);

% ---------------------------------------------------------------------
function lclbnames_listener(this, eventData)

backupnames_listener(this, eventData);

% [EOF]
