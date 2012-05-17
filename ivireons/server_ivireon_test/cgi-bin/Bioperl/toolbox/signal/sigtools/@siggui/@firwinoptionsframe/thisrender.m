function thisrender(this, varargin)
%THISRENDER Render the FIR Options window frame for FDATool.

%   Author(s): V.Pellissier & Z. Mecklai
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.9.4.6 $  $Date: 2009/01/20 15:36:09 $

pos = parserenderinputs(this, varargin{:});
if nargin < 2,
    hFig = gcf;
end

if isempty(pos)
    % Get the gui sizes
    sz = gui_sizes(this);
    pos = sz.pixf.*[217, 55, 178, 133-(sz.vffs/sz.pixf)];
end

framewlabel(this, pos, 'Options');
renderactionbtn(this, pos-[0 2*sz.pixf 0 0], 'View', 'view');

%reduce the buttom height
H = get(this,'Handles');
P = get(H.view, 'Position');
set(H.view, 'Position', P);

rendercontrols(this, pos + [0 sz.uh+2*sz.pixf 0 -sz.uh], ...
    {'Scale', 'Window', 'Parameter', 'Parameter2'});

% Add context-sensitive help
cshelpcontextmenu(this, 'fdatool_firwin_options_frame');

l = [ this.WhenRenderedListeners; ...
    handle.listener(this, this.findprop('privWindow'), ...
    'PropertyPostSet', @(h, ev) updateparameter(this)); ...
    handle.listener(this, this.findprop('isMinOrder'), ...
    'PropertyPostSet', @(h, ev) updateparameter(this)); ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% [EOF]