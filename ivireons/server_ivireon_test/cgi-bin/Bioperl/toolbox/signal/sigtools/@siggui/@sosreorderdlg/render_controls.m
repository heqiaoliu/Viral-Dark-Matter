function render_controls(this)
%RENDER_CONTROLS   Render the controls for the reorder dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/05/23 08:17:02 $

sz = dialog_gui_sizes(this);

if ispc,
    leftwidth = 285*sz.pixf;
else
    leftwidth = 330*sz.pixf;
end

leftpos = [sz.controls(1) sz.controls(2)+sz.bh+sz.vfus ...
    leftwidth sz.controls(4)-sz.vfus-sz.bh-2*sz.vfus];

rightpos = [leftpos(1)+leftpos(3)+sz.hfus leftpos(2) ...
    sz.controls(3)-leftpos(1)-leftpos(3) leftpos(4)];

% Put up a frame to go around the controls.
framewlabel(this, leftpos, fdatoolmessage('ReorderingLabel'));
framewlabel(this, rightpos, fdatoolmessage('ScalingLabel'));
set(handles2vector(this), 'Visible', 'On'); % HG BUG

hFig = get(this, 'FigureHandle');

ho = getcomponent(this, 'overall');
hc = getcomponent(this, 'custom');

y = leftpos(2)+leftpos(4);
h = sz.uh*4+sz.uuvs*3;

render(ho, hFig, [], [leftpos(1) y-h-sz.vfus leftpos(3) h]);
render(hc, hFig, leftpos(1:4)+[sz.uh 0 -2*sz.hfus -h]);

set(ho, 'Visible', 'On');
set(hc, 'Visible', 'On');

renderactionbtn(this, sz.controls-[0 sz.vfus 0 0], fdatoolmessage('RevertToOriginalFilter'), 'revert');

props = {'scale','maxnumerator', 'numeratorconstraint', 'overflowmode', ...
    'scalevalueconstraint','maxscalevalue'};
labels = {fdatoolmessage('ScaleLabel'), fdatoolmessage('MaximumNumerator'), ...
    fdatoolmessage('NumeratorConstraint'), fdatoolmessage('OverflowMode'), ...
    fdatoolmessage('ScaleValueConstraint'), fdatoolmessage('MaxScaleValue')};

rendercontrols(this, rightpos - [0 0 0 sz.uh*3], props, labels);

pos = getpixelpos(this, 'scale');
pos(2) = rightpos(2)+rightpos(4)-sz.uh-sz.vfus*2;
setpixelpos(this, 'scale', pos);

h = get(this, 'Handles');

% Internationalize the popups.  This is not handled by rendercontrols.
set(h.numeratorconstraint, 'String', { ...
    fdatoolmessage('ScaleNone'), ...
    fdatoolmessage('ScaleUnit'), ...
    fdatoolmessage('ScaleNormalize'), ...
    fdatoolmessage('ScalePowersOfTwo')});

set(h.overflowmode, 'String', { ...
    fdatoolmessage('OverflowWrap'), ...
    fdatoolmessage('OverflowSaturate')});

set(h.scalevalueconstraint, 'String', { ...
    fdatoolmessage('ScaleNone'), ...
    fdatoolmessage('ScaleUnit'), ...
    fdatoolmessage('ScalePowersOfTwo')});

pos(2) = pos(2)-2*sz.uh-sz.uuvs-5*sz.pixf;
pos(3) = rightpos(3)-2*sz.hfus;

norms = {'l1', 'Linf', 'L2', 'L1', 'linf'};
for indx = 1:5
    h.pnorm_tick_lbl(indx) = uicontrol(hFig, ...
        'Style','text', ...
        'Position', [pos(1)+indx*39*sz.pixf-25*sz.pixf pos(2)+pos(4)*1.5 pos(3)/6 sz.uh], ...
        'String', norms{indx});
    h.pnorm_tick(indx) = uicontrol(hFig, ...
        'Style', 'Frame', ...
        'Position', [pos(1)+indx*39*sz.pixf-5*sz.pixf pos(2) 1 pos(4)*1.5]);
end

h.pnorm = uicontrol(hFig, ...
    'Style', 'Slider', ...
    'Position', pos, ...
    'Min', 1, ...
    'Max', 5, ...
    'Callback', {@slider_cb, this}, ...
    'SliderStep', [.25 .25], ...
    'Value', get(this, 'PNorm'));

pos(2) = pos(2)-sz.uh;
if ~ispc, pos(2) = pos(2)-3*sz.pixf; end

h.pnorm_lbl(1) = uicontrol(hFig, ...
    'Style', 'Text', ...
    'Position', [pos(1:2) pos(3)/2 pos(4)], ...
    'HorizontalAlignment', 'Left', ...
    'String', fdatoolmessage('LessOverflow'));

h.pnorm_lbl(2) = uicontrol(hFig, ...
    'Style', 'Text', ...
    'Position', [pos(1)+pos(3)/2 pos(2) pos(3)/2 pos(4)], ...
    'HorizontalAlignment', 'Right', ...
    'String', fdatoolmessage('HighestSNR'));

h.pnorm_lbl = h.pnorm_lbl(:);

set(this, 'Handles', h);

% It's a dialog so make all of its children visible.
set(handles2vector(this), 'Visible', 'On');

l = [ ...
        this.WhenRenderedListeners(:); ...
        handle.listener(ho, 'NewSelection', @enable_listener); ...
        handle.listener(this, this.findprop('PNorm'), 'PropertyPostSet', ...
        @pnorm_listener); ...
        handle.listener(this, [this.findprop('ScaleValueConstraint') ...
        this.findprop('Scale') this.findprop('Filter')], 'PropertyPostSet', ...
        @enable_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

enable_listener(this);

% -------------------------------------------------------------------------
function pnorm_listener(this, ~)

h = get(this, 'Handles');

set(h.pnorm, 'Value', get(this, 'PNorm'));

% -------------------------------------------------------------------------
function slider_cb(hcbo, ~, this)

set(this, 'PNorm', round(get(hcbo, 'Value')));

% [EOF]
