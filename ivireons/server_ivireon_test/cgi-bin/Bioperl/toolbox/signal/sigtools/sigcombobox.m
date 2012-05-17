function h = sigcombobox(varargin)
%SIGCOMBOBOX Create a combo box
%   SIGCOMBOBOX('PropertyName1',value1,'PropertyName2',value2,...) creates
%   a combobox user interface control in the current figure window and
%   returns a handle to it.
%
%   SIGCOMBOBOX(FIG,...) creates a combobox in the specified figure.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.7 $  $Date: 2009/01/05 17:59:53 $

% If max == 0, then set the combo box to read only

[h, hedit, msg] = render_sigcombobox(varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

addlisteners(h, hedit);
update(h, hedit);

% ----------------------------------------------------
function [h, hedit, msg] = render_sigcombobox(varargin)

% If the first input is gcf, use it.  This enables the combobox calling API
% to be similar to uicontrol's.
if nargin > 0 && isscalar(varargin{1})
    if ishghandle(varargin{1}, 'figure') || ...
            ishghandle(varargin{1}, 'uipanel') || ...
            ishghandle(varargin{1}, 'uicontainer')
        varargin = {'Parent', varargin{:}};
    end
end

% Draw a popup assuming the inputs are prop-param pairs
h = uicontrol('style', 'popup', varargin{:});

msg = '';
if isempty(get(h, 'String')),
    delete(h);
    hedit = [];
    msg = 'ComboBoxes cannot be empty';
    return;
end

% Create the editbox part of the popup
hFig  = get(h, 'Parent');
hedit = uicontrol(hFig, ...
    'style', 'edit', ...
    'Tag', [get(h, 'Tag') '_editbox'], ...
    'String', lclpopupstr(h), ...
    'HandleVisibility', 'Off', ...
    'HorizontalAlignment', 'Left', ...
    'Callback', @(hcbo, ev) updatepopup(hcbo, h), ...
    'Visible', 'Off');

setappdata(h, 'EditBox', hedit);

% ----------------------------------------------------
function addlisteners(h, hedit)

% We need to sync to all these properties
props = {'Enable' 'Visible' 'String' 'Value' 'Position' 'FontSize' ...
    'FontUnits' 'Max'};

% We need to add a listener to the figure position, incase the popup is set
% to normalized.
addlistener(get(h, 'Parent'), 'ObjectBeingDestroyed', @(hf, ev) destroy_listener(hedit));
addlistener(h, props, 'PostSet', @(hv, ev) prop_listener(hedit, h, ev));
addlistener(get(h, 'Parent'), 'Position', 'PostSet', @(hf, ev) update_position(hedit, h));

% ----------------------------------------------------
function update(h, hedit)

% Update the editbox to match the popup
setenableprop([hedit h], get(h, 'Enable'), false);
set(hedit, 'Visible', get(h, 'Visible'));
set(hedit, 'FontUnits', get(h, 'FontUnits'));
set(hedit, 'FontSize', get(h, 'FontSize'));
maxset(hedit, h);
update_position(hedit, h);

% -------------------------------------------------------
function prop_listener(hedit, hpop, eventData)

prop = get(eventData.Source, 'Name');
nval = get(hpop, prop);

switch lower(prop)
case 'position'
    update_position(hedit, hpop);
case 'fontsize'
    set(hedit, 'fontsize', nval);
    update_position(hedit, hpop);
case {'value', 'string'}
    % This set might fail depending on whether the value makes sense for
    % the string, i.e. the string vector might be set before the value
    if get(hpop, 'Value') <= length(get(hpop, 'String')),
        set(hedit, 'String', lclpopupstr(hpop));
    else
        set(hedit, 'string', '');
    end
case 'enable'
    setenableprop(hedit, nval, false);
    if strcmpi(nval, 'inactive')
        set(hedit, 'BackgroundColor', [1 1 1]);
    end
    maxset(hedit, hpop);
case 'max'  % The max property controls whether the combobox is read only
    maxset(hedit, hpop);
otherwise
    set(hedit, prop, nval);
end

% -------------------------------------------------------
function maxset(hedit, h)

% If the max value is 0, the combobox is ready only.  Set the editbox to be
% inactive.
nval = get(h, 'Max');
if nval, enabState = get(h, 'Enable');
else     enabState = 'Inactive'; end
set(hedit, 'Enable', enabState);

% -------------------------------------------------------
function update_position(hedit, h)

% Make sure that the Edit box appears over the correct portion of the popup
% menu so that the popup cannot be selected (except by the arrow).
sz = gui_sizes;

% Disable the listeners so that they are not fired when we change the units
% of the popup.
units = get(h, 'Units'); set(h, 'Units', 'Pixels');
pos   = get(h, 'Position');
ext   = get(h, 'Extent'); set(h, 'Units', units);

pos(3) = pos(3) - sz.popwTweak + 5*sz.pixf;

% We need to use the # of strings to determine the size of the editbox,
% since this has an effect on the extent.
ind = get(h, 'Value');

if isempty(ind)
    ind = 0;
end

switch ind
case {1, 2},
    
    pos(2) = pos(2)+pos(4)-ext(4)-4*sz.pixf;
    pos(4) = ext(4)+4*sz.pixf;
otherwise
    
    str = get(h, 'String'); str = cellstr(str);
    ind = length(str)-1;
    
    pos(2) = pos(2)-2*sz.pixf-pos(4)+ext(4)-13*ind*sz.pixf;
    pos(4) = ext(4)-13*ind*sz.pixf+4*sz.pixf;
end

currentpos = get(h, 'Position');
if any(isnan([pos, currentpos])) | ...
        any(isinf([pos, currentpos])) | ...
        ~isempty(find([pos, currentpos] <= 0)),
    set(h, 'Position', getappdata(h, 'OldPosition'));
    return;
end

setappdata(h, 'OldPosition', get(h, 'Position'));

if ~ispc,
    pos(3) = pos(3)-4;
    pos(2) = pos(2)+2;
    pos(4) = pos(4)-2;
else
    pos(3) = pos(3)-1;
    pos(2) = pos(2)+1;
    pos(4) = pos(4)-1;
end

set(hedit, 'Units', 'Pixels', 'Position', pos, 'Units', units);

% -------------------------------------------------------
function updatepopup(hedit, hpop)

% Callback to the edit box.  When the editbox changes the string vector of
% the popup must also change.
str = get(hpop, 'String'); if ~iscell(str), str = {str}; end
val = get(hpop, 'Value');

newstr   = get(hedit, 'String');
str{val} = newstr;

set(hpop, 'String', str);

% -------------------------------------------------------
function destroy_listener(hedit)

delete(hedit);

% -------------------------------------------------------
function str = lclpopupstr(handle)

pick_list = get(handle, 'String');
selection = get(handle, 'Value');
if (iscell(pick_list))
    str = pick_list{selection};
else
    str = deblank(pick_list(selection,:));
end

% [EOF]
