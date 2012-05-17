function render_controls(this)
%RENDER_CONTROLS Render the controls for the export dialog

%   Author(s): P. Costa
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2008/08/01 12:25:51 $

h    = get(this,'Handles');
hFig = get(this,'FigureHandle');
sz   = export_gui_sizes(this);
cbs  = callbacks(this);

% Render the popup frame
h.xp2Fr = framewlabel(hFig, sz.xp2fr, 'Export To', 'exportto', get(hFig, 'Color'));

items = get(this,'AvailableDestinations');
% jsun - remove the item from the list. e.g. remove "SPTool" if launched by SPTool
if ~isempty(this.ExcludeItem)
    item_index = find(strcmpi(items, this.ExcludeItem));
    if ~isempty(item_index)
        items(item_index) = [];
    end
end
% Render the popup.  Make sure the callback is not interruptible since
% we'll be creating objects which is time consuming.
h.xp2popup = uicontrol(hFig, ...
    'Style','Popup', ...
    'Interruptible', 'Off', ...
    'Position', sz.xp2popup, ...
    'Tag', 'export_popup', ...
    'Callback', {cbs.popup, this}, ...
    'String', items);

% Use setenableprop to gray out the background if necessary
setenableprop(h.xp2popup, this.Enable);

set(this,'Handles',h);

% Render the contained destination object
render(this.Destination,hFig,sz.xpdestopts);
set(this.Destination,'Visible','On');

% Update the "Export To" popupmenu
update_popup(this);

listeners = [ ...
    handle.listener(this, this.findprop('CurrentDestination'), ...
    'PropertyPostSet', @(h, ed) currentDestination_listener(this)) ...
    handle.listener(this, this.findprop('Destination'), ...
    'PropertyPreSet', @destination_listener) ...
    handle.listener(this, this.findprop('AvailableDestinations'), ...
    'PropertyPostSet', @availabledestinations_listener) ...
    handle.listener(this.Destination, 'NewFrameHeight', @newheight_cb)...
    handle.listener(this.Destination, 'UserModifiedSpecs', @usermodifiedspecs_cb)...
    ];

set(listeners, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', listeners);

cshelpcontextmenu(this,this.CSHelpTag);
cshelpcontextmenu(this.destination,this.CSHelpTag);

% -------------------------------------------------------------------------
function availabledestinations_listener(this, eventData)

h = get(this, 'Handles');

ad = get(this, 'AvailableDestinations');
cd = get(this, 'CurrentDestination');

set(h.xp2popup, ...
    'String', ad, ...
    'Value',  find(strcmpi(ad, cd)));

% [EOF]
