function panel_listener(this, eventData)
%PANEL_LISTENER Listener to the CurrentPanel property

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.7 $  $Date: 2006/11/19 21:46:28 $

% Make sure that the correct toggle button is depressed.
update_toggle_buttons(this, eventData);

% Hide the previously selected panel.
hide_old_panel(this, eventData);

% Show the newly selected panel.
show_new_panel(this, eventData);

% ---------------------------------------------------------------------
function update_toggle_buttons(this, eventData)

h     = get(this,'Handles');
index = get(eventData, 'NewValue');

set(h.button, 'Value', 0, 'Enable', 'On');
set(h.button(index), 'Value', 1, 'Enable', 'Inactive');

% ---------------------------------------------------------------------
function hide_old_panel(this, eventData)

index   = get(this, 'CurrentPanel');
hPanel = getpanelhandle(this, index);

if isequal(hPanel,0), return; end

% A structure can be used to store function handles that we FEVAL
if isstruct(hPanel),
    hFig = get(this,'FigureHandle');
    feval(hPanel.hide, hFig);
else
    set(hPanel,'Visible','Off');
end


% ---------------------------------------------------------------------
function show_new_panel(this, eventData)

index  = get(eventData,'NewValue');
hPanel = getpanelhandle(this, index);

% If the returned panel is empty it has not been instantiated yet
% Instantiate it.
if isempty(hPanel)
    hPanel = constructAndSavePanel(this,index);
end

if isstruct(hPanel),
    hFig = get(this,'FigureHandle');
    feval(hPanel.show, hFig);
else
    set(hPanel,'Visible',this.Visible);
end

% [EOF]
