function wintool_export(this)
%WINTOOL_EXPORT Create an export dialog for wintool

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.7 $  $Date: 2007/12/14 15:21:34 $

inputs   = getselection(this);
hwindows = get(inputs, 'Window');
if isempty(hwindows)
    error(generatemsgid('GUIErr'),'There are no windows to export.');
end

hXP = getcomponent(this, '-class', 'sigio.export');

if isempty(hXP),           
    % Create the export dialog
    hXP = sigio.export(hwindows);
    set(hXP, 'DefaultLabels', cellstr(get(inputs, 'Name')));
        
    % Define contextsensitive help
    set(hXP,'CSHelpTag','wintool_export_dlg');
    
    % Add the export component to wintool
    addcomponent(this, hXP);
    hManag = getcomponent(this, '-class', 'siggui.winmanagement');
    addlistener(this, 'NewSelection', @exportselection_eventcb, hManag, this, 'Listeners');    
end

% Render the Export dialog (figure).
if ~isrendered(hXP),
    render(hXP)
    centerdlgonfig(hXP, this);
end

if isempty(inputs), 
    set(hXP, 'Enable', 'off');
end

set(hXP, 'Visible', 'On');
figure(hXP.FigureHandle);


%-------------------------------------------------------------------------
function selectedwin = getselection(this)
%GETSELECTION Return the names of the selected windows in TNAMES,
% and the corresponding objects in OBJECTS.

hManag = getcomponent(this, '-class', 'siggui.winmanagement');

window_list = get(hManag, 'Window_list');
selection = get(hManag, 'Selection');
selectedwin= window_list(selection);

%-------------------------------------------------------------------------
function exportselection_eventcb(this, eventData)
%EXPORTSELECTION_EVENTCB Callback executed by the listener on the NewSelection event

hXP = getcomponent(this, '-class', 'sigio.export');
winspecs = getselection(this);

if isempty(winspecs)
    set(hXP, 'Visible', 'Off');
    return;
end

set(hXP, 'DefaultLabels', cellstr(get(winspecs, 'Name')), 'Data', get(winspecs, 'Window'));

if isempty(winspecs), 
    enab = 'off';
else
    enab = this.Enable;
end

set(hXP, 'Enable', enab);

% [EOF]
