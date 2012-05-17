function thisrender(this, hFig, pos, lblwidth, type)
%THISRENDER  Render the labels and values uicontrols
%   It is assumed that this is not going be rendered by itself
%   and so it is safe to call upon the figure and frame as already
%   existing.
%
%   THISRENDER(H, HFIG, POS, LBLWIDTH, TYPE)

%   Author(s): Z. Mecklai
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.10 $  $Date: 2007/12/14 15:18:59 $

error(nargchk(3,5,nargin,'struct'));

% Store the figure handle
set(this, 'FigureHandle', hFig);

m   = get(this, 'Maximum');
sz  = gui_sizes(this);

width = pos(3);

if nargin < 4, lblwidth = 40*sz.pixf; end
if nargin < 5, type = false; end

valwidth = min(lblwidth, width-lblwidth);

left = width-lblwidth-valwidth;
lblwidth = lblwidth+left*.15;
valwidth = valwidth+left*.85;

lblpos  = [pos(1) pos(2)+pos(4) lblwidth sz.uh];
editpos = [pos(1)+lblpos(3) lblpos(2) valwidth sz.uh];
lblpos(2) = lblpos(2)-sz.lblTweak;

if type,
    skip = (pos(4)-m*sz.uh)/(m+1);
else
    if m == 1, skip = 0; 
    else       skip = (pos(4)-m*sz.uh)/m; end
    lblpos(2) = lblpos(2)+skip;
    editpos(2) = editpos(2)+skip;
end
commonprops = {'HorizontalAlignment', 'Left', 'Visible', 'Off'};

% Make the labels take up all the "skipped" space.  In this way we can
% prevent as much clipping of translated text as possible.
lblpos(2) = lblpos(2)-skip; lblpos(4) = lblpos(4)+skip;

for indx = 1:m
    lblpos(2)  = lblpos(2)-skip-sz.uh;
    editpos(2) = editpos(2)-skip-sz.uh;
    
    h.labels(indx) = uicontrol(hFig, commonprops{:}, ...
        'Position', lblpos, ...
        'Tag', sprintf('label%d', indx), ... 
        'Style', 'Text');
    h.values(indx) = uicontrol(hFig, commonprops{:}, ...
        'Position', editpos, ...
        'Style', 'Edit', ...
        'BackgroundColor', 'w', ...
        'Tag', sprintf('value%d', indx), ...
        'Callback', {@value_cb, this, indx});

    setappdata(h.values(indx), 'index', indx);
end

set(this, 'Handles', h);

l = [ ...
        handle.listener(this, [this.findprop('values'), this.findprop('labels'), ...
        this.findprop('HiddenValues') this.findprop('HiddenLabels')], ...
        'PropertyPostSet', @values_labels_listener);
        handle.listener(this, this.findprop('DisabledValues'), 'PropertyPostSet', ...
        @disabledvalues_listener) ...
    ];

set(l,'CallbackTarget',this)

% Store the listeners in the WhenRenderedListeners property of the superclass
this.WhenRenderedListeners = l;

values_labels_listener(this);
enable_listener(this);

% -------------------------------------------------------------------------
function values_labels_listener(this, eventData) %#ok

if strcmpi(this.Visible, 'on'), update_uis(this); end

% -------------------------------------------------------------------------
function disabledvalues_listener(this, eventData) %#ok

enable_listener(this);

% -------------------------------------------------------------------------
function value_cb(hcbo, eventData, this, indx) %#ok

vals = get(this, 'Values');
vals(indx) = fixup_uiedit(hcbo);
set(this, 'Values', vals);
send(this, 'UserModifiedSpecs', handle.EventData(this, 'UserModifiedSpecs'));

% [EOF]
