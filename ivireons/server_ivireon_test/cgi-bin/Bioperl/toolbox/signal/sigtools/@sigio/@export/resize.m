function resize(this, varargin)
%RESIZE Resize the export dialog

% This should be a private method

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/03/13 19:50:40 $

hFig  = get(this,'FigureHandle');
figPos = get(hFig,'Position');

sz = export_gui_sizes(this, varargin{:});

% New figure position.
set(hFig,'Position', [figPos(1:2) sz.fig(3:4)]);

h = get(this, 'Handles');

% set(h.xp2Fr(1), 'Units', 'Pixels', 'Position', sz.xp2fr)
framewlabel(h.xp2Fr, sz.xp2fr);

set(h.xp2popup, 'Units', 'Pixels', 'Position', sz.xp2popup)

hd = get(this, 'DialogHandles');

delete([hd.action hd.close]);

if isfield(hd, 'help')
    delete(hd.help);
end

render_buttons(this);

% [EOF]
