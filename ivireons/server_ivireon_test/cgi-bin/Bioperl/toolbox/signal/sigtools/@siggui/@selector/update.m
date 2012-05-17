function update(this, fcn, varargin)
%UPDATE Update the selector

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2004/12/26 22:21:54 $

if nargin == 1, fcn = 'update_all'; end

feval(fcn, this, varargin{:});

% ---------------------------------------------------------------
function update_all(this)

update_enablestates(this);
update_popup(this);
update_radiobtns(this);
update_cshtags(this);

% ---------------------------------------------------------------
function update_enablestates(this)
%UPDATE_ENABLESTATES Update the enable states of the selector

enabState = get(this, 'Enable');
h         = get(this, 'Handles');

% If the enable state of the property is off, then the whole frame is off.
if strcmpi(enabState, 'off');
    setenableprop(h.popup, enabState, false);
    setenableprop(h.radio, enabState, false);
else
    dSelects = get(this,'DisabledSelections');
    
    % Loop over all the radio buttons and compare the tags to the dSelects string
    % vector to determine enable state
    for i = 1:length(h.radio)
        tag = get(h.radio(i),'Tag');
        if ~isempty(strmatch(tag,dSelects))
            enabState = 'Off';
        else
            enabState = 'On';
        end
        setenableprop(h.popup(i), enabState, false);
        setenableprop(h.radio(i), enabState, false);
    end
end


% ---------------------------------------------------------------
function update_popup(this)
%UPDATE_POPUP Update the currently selected popup of the selector

% This can be a private method

selection = get(this, 'Selection');
subselect = get(this, 'SubSelection');
h         = get(this, 'Handles');

hPop = [];
if ~isempty(h.popup)

    % Find a popup with the tag matching the selection.
    hPop = findobj(h.popup, 'Tag', selection);
end

if ~isempty(hPop)
    
    % Find the popup entry with the tag matching the subselection
    tags = get(hPop,'UserData');
    indx = find(strcmpi(subselect,tags));

    if isempty(indx),
        indx = 1;
    end
    set(hPop,'Value',indx);
end


% ---------------------------------------------------------------
function update_radiobtns(this)
%UPDATE_RADIOBTNS Update the radiobuttons of the Selector

h   = get(this,'Handles');
sel = get(this,'Selection');

% Deactivate all the radio buttons
set(h.radio,'value',0);
hOn = findobj(h.radio,'tag',sel);

% Activate the radio button that matches the current selection.
set(hOn,'value',1);

% ---------------------------------------------------------------
function update_cshtags(this)

h = get(this, 'Handles');

tags = get(this, 'CSHTags');

for indx = 1:min(length(tags), length(h.radio))
    cshelpcontextmenu(h.radio(indx), tags{indx}, 'fdatool');
    cshelpcontextmenu(h.popup(indx), tags{indx}, 'fdatool');
end

% [EOF]
