function varargout = contextmenu(hPrm, h)
%CONTEXTMENU Create a context menu for the parameter
%   CONTEXTMENU(hPRM, H) create a context menu for the parameter hPRM on
%   the HG object H.  This function only works for parameter objects whose
%   'ValidValues' is a string vector (a cell of strings).
%
%   This function also maintains the check state of the UIMenus beneath the
%   contextmenu.  If a context menu already exists for the HG object, the 
%   UIMenus will be added to it with a separator.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2009/01/05 18:00:21 $

error(nargchk(2,2,nargin,'struct'));

msg = validate_inputs(hPrm, h);
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

[hc, sep] = addcsmenu(h);
labels    = get(hPrm, 'ValidValues');

% Loop over the labels and create menu items
for i = 1:length(labels)
    hm(i) = uimenu('Parent', hc, ...
        'Label', xlate(labels{i}), ...
        'Tag', labels{i}, ...
        'Callback', {@selection_cb, hPrm});
    
    % If the current label matches the value check it.
    if strcmpi(labels{i}, get(hPrm, 'Value')),
        set(hm(i), 'Check', 'On');
    end
end

set(hm(1), 'Separator', sep);

% Add a listener to the NewValue event cb which will maintain the check state
l = [ ...
        handle.listener(hPrm, 'NewValue', @newvalue_eventcb); ...
        handle.listener(hPrm, hPrm.findprop('DisabledOptions'), ...
        'PropertyPostSet', @lcldisabledoptions_listener); ...
        handle.listener(hPrm, 'NewValidValues', @newvalidvalues_eventcb); ...
    ];
set(l, 'CallbackTarget', hm);
setappdata(hm(1), 'NewValueEventListener', l);

set(h, 'UIContextMenu', hc);

if nargout,
    varargout = {hc, hm};
end

% -------------------------------------------------------------------
function newvalidvalues_eventcb(hm, eventData)

vv = get(eventData.Source, 'ValidValues');

for indx = 1:length(hm)
    set(hm(indx), 'Label', xlate(vv{indx}), 'tag', vv{indx});
end

% -------------------------------------------------------------------
function lcldisabledoptions_listener(hm, eventData)

hObj = get(eventData, 'AffectedObject');

set(hm, 'Visible', 'Off');

vv = get(hObj, 'ValidValues');

for indx = 1:length(vv),
    set(findobj(hm, 'Label', vv{indx}), 'Visible', 'On');
end

% -------------------------------------------------------------------
function newvalue_eventcb(hm, eventData)

set(hm, 'Check', 'Off');
indx = find(strcmpi(get(eventData.Source, 'Value'), get(hm, 'Tag')));

set(hm(indx), 'Check', 'On');

% -------------------------------------------------------------------
function selection_cb(hcbo, eventStruct, hPrm, hm)

setvalue(hPrm, get(hcbo, 'Tag'));

% -------------------------------------------------------------------
function msg = validate_inputs(hPrm, h)
% Validate the inputs

msg = '';

if length(hPrm) ~= 1,
    msg = 'Only one parameter object can be specified.';
end

labels = get(hPrm, 'ValidValues');

if ~iscellstr(labels),
    msg = 'Parameter object''s Valid Values must be a cell of strings';
end

if ~ishghandle(h),
    msg = 'A handle must be specified.';
end

% [EOF]
