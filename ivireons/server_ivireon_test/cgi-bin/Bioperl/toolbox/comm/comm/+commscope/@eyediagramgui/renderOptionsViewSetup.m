function renderOptionsViewSetup(this, callerID)
%RENDEROPTIONSVIEWSETUP <short description>
%   OUT = RENDEROPTIONSVIEWSETUP(ARGS) <long description>

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/13 15:11:41 $

if strcmp(callerID, 'OptionsMenuEyeSettings')
    titleBarStr = 'Configure eye diagram object settings view';
    hPanelMgr = this.SettingsPanel;
else
    titleBarStr = 'Configure measurements view';
    hPanelMgr = this.MeasurementsPanel;
end

sz = getOptionsViewSizes(this);

hFig = figure(...
    'Position', [0 0 sz.OptionsViewWidth sz.OptionsViewHeight], ...
    'CreateFcn', {@movegui,'center'}, ...
    'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
    'IntegerHandle', 'off', ...
    'MenuBar', 'none', ...
    'Name', titleBarStr, ...
    'NumberTitle', 'off', ...
    'Resize', 'off', ...
    'NextPlot', 'new', ...
    'HandleVisibility', 'off', ...
    'Tag', 'OptionsViewSetup', ...
    'Visible', 'off', ...
    'WindowStyle', 'modal');
set(hFig, 'KeyPressFcn', {@pbcbOptionsViewFinish, hFig, this});

% Render widgets
% Get the list of items
list = getScreenNames(hPanelMgr);
quickHelp = getQuickHelp(hPanelMgr);
selectedItemIndices = hPanelMgr.PanelContentIndices;

handles.ShuttleCtrl = commgui.shuttlectrl(...
    'Parent', hFig, ...
    'Position', [sz.hcc sz.vcc ...
        sz.OptionsViewWidth-2*sz.hcc sz.OptionsViewHeight-2*sz.vcc], ...
    'Items', list, ...
    'QuickHelp', quickHelp, ...
    'QuickHelpHeight', sz.QuickHelpHeight, ...
    'SelectedItemIndices', selectedItemIndices);
    
% Offset button locations based on the shuttle control information
sz.OKButtonX = sz.OKButtonX + handles.ShuttleCtrl.SelectedListX;
sz.CancelButtonX = sz.CancelButtonX + handles.ShuttleCtrl.SelectedListX;

handles.OK = uicontrol(hFig, ...
    'Style', 'pushbutton', ...
    'String', 'OK', ...
    'Tag', 'OptionsViewOK', ...
    'KeyPressFcn', {@pbcbOptionsViewFinish, hFig, this}, ...
    'Callback', {@pbcbOptionsViewFinish, hFig, this}, ...
    'Position', [sz.OKButtonX sz.OKButtonY sz.bw sz.bh]);

handles.Cancel = uicontrol(hFig, ...
    'Style', 'pushbutton', ...
    'String', 'Cancel', ...
    'Tag', 'OptionsViewCancel', ...
    'KeyPressFcn', {@pbcbOptionsViewFinish, hFig, this}, ...
    'Callback', {@pbcbOptionsViewFinish, hFig, this}, ...
    'Position', [sz.CancelButtonX sz.CancelButtonY sz.bw sz.bh]);

% Store the handles
setappdata(hFig, 'Handles', handles);

% Store the window type
setappdata(hFig, 'OptionsViewSetupType', callerID);

% Make the figure window visible
set(hFig, 'Visible', 'on');

% Restore the font parameters to the system defaults
restoreFontParams(this, sz);
end
%-------------------------------------------------------------------------------
function pbcbOptionsViewFinish(hsrc, eventdata, hFig, this)
% Callback function for OK and cancel buttons and escape key

% Check if this is a key press event
if isstruct(eventdata) && isfield(eventdata, 'Key')
    if strcmp(eventdata.Key, 'escape')
        delete(hFig);
        return
    elseif ~strcmp(eventdata.Key, 'return')
        return
    end
end

% Get the caller's name
source = get(hsrc, 'Tag');

if strcmp(source, 'OptionsViewOK')
    % OK button was clicked
    
    % Get handles
    handles = getappdata(hFig, 'Handles');
    hShuttle = handles.ShuttleCtrl;
    
    % Get window type
    windowType = getappdata(hFig, 'OptionsViewSetupType');

    % Set the selected values
    if strcmp(windowType, 'OptionsMenuEyeSettings')
        this.SettingsPanel.PanelContentIndices = hShuttle.SelectedItemIndices;
    else
        this.MeasurementsPanel.PanelContentIndices = ...
            hShuttle.SelectedItemIndices;
    end
    
    % Update the scope face
    update(this.CurrentScopeFace)

    % Indicate that the scope is dirty, i.e. a property has changed 
    set(this, 'Dirty', 1);
end

% Close the window
delete(hFig);
end
%-------------------------------------------------------------------------------
% [EOF]
