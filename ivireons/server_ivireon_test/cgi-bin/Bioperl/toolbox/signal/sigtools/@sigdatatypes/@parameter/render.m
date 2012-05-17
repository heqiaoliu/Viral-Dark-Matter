function h = render(hPrm, hFig, pos, varargin)
%RENDER Render a parameter selector
%   RENDER(hPRM, hFIG, POS) Render a parameter selector to the figure hFIG
%   at the position (in pixels) POS.
%
%   RENDER(hPRM, hFIG, POS, SPECPOS) Render a parameter selector with the
%   specifier rendered at SPECPOS.  If SPECPOS is not included POS will be
%   used to determine the position of the specifier.
%
%   RENDER(hPRM, hFig, POS, SPECPOS, FORMAT) Render a parameter selector in
%   the format specified by FORMAT.  FORMAT can be 'loose' and 'compact'.
%   'loose' is the default.
%
%   RENDER(hPRM, hFig, POS, SPECPOS, FORMAT, AUTOUPDATE) Render a parameter
%   selector which updates the parameters according to AUTOUPDATE.  If
%   AUTOUPDATE is 1, the parameter is updated.  If AUTOUPDATE is 0, the
%   event 'UserModified' is sent.  AUTOUPDATE is 1 by default.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.9 $  $Date: 2008/08/01 12:25:47 $

