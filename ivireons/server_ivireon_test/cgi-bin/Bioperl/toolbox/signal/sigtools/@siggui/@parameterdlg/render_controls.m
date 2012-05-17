function render_controls(this)
%RENDER_CONTROLS Render the controls for the parameter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.4 $  $Date: 2007/03/13 19:50:32 $

% This should be a private method

render_frame(this);
render_parameters(this);
render_buttons(this);
update_uis(this);


% ----------------------------------------------------------------
function render_parameters(this)

hPrm = get(this, 'Parameters');
sz   = parameter_gui_sizes(this);
hFig = get(this, 'FigureHandle');
h    = get(this, 'Handles');

if ~isempty(hPrm),
    
    pos = [2*sz.hfus sz.frame(2)+2*sz.uuvs+sz.bh sz.fig(3)-4*sz.hfus sz.uh];
    
    % Render the parameters with autoupdate off.
    h.controls = render(hPrm, hFig, pos, 0);
    
    listen = handle.listener(hPrm, 'UserModified', @usermodified_eventcb);
    set(listen, 'CallbackTarget', this);
    set(this, 'UserModifiedListener', listen);
    
    setenableprop([h.controls.edit h.controls.specpopup], this.Enable);
    set([h.controls.label], 'Enable', this.Enable);
    
    set(this, 'isApplied', 1);
    
    set(this, 'Handles', h);
        
    % Call the listener to sync the enable states.
    dialog_enable_listener(this,[]);
else
    h.controls   = [];
    h.noparamtxt = uicontrol(hFig, ...
        'Position', sz.frame - [-sz.hfus -sz.vfus 2*sz.hfus 3.5*sz.vfus], ...
        'String', xlate('There are currently no parameters to set.'), ...
        'Style', 'Text');
    set(this, 'Handles', h);
    
    set(convert2vector(rmfield(this.DialogHandles, 'cancel')), 'Enable', 'Off');
end

% Install Listeners
install_listeners(this);

% -------------------------------------------------------------------
function render_frame(this)

sz   = parameter_gui_sizes(this);
hFig = get(this, 'FigureHandle');

h = get(this, 'Handles');

lbl = this.Label;

if isempty(lbl), lbl = ' '; end

h.frame = framewlabel(hFig, sz.frame, lbl, ...
    'parameterdialog_frame', get(0,'defaultuicontrolbackgroundcolor'));

if isempty(this.Label), set(h.frame(2), 'Visible', 'Off'); end

set(this, 'Handles', h);


% ----------------------------------------------------------------
function install_listeners(this)

oldlisten = get(this, 'WhenRenderedListeners');

% If there are any listeners, then there is no reason to create new ones.
if length(oldlisten)
    return;
end

listen = [ ...
        handle.listener(this, this.findprop('Name'), ...
        'PropertyPostSet', @name_listener); ...
        handle.listener(this, this.findprop('Label'), ...
        'PropertyPostSet', @label_listener); ...
        handle.listener(this, this.findprop('Parameters'), ...
        'PropertyPostSet', @parameters_listener); ...
        handle.listener(this, [this.findprop('DisabledParameters'), ...
        this.findprop('StaticParameters')], 'PropertyPostSet', @update_uis); ...
    ];

set(listen, 'CallbackTarget', this);

set(this, 'WhenRenderedListeners', listen);

% -------------------------------------------------------------------
function render_buttons(this)

if isempty(this.Parameters), return; end

sz   = parameter_gui_sizes(this);
hFig = get(this, 'FigureHandle');
cbs  = siggui_cbs(this);

h = get(this, 'Handles');

pos = [sz.frame(1)+sz.hfus sz.frame(2)+sz.uuvs sz.makedefault sz.bh];
h.makedefault = uicontrol(hFig, ...
    'Style', 'Pushbutton', ...
    'Position', pos, ...
    'Callback', {cbs.method, this, 'makedefault'}, ...
    'String', xlate('Save as Default'), ...
    'Visible', 'On');

pos = [pos(1)+pos(3)+sz.uuhs pos(2) sz.restore sz.bh];
h.restoredefault = uicontrol(hFig, ...
    'Style', 'Pushbutton', ...
    'Position', pos, ...
    'Callback', {@lclRestoreOriginalValues, this}, ...
    'String', xlate('Restore Original Defaults'), ...
    'Visible', 'On');

set(this, 'Handles', h);

% -------------------------------------------------------------------
function lclRestoreOriginalValues(hcbo, eventStruct, this)

hPrm = get(this, 'Parameters');

restore(hPrm);

% [EOF]
