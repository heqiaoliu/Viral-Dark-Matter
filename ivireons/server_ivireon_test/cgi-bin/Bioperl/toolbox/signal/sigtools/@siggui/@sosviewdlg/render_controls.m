function render_controls(this)
%RENDER_CONTROLS   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:26:40 $

sz = dialog_gui_sizes(this);

h = getcomponent(this, '-class', 'siggui.selector');

sz.controls(4) = sz.controls(4)-sz.vfus*2;

cpos = sz.controls;
cpos(2) = cpos(2)+2*sz.uh+2*sz.uuvs;
cpos(4) = cpos(4)-2*sz.uh-2*sz.uuvs;

render(h, this.FigureHandle, sz.controls, cpos);

cpos = sz.controls;
cpos(2) = cpos(2)+sz.vfus;
cpos(4) = sz.uh*2+2*sz.uuvs;

rendercontrols(this, cpos, {'custom', 'secondaryscaling'}, {'', 'Use secondary-scaling points'});

l = handle.listener(h, 'NewSelection', @newselection_listener);
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', union(this.WhenRenderedListeners, l));

newselection_listener(this);

% Turn all the children on since this is a dialog.
set(handles2vector(this), 'Visible', 'On');
set(h, 'Visible','on');

% [EOF]
