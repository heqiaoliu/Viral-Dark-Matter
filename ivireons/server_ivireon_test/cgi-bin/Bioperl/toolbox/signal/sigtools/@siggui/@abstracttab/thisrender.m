function thisrender(this, varargin)
%THISRENDER   Render the tab.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/12/26 22:20:41 $

pos = parserenderinputs(this, varargin{:});

sz = gui_sizes(this);
if isempty(pos), pos = getdefaultposition(this); end

% Include the offset.
offset = getpanelinset(this);
offset = offset(:)';  % Make sure that the offset is a row.
pos = pos + [offset(1:2) -offset(1:2)-offset(3:4)];

hFig = get(this, 'FigureHandle');

lbls    = gettablabels(this);
ntabs   = length(lbls);
cshtags = gettabcshtags(this);

tabshift = gettabshift(this);

for indx = 1:length(lbls)
    tabwidth(indx) = largestuiwidth(lbls(indx));
end

% Put up the buttons
buttonpos = [0 pos(2)+pos(4)-sz.bh-4*sz.pixf 0 sz.bh+2*sz.pixf];
if strcmpi(this.TabAlignment, 'left')
    buttonpos(1) = pos(1)+tabshift;
else
    buttonpos(1) = pos(1)+pos(3)-sum(tabwidth)-12*ntabs*sz.pixf-2*sz.pixf;
end

for indx = 1:ntabs
    
    % Start the buttons off 2 pixels. This makes it look better.
    buttonpos(1) = buttonpos(1)+buttonpos(3)+2*sz.pixf;
    buttonpos(3) = tabwidth(indx)+10*sz.pixf;
    
    h.tabbuttons(indx) = uipanel('Parent', hFig, ...
        'Units', 'Pixels', ...
        'ButtondownFcn', {@tabbutton_cb, this, indx}, ...
        'Visible', 'Off', ...
        'Position', buttonpos);
    h.tablabels(indx) = uicontrol(h.tabbuttons(indx), ...
        'Style', 'Text', ...
        'String', lbls{indx}, ...
        'Position', [1 2 buttonpos(3)-4 16], ...
        'ButtondownFcn', {@tabbutton_cb, this, indx});
    
    if length(cshtags) >= indx
        cshelpcontextmenu([h.tabbuttons(indx) h.tablabels(indx)], cshtags{indx}, 'fdatool');
    end
end

% Put up the panel
tabpanelpos = pos - [0 0 0 sz.bh+1];
h.tabpanel = uipanel('Parent', hFig, ...
    'Units', 'Pixels', ...
    'Visible', 'Off', ...
    'Position', tabpanelpos);

% Put up the button covers
buttonpos(3) = 0;
if strcmpi(this.TabAlignment, 'left')
    buttonpos(1) = pos(1)+tabshift;
else
    buttonpos(1) = pos(1)+pos(3)-sum(tabwidth)-12*ntabs*sz.pixf-2*sz.pixf;
end
buttonpos(2) = buttonpos(2)+1;
for indx = 1:length(lbls)
    
    buttonpos(1) = buttonpos(1)+buttonpos(3)+3*sz.pixf;
    buttonpos(3) = tabwidth(indx)+9*sz.pixf;
    h.tabcovers(indx) = uipanel('Parent', hFig, ...
        'Units', 'Pixels', ...
        'Visible', 'Off', ...
        'HitTest', 'Off', ...
        'BorderType', 'etchedout', ...
        'Position', [buttonpos(1) buttonpos(2) 2 2]);
end

set(this, 'TabHandles', h);

renderpanels(this, tabpanelpos);

l = [ ...
    handle.listener(this, this.findprop('CurrentTab'), ...
        'PropertyPostSet', @currenttab_listener); ...
    handle.listener(this, this.findprop('DisabledTabs'), ...
        'PropertyPostSet', @disabledtabs_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', union(l, this.WhenRenderedListeners));

disabledtabs_listener(this);
currenttab_listener(this);

% ---------------------------------------------------------------------
function tabbutton_cb(hcbo, eventStruct, this, indx)

if any(indx == this.DisabledTabs) || ...
        strcmpi(get(ancestor(hcbo, 'figure'), 'SelectionType'), 'alt')
    return;
end

set(this, 'CurrentTab', indx);

% ---------------------------------------------------------------------
function disabledtabs_listener(this, eventData)

h = get(this, 'TabHandles');

for indx = 1:length(h.tabbuttons)
    if any(indx == this.DisabledTabs) || strcmpi(this.Enable, 'Off')
        enab = 'off';
    else
        enab = 'inactive';
    end
    set(h.tablabels(indx), 'Enable', enab);
end

% ---------------------------------------------------------------------
function currenttab_listener(this, varargin)

ontab = this.CurrentTab;
lbls  = gettablabels(this);
h     = get(this, 'TabHandles');

for indx = 1:length(lbls)
    origUnits = get(h.tablabels(indx), 'Units');
    set(h.tablabels(indx), 'Units', 'Pixels');
    pos = get(h.tablabels(indx), 'Position');
    if indx == ontab
        pos(2) = 0;
        pos(4) = 18;
    else
        pos(2) = 2;
        pos(4) = 16;
    end
    set(h.tablabels(indx), 'Position', pos, 'Units', origUnits);
end   

visible_listener(this, varargin{:});

% [EOF]
