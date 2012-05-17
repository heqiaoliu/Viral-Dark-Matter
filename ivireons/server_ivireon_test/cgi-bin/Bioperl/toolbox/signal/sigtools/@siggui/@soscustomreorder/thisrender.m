function thisrender(this, varargin)
%THISRENDER   Render the custom reorder frame.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 08:17:01 $

pos = parserenderinputs(this, varargin{:});

sz = gui_sizes(this);
if isempty(pos), pos = [10 10 200 200]*sz.pixf; end

hFig = get(this, 'FigureHandle');

y = pos(2)+pos(4);

numpos = [pos(1) pos(2)+pos(4)-sz.uh-sz.uuvs pos(3) sz.uh];

rendercontrols(this, numpos, 'numeratororder', fdatoolmessage('NumeratorOrder'));

npos = getpixelpos(this, 'numeratororder');

h = get(this, 'Handles');

h.denominator_lbl = uicontrol(hFig, ...
    'Style', 'Text', ...
    'HorizontalAlignment', 'Left', ...
    'Visible', 'Off', ...
    'String', fdatoolmessage('DenominatorOrder'), ...
    'Position', numpos-[-sz.hfus sz.uh+sz.uuvs*1.5 2*sz.hfus 0]);
h.scalevalues_lbl = uicontrol(hFig, ...
    'Style', 'Text', ...
    'HorizontalAlignment', 'Left', ...
    'Visible', 'Off', ...
    'String', fdatoolmessage('ScaleValuesOrder'), ...
    'Position', numpos-[-sz.hfus sz.uh*4+sz.uuvs*3 2*sz.hfus 0]);

set(this, 'Handles', h);

% Render the selectors first so that they will be "under" the edit boxes.
hden = getcomponent(this, 'tag', 'denominator');
render(hden, hFig, [pos(1)+sz.hfus y-sz.uh-sz.uuvs*1.75 pos(3)-sz.hfus*2 1], ...
    [pos(1) y-sz.uh*4-sz.uuvs*3 pos(3) sz.uh*2+sz.uuvs], npos(3)+6*sz.pixf)
hsv  = getcomponent(this, 'tag', 'scalevalues');
render(hsv, hFig, [pos(1)+sz.hfus y-sz.uh*3-sz.uuvs*5 pos(3)-sz.hfus*2 1], ...
    [pos(1) y-sz.uh*6-sz.uuvs*6.5 pos(3) sz.uh*2+sz.uuvs], npos(3)+6*sz.pixf)

l = [ ...
        handle.listener(hden, 'NewSelection', @enable_listener); ...
        handle.listener(hsv, 'NewSelection', @enable_listener); ...
    ];
set(l, 'CallBackTarget', this);
set(this, 'WhenRenderedListeners', union(this.WhenRenderedListeners, l));

enable_listener(this);

% [EOF]
