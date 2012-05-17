function render_controls(this)
%RENDER_CONTROLS Render the controls for the SOS dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/13 00:26:17 $ 

hFig = get(this, 'FigureHandle');
sz   = dialog_gui_sizes(this);

framewlabel(this, sz.controls);
rendercontrols(this, sz.controls, {'scale', 'direction'});

set(handles2vector(this), 'Visible', 'On');

h = get(this, 'Handles');

fdaddcontextmenu(hFig, handles2vector(this), 'fdatool_sos_frame');
fdaddcontextmenu(hFig, [h.scale h.direction], 'fdatool_sos_popupmenu');

filter_listener(this);

l = [ ...
        this.WhenRenderedListeners(:); ...
        handle.listener(this, this.findprop('Filter'), ...
        'PropertyPostSet', @filter_listener); ...
    ];

set(l, 'CallbackTarget', this);

set(this, 'WhenRenderedListeners', l);


% [EOF]