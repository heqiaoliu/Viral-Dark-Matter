function thisrender(this, varargin)
%RENDER Renders the ui components of the freqspecs2 class.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/13 00:23:45 $

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'freq'; end

% Call the super classes render method
super_render(this, pos);

sz   = gui_sizes(this);
pos  = getpixelpos(this, 'framewlabel', 1);
hFig = get(this, 'FigureHandle');

% Render the FSSpecifier
render(getcomponent(this, 'siggui.specsfsspecifier'), hFig, pos);

render(getcomponent(this, 'siggui.labelsandvalues'), hFig, ...
    [pos(1)+2*sz.hfus pos(2)+sz.uuvs*1.4 pos(3)-sz.hfus*3.7 pos(4)*.58]);

selpos = [pos(1)+sz.hfus pos(2)+sz.vfus pos(3)-sz.hfus*1.5 pos(4)/3];
hs = getcomponent(this, '-class', 'siggui.selectorwvalues');
render(hs, hFig, [pos(1)+sz.hfus pos(2)+pos(4)/3+sz.vfus pos(3)-2*sz.hfus 1], selpos, 50*sz.pixf);

wrl = get(this, 'WhenRenderedListeners');
wrl = [ wrl, ...
        handle.listener(allchild(this), 'UserModifiedSpecs', ...
        @lclnewselection_listener), ...
        handle.listener(hs, 'NewSelection', ...
        @lclnewselection_listener), ...
        handle.listener(hs, 'NewValues', ...
        @lclnewselection_listener), ...
    ];

set(wrl, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', wrl);

%  Add context sensitive help
cshelpcontextmenu(this, 'fdatool_ALL_freq_specs_frame');

% -------------------------------------------------------------------------
function lclnewselection_listener(this, eventData)

send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

% [EOF]
