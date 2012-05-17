function thisrender(this, varargin)
%THISRENDER   Render the MAGSPECSUL object.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2005/12/22 19:04:24 $

pos = parserenderinputs(this, varargin{:});

hFig = get(this, 'FigureHandle');

if isempty(pos), pos = 'mag'; end

% Render the frame
super_render(this, pos);

hu = getcomponent(this, 'Upper');
hl = getcomponent(this, 'Lower');
sz = gui_sizes(this);

pos = getpixelpos(this, 'framewlabel', 1);

% Render the Upper Labels and Values
pos = [pos(1)+sz.hfus pos(2)+sz.vfus pos(3)*2/3-sz.uuhs-sz.hfus pos(4)-8*sz.vfus];
render(hu, hFig, pos);
render_label(this, pos, 'Upper');

% Render the lower values
pos(1) = pos(1)+pos(3)/2;
render(hl, hFig, pos);
render_label(this, pos, 'Lower');

cshelpcontextmenu(this, 'fdatool_ALL_mag_specs_frame', 'fdatool');

% --------------------------------------------------------------
function render_label(this, pos, str)

h  = get(this, 'Handles');
sz = gui_sizes(this);

lblpos = [pos(1)+pos(3)*.55 pos(2)+pos(4)+sz.uuvs/2 largestuiwidth({str}) sz.uh];
h.([lower(str) '_lbl']) = uicontrol(this.FigureHandle, ...
    'Style', 'Text', ...
    'String', str, ...
    'Position', lblpos, ...
    'HorizontalAlignment', 'Left', ...
    'Visible', 'Off');

set(this, 'Handles', h);

% [EOF]