error(nargchk(3,6,nargin,'struct'));
[specPos, format, autoupdate, msg] = parse_inputs(pos, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

pixf = get(0,'screenpixelsperinch')/96;

% "Nudge" the labels down.
pos(2) = pos(2) - 2*pixf;

if isempty(specPos),
    lblwidth = largestuiwidth(cellstr(get(hPrm, 'Name')))+5*pixf;;
    
    vv = get(hPrm, 'ValidValues');
    
    if length(hPrm) == 1,
        if iscell(vv),
            specwidth = largestuiwidth(vv)+25*pixf;
        else
            specwidth = pos(3)-lblwidth-10*pixf;
        end
    else
        if lblwidth > pos(3)/2,
            specwidth = pos(3)-lblwidth;
        else
            specwidth = pos(3)/2;
            for indx = 1:length(vv),
                if iscell(vv{indx}),
                    specwidth = max(specwidth, largestuiwidth(vv{indx})+21*pixf);
                end
            end
            if specwidth+lblwidth > pos(3),
                specwidth = pos(3)-lblwidth;
            end
        end
    end
    specPos = pos;
    specPos(1) = specPos(1)+specPos(3)-specwidth;
    specPos(3) = specwidth;
    specPos(2) = specPos(2)+3*pixf;
end

if length(hPrm) == 1 | strcmpi(format, 'compact'),
    h = render_individual(hPrm, hFig, pos, specPos, format, autoupdate);
else
    for i = length(hPrm):-1:1,
        h(i) = render_individual(hPrm(i), hFig, pos, specPos, format, autoupdate);
        skip = max([pos(4) specPos(4)]) + 10*pixf;
        pos(2) = pos(2) + skip;
        specPos(2) = specPos(2) + skip;
    end
end


% --------------------------------------------------------------------
function h = render_individual(hPrm, hFig, pos, specPos, format, autoupdate)

name = get(hPrm, 'Name');

% Determine the position of the label and popup.
if ~iscell(name),
    cname = {name};
else
    cname = name;
end

width     = largestuiwidth(cname);
popPos    = pos;

if length(hPrm) == 1 & strcmpi(get(findprop(hPrm, 'Value'), 'DataType'), 'on/off'),
    cpos = pos + [0 2 0 0];
    h.checkbox = uicontrol(hFig, ...
        'Style', 'checkbox', ...
        'Visible', 'Off', ...
        'String', name, ...
        'Position', cpos, ...
        'Callback', {@check_cb, hPrm});
    if strcmpi(get(hPrm, 'Value'), 'on'),
        set(h.checkbox, 'Value', 1);
    else
        set(h.checkbox, 'Value', 0);
    end
else
    h.checkbox = [];
end

% Create the editbox and the pop up for the values
h.edit = uicontrol(hFig, ...
    'Style', 'Edit', ...
    'Visible', 'Off', ...
    'Position', specPos, ...
    'HorizontalAlignment', 'Left', ...
    'tag', [hPrm(1).tag '_editbox'], ...
    'Callback', @edit_cb);

if iscell(hPrm(1).ValidValues),
    strs = hPrm(1).ValidValues;
else
    strs = ' ';
end

h.specpopup = uicontrol(hFig, ...
    'Style', 'Popup', ...
    'String', strs, ...
    'Position', specPos, ...
    'tag', [hPrm(1).tag '_specpopup'], ...
    'Visible', 'Off', ...
    'Callback', @specpopup_cb);

if ~autoupdate,
    set([h.edit h.specpopup h.checkbox], 'Callback', {@sendusermodified, hPrm})
end

% If name is a cell array we must have multiple parameters.
% Render a popup for the cell of strings
if iscell(name),
    
    % In R13 we may be able to use gui_sizes as a static siggui method
    popPos(3) = width+20*get(0,'screenpixelsperinch')/96;

    popPos(3) = check_position(popPos, specPos);
    
    % If there are multiple names, then we need a popup to select them
    h.popup   = uicontrol(hFig, ...
        'Style', 'Popup', ...
        'String', name, ...
        'Position', popPos, ...
        'tag', [hPrm(1).tag '_popup'], ...
        'HorizontalAlignment', 'Left', ...
        'Callback', {@popup_cb, hPrm});
    setappdata(h.popup, 'handles', h);

else
    
    popPos(3) = check_position(popPos, specPos);
    
    % If there is only one name, create a textbox for the label.
    h.label = uicontrol(hFig, ...
        'Style', 'Text', ...
        'String', [name ':'], ...
        'tag', [hPrm(1).tag '_label'], ...
        'HorizontalAlignment', 'Left', ...
        'Position', popPos);
end

vv = get(hPrm(1), 'ValidValues');

% If the first parameter has a cell for the valid values, use the popup
if iscell(vv),
    l = handle.listener(hPrm(1), hPrm(1).findprop('DisabledOptions'), ...
        'PropertyPostSet', @disabledoptions_listener);
    set(l, 'CallbackTarget', h.specpopup);
    setappdata(h.specpopup, 'DisabledOptionsListener', l);
    set(h.specpopup, 'Visible', 'On');
elseif ischar(vv) & strcmpi(vv, 'on/off')
    set(h.checkbox, 'Visible', 'On');
    set(h.label, 'Visible', 'Off');
else
    set(h.edit, 'Visible', 'On');
end

% Set up listeners on the NewValue of the parameters to update the GUI
for i = 1:length(hPrm),
    
    % We need this "strange" indexing to set the correct parameter object as the CB target
    indx = 2*i-1;
    l(indx) = handle.listener(hPrm(i), 'ForceUpdate', {@property_listener, h});
    l(indx+1) = handle.listener(hPrm(i), 'NewValidValues', {@newvalidvalues_listener, h});
    set(l(indx:end), 'CallbackTarget', hPrm(i));
end

setappdata(h.edit, 'ParameterListener', l);
setappdata(h.edit, 'ActiveParameter', hPrm(1));
setappdata(h.specpopup, 'ActiveParameter', hPrm(1));

property_listener(hPrm, [], h);
if iscell(hPrm(1).ValidValues),
    disabledoptions_listener(h.specpopup);
end

% ---------------------------------------------------------------------
function disabledoptions_listener(hpopup, eventData)

hPrm = getappdata(hpopup, 'ActiveParameter');
vv   = get(hPrm, 'ValidValues');
indx = get(hpopup, 'Value');

if indx > length(vv),
    indx = 1;
end

if length(vv) == 1, enabState = 'Off';
else,               enabState = 'On'; end

set(hpopup, 'Value', indx, 'String', vv);
setenableprop(hpopup, enabState);

% ---------------------------------------------------------------------
function property_listener(hPrm, eventData, h)

if ~isfield(h,'popup'),
    
    % If there is no popup then we can assume that we are reacting to the
    % active parameter (there are no others)
    sync_specifier(hPrm, h);
else
    
    % If there is a popup we must check the name of the parameter with the
    % string in the parameter selection popup
    if strcmpi(get(hPrm,'Name'), popupstr(h.popup)),
        sync_specifier(hPrm, h);
    end
end

% ---------------------------------------------------------------------
function newvalidvalues_listener(hPrm, eventData, h)

set(h.specpopup, 'String', get(hPrm, 'ValidValues'));

% ---------------------------------------------------------------------
function sync_specifier(hPrm, h)
% Synchronize the edit/popup with the Parameter value 

vv = get(hPrm, 'ValidValues');

if iscell(vv),
    indx = find(strcmpi(hPrm.Value, vv));
    if isempty(indx),
        value = popupstr(h.specpopup);
        indx = find(strcmpi(value, vv));
        if isempty(indx), indx = get(h.specpopup, 'Value'); end
    end
    set(h.specpopup, 'String', vv, 'Value', indx);
elseif ischar(vv) & strcmpi(vv, 'on/off')
    if strcmpi(hPrm.Value, 'On'), v = 1;
    else,                         v = 0; end
    set(h.checkbox, 'Value', v);
else
    str = get(h.edit, 'String');
    if isempty(str)
        str = hPrm.Value;
        if ~ischar(str)
            str = num2str(hPrm.Value);
        end
    else
        if ischar(hPrm.Value)
            str = hPrm.Value;
        else
            [varsinedit, msg] = evaluatevars(get(h.edit, 'string'));
            if isempty(msg)
                if length(varsinedit) == length(hPrm.Value)
                    if all(varsinedit == hPrm.Value)
                        % No need to update, we don't want to overwrite a string.
                        return;
                    end
                end
            end
            str = num2str(hPrm.Value);
        end
    end
    set(h.edit, 'String', str);
end

% ----------------------------------------------------------------------
function check_cb(hcbo, eventStruct, hPrm)

if get(hcbo, 'Value'),
    value = 'on';
else
    value = 'off';
end

hActive = getappdata(hcbo, 'ActiveParameter');
set(hActive, 'Value', value);

% ----------------------------------------------------------------------
function popup_cb(hcbo, eventStruct, hPrm)

indx    = get(hcbo, 'Value');
hActive = hPrm(indx);
h       = getappdata(hcbo, 'handles');

if iscell(hActive.ValidValues),

    % Turn off the edit box
    set([h.edit h.checkbox], 'Visible', 'Off');
    
    % Turn on the spec popup and update the string
    set(h.specpopup, 'String', hActive.ValidValues, ...
        'Visible', 'On');
    
    % Store the active parameter
    setappdata(h.specpopup, 'ActiveParameter', hActive);
elseif strcmpi(hActive.ValidValues, 'on/off'),
    set(h.checkbox, 'Visible', 'on');
    set([h.edit h.specpopup], 'Visible', 'Off');
    setappdata(h.checkbox, 'ActiveParameter', hActive);
else
    
    % Turn on the edit box
    set(h.edit, 'Visible', 'On');

    % Turn off the spec popup
    set([h.specpopup h.checkbox], 'Visible', 'Off');

    % Store the active parameter
    setappdata(h.edit, 'ActiveParameter', hActive);
end

% Once the parameter becomes "active" we must sync it's popup/edit
sync_specifier(hActive,h);

% ----------------------------------------------------------------------
function edit_cb(hcbo, eventStruct)

hActive = getappdata(hcbo, 'ActiveParameter');

try,
    
    % Try to set the value.  If it fails it is invalid
    setvalue(hActive, str2num(get(hcbo,'String')));
catch ME
    
    errordlg(cleanerrormsg(ME.message), 'Parameter Error');
    set(hcbo, 'String', num2str(get(hActive, 'Value')));
end

% ----------------------------------------------------------------------
function specpopup_cb(hcbo, eventStruct)

% Set the active parameter to the popup string
hActive = getappdata(hcbo, 'ActiveParameter');
setvalue(hActive, popupstr(hcbo));

% ----------------------------------------------------------------------
function pos = check_position(popPos, specPos)

% Make sure that the selector popup or the label does not cover up the specifier

if popPos(2) + popPos(4) > specPos(2) & popPos(2) < specPos(2) + specPos(4),
    if popPos(3)+popPos(1) > specPos(1),
        pos = specPos(1)-popPos(1);
    else
        pos = specPos(3);
    end
else
    pos = specPos(3);
end

% ----------------------------------------------------------------------
function sendusermodified(hcbo, eventStruct, hPrm)

switch lower(get(hcbo, 'Style'))
    case 'edit'
        value = str2num(get(hcbo, 'String'));
    case 'checkbox'
        if get(hcbo, 'Value'), value = 'on';
        else,                  value = 'off'; end
    otherwise
        value = popupstr(hcbo);
end

send(hPrm, 'UserModified', ...
    sigdatatypes.sigeventdata(hPrm, 'UserModified', value));

% ----------------------------------------------------------------------
function [specPos, format, autoupdate, msg] = parse_inputs(pos, varargin)

specPos = [];
format     = 'loose';
autoupdate = 1;
msg        = nargchk(1,4,nargin);

for i = 1:length(varargin),
    if ischar(varargin{i}),
        format = varargin{i};
    elseif isnumeric(varargin{i}),
        switch length(varargin{i}),
        case 1
            autoupdate = varargin{i};
        case 4
            specPos = varargin{i};
        case 0
            % No Op Users can input [] to use the default
        otherwise
            msg = 'Invalid input.';
        end
    end
end

% [EOF]
