function thisrender(this, varargin)
%THISRENDER  Renders this object

%   Author(s): Z. Mecklai
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2007/03/13 19:50:33 $

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'mag'; end

super_render(this, pos);

hFig = get(this, 'FigureHandle');
h    = get(this,'handles');
sz   = gui_sizes(this);

% Render the super class to get the labels and edit boxes
super_render(this, pos);
pos = getpixelpos(this, 'framewlabel', 1);

cbs = callbacks(this);

pos = [pos(1)+sz.hfus pos(2)+pos(4)-sz.vfus pos(3)-2*sz.hfus sz.uh];

for i = 1:6
    pos(2) = pos(2)-(sz.uuvs + sz.uh);

    h.rbs(i) = uicontrol(hFig, 'Style', 'radio',...
        'Visible', 'off',...
        'callback', {cbs.rbc, this},...
        'position', pos);
    setappdata(h.rbs(i), 'Index', i);
end

h.text = uicontrol(hFig, 'style','text',...
    'Visible', 'off',...
    'horizontalalignment','left',...
    'position',pos);
setenableprop(h.text, 'on');

h.divider = uicontrol(hFig, 'Style','frame',...
    'Visible', 'off',...
    'Position', [pos(1) pos(2) - sz.uuvs pos(3) 1]);

setenableprop(convert2vector(h), 'On');

% Store the handles of the uicontrol
set(this, 'handles', h);

% Install the listeners
wrl = handle.listener(this, [this.findprop('Comment') ...
        this.findprop('AllOptions') this.findprop('currentSelection')], ...
    'PropertyPostSet', @lclprop_listener);

set(wrl, 'callbacktarget', this);
set(this, 'WhenRenderedListeners', wrl);

cshelpcontextmenu(this, 'fdatool_ALL_mag_specs_frame');

% ----------------------------------------------------------------
function lclprop_listener(this, eventData)

update_uis(this);

% [EOF]
