function this = splitpane(hPanel, varargin)
%SPLITPANE   Construct a SPLITPANE object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:20:47 $

error(nargchk(1,inf,nargin,'struct'));

this = siglayout.splitpane;

% Set up the abstract properties.
abstractlayout_construct(this, hPanel, varargin{:});

% Create the 'divider' with a button.
set(this, ...
    'Invalid',       true, ...
    'DividerHandle', uicontrol(hPanel, ...
    'style',         'pushbutton', ...
    'Enable',        'Inactive', ...
    'tag',           'splitpanedivider', ...
    'ButtonDownFcn', {@buttondown_cb, this}));

% Add a listener to the properties that will cause an update.
l = [ ...
    handle.listener(this, [this.findprop('NorthWest') this.findprop('SouthEast') ...
        this.findprop('LayoutDirection') this.findprop('Dominant'), ...
        this.findprop('DominantWidth') this.findprop('DividerWidth')], ...
        'PropertyPostSet', @property_listener); ...
    handle.listener(this, 'ObjectBeingDestroyed', @obd_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'Listeners', l);

update(this);

% -------------------------------------------------------------------------
function obd_listener(this, eventData)

% Clean up by removing the divider.
delete(this.DividerHandle);

% -------------------------------------------------------------------------
function property_listener(this, eventData)

set(this, 'Invalid', true);
update(this);

% -------------------------------------------------------------------------
function buttondown_cb(hDivider, eventStruct, this)

hFig = ancestor(hDivider, 'figure');

if isempty(get(hDivider, 'UserData'))
    set(hDivider, 'UserData', get(hFig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'Pointer'}));
end

% Theoretically the panel's position cannot change until after the buttonup
% function is fired.  Get the position here and pass it as an input.
pos = getpanelpos(this);

if strcmpi(this.LayoutDirection, 'vertical')
    ptr = 'top';
else
    ptr = 'left';
end

set(hFig, ...
    'WindowButtonMotionFcn', {@windowbuttonmotion_cb, this, pos}, ...
    'WindowButtonUpFcn',     {@windowbuttonup_cb,     this}, ...
    'Pointer',               ptr);

% -------------------------------------------------------------------------
function windowbuttonmotion_cb(hFig, eventStruct, this, pos)

cp = get(hFig, 'CurrentPoint');

if strcmpi(this.LayoutDirection, 'vertical')
    maxwidth = pos(4)-6;
    if strcmpi(this.Dominant, 'northwest')
        cp = cp+ceil(this.DividerWidth/2);
        width = pos(4)-cp(2);
    else
        cp = cp-ceil(this.DividerWidth/2);
        width = cp(2);
    end
else
    maxwidth = pos(3)-6;
    if strcmpi(this.Dominant, 'northwest')
        cp = cp-ceil(this.DividerWidth/2);
        width = cp(1);
    else
        cp = cp+ceil(this.DividerWidth/2);
        width = pos(3)-cp(1);
    end
end

set(this, 'DominantWidth', min(maxwidth, max(5, width)));

% -------------------------------------------------------------------------
function windowbuttonup_cb(hFig, eventStruct, this)

set(hFig, {'WindowButtonMotionFcn', 'WindowButtonUpFcn', 'Pointer'}, ...
    get(this.DividerHandle, 'UserData'));
set(this.DividerHandle, 'UserData', []);

set(this, 'Invalid', true);
update(this);

% [EOF]
