function render_exportas(this,pos)
%RENDER_EXPORTAS Render a frame with an "Export As" popup.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/04/11 18:44:25 $

if nargin < 2 , pos =[]; end

hFig = get(this,'FigureHandle');
bgc  = get(0,'defaultuicontrolbackgroundcolor');
cbs  = callbacks(this);
sz   = xp_gui_sizes(this);

% Render the "Export As" frame
if isempty(pos),
    % Default Position
    pos = sz.XpAsFrpos;
else
    % Adjust position (pos is for entire destination options frames)
    ypos = (pos(2)+pos(4))-sz.XpAsFrpos(4);
    pos = [pos(1) ypos pos(3) sz.XpAsFrpos(4)];
end

h    = get(this,'Handles');
if ishandlefield(this, 'xpasfr'),
    framewlabel(h.xpasfr, pos);
else
    h.xpasfr = framewlabel(hFig, pos, 'Export As', 'exportas', bgc, this.Visible);
end

% Render the "Export As" popupmenu
popupwidth = pos(3)-sz.hfus*2;
XpAsPoppos = [pos(1)+sz.hfus pos(2)+sz.vfus*2 popupwidth sz.uh];

if ishandlefield(this, 'exportas'),
    setpixelpos(this, h.exportas, XpAsPoppos);
else
    h.exportas = uicontrol(hFig, ...
        'Style', 'Popup', ...
        'Position', XpAsPoppos, ...
        'Callback', {cbs.exportas, this}, ...
        'Tag', 'exportas_popup', ...
        'Visible', this.Visible, ...
        'HorizontalAlignment', 'Left', ...
        'String', set(this, 'ExportAs'));
    setenableprop(h.exportas, this.Enable);
end

set(this, 'Handles', h);

l = handle.listener(this, this.findprop('ExportAs'), 'PropertyPostSet', @prop_listener);
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

prop_listener(this);

% [EOF]
