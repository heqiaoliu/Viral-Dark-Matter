function render_controls(hFs)
%RENDER_CONTROLS Render the controls on the FsDialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 23:25:26 $

sz   = fsdialog_gui_sizes(hFs);
hFig = get(hFs, 'FigureHandle');

% Render a frame for the specifier
y = sz.bh+sz.vfus+sz.uuvs;
frPos = [sz.hfus y sz.figpos(3)-2*sz.hfus sz.figpos(4)-y-2*sz.vfus];
uicontrol(hFig, 'Position', frPos, 'tag', 'sampfreq', 'style','frame');

% Render the specifier
fsh = getcomponent(hFs, '-class', 'siggui.fsspecifier');
render(fsh, hFig, sz.specifier);
set(hFig, 'Position', [300 300 770 549]*sz.pixf);
setunits(fsh, 'pixels');
set(hFig, 'Position', sz.figpos);

% The specifier is always visible, since the visibility of the dialog is
% at the level of the figure
set(fsh, 'Visible', 'On');
set(hFs, 'isApplied', 1);

% Install Listeners
install_listeners(hFs)


% -----------------------------------------------------------
function install_listeners(hFs)

fsh = getcomponent(hFs, '-class', 'siggui.fsspecifier');

l    = handle.listener(fsh, [fsh.findprop('Value'), fsh.findprop('Units')], ...
    'PropertyPostSet', @specifier_listener);
set(l, 'CallbackTarget', hFs)

set(hFs, 'WhenRenderedListeners', l);


% [EOF]
