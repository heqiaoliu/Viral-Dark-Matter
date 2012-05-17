function render(this)
%RENDER Render compare results scope face

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/02/13 15:10:55 $

% Get the figure handle
hFig = this.Parent;

% Get active eye object and determine operation mode
activeEyeObj = getSelected(this.EyeDiagramObjMgr);

if isempty(activeEyeObj)
    hEye = [];
    opMode = 'Real Signal';
else
    hEye = activeEyeObj.Handle;
    opMode = get(hEye, 'OperationMode');
end

% Get sizes and spacing
sz = guiSizes(this);

% Start a new Handles structure
handles = struct;

%-------------------------------------------------------
% Render axes

if strcmp(opMode, 'Complex Signal')
    % Render in-phase axis
    x = sz.AxesX;
    height = sz.AxesIQHeight;
    y = sz.AxesIY;
    width = sz.AxesWidth;
    handles.InPhaseAxes = axes(...
        'Parent',hFig,...
        'FontSize',get(0,'defaultuicontrolFontSize'),...
        'Units','pixel',...
        'Position',[x y width height],...
        'Tag','InPhaseAxes');
    formatAxes(handles.InPhaseAxes, 'Single Eye Diagram View', ...
        'In-phase Amplitude (AU)');

    % Render quadrature axis
    y = sz.AxesQY;
    handles.QuadratureAxes = axes(...
        'Parent',hFig,...
        'FontSize',get(0,'defaultuicontrolFontSize'),...
        'Units','pixel',...
        'Position',[x y width height],...
        'Tag','QuadratureAxes');
    formatAxes(handles.QuadratureAxes, '', 'Quadrature Amplitude (AU)');
else
    % Render in-phase axis
    x = sz.AxesX;
    height = sz.AxesHeight;
    y = sz.AxesY;
    width = sz.AxesWidth;
    handles.InPhaseAxes = axes(...
        'Parent',hFig,...
        'FontSize',get(0,'defaultuicontrolFontSize'),...
        'Units','pixel',...
        'Position',[x y width height],...
        'Tag','InPhaseAxes');
    formatAxes(handles.InPhaseAxes, 'Single Eye Diagram View', ...
        'Amplitude (AU)');
end

% Store handles.  We need them for updateAxesWidth
this.WidgetHandles = handles;

% Plot the eye diagram
plotEyeDiagram(this)

%-------------------------------------------------------
% Render list and list label
y = sz.ListLabelY;
x = sz.ListLabelX;
height = sz.ListLabelHeight;
width = sz.ListLabelWidth;
handles.EyeObjNameLabel = uicontrol(...
    'Parent', hFig,...
    'FontSize', get(0,'defaultuicontrolFontSize'),...
    'HorizontalAlignment', 'left',...
    'Position', [x y width height],...
    'String', 'Eye diagram objects:',...
    'Style', 'text',...
    'Tag', 'EyeDiagramObjectNameLabel');


y = sz.ListY;
x = sz.ListX;
height = sz.ListHeight;
width = sz.ListWidth;

[eyeObjList selectedIdx] = getSortedNameList(this.EyeDiagramObjMgr);
handles.EyeObjName = uicontrol(...
    'Parent',hFig,...
    'Callback',{@(hsrc, edata)pucbObjectName(hsrc, this)},...
    'FontSize',get(0,'defaultuicontrolFontSize'),...
    'BackgroundColor',[1 1 1],...
    'HorizontalAlignment','left',...
    'Position',[x y width height],...
    'String', eyeObjList,...
    'Value', selectedIdx,...
    'Style','listbox',...
    'Tag','EyeDiagramObjectName');

% Render eye diagram management buttons
x = sz.ButtonX;
height = sz.ButtonHeight;
width = sz.ButtonWidth;

load('comm_add');
handles.AddButton = uicontrol(...
    'Parent',hFig,...
    'Style', 'pushbutton', ...
    'CData',commicon,...
    'Callback', {@(src,evnt)addAction(this)}, ...
    'Units','pixel',...
    'Position',[x sz.AddY width height],...
    'Tooltip', 'Import eye diagram object', ...
    'Tag','AddButton');

load('comm_delete');
handles.DelButton = uicontrol(...
    'Parent',hFig,...
    'Style', 'pushbutton', ...
    'CData',commicon,...
    'Callback', {@(src,evnt)delAction(this)}, ...
    'Units','pixel',...
    'Position',[x sz.DelY width height],...
    'Tooltip', 'Remove eye diagram object', ...
    'Tag','DelButton');

%-------------------------------------------------------
% Render eye diagram object settings view panel
x = sz.SettingsPanelX;
height = sz.SettingsPanelHeight;
y = sz.SettingsPanelY;
width = sz.SettingsPanelWidth;
handles.EyeObjSettingPanel = uipanel(...
    'Parent',hFig,...
    'Units','pixel',...
    'Title','Eye diagram object settings',...
    'Clipping','on',...
    'Position',[x y width height],...
    'Tag','EyeDiagramObjectSettings');

handles.SettingsPanelContents = ...
    renderInfoTable(this, handles.EyeObjSettingPanel, this.SettingsPanel);

%-------------------------------------------------------
% Render measurements view panel
x = sz.MeasurementsPanelX;
y = sz.MeasurementsPanelY;
width = sz.MeasurementsPanelWidth;
height = sz.MeasurementsPanelHeight;
handles.MeasurementsPanel = uipanel(...
    'Parent',hFig,...
    'Units','pixel',...
    'Title','Measurements',...
    'Clipping','on',...
    'Position',[x y width height],...
    'Tag','Measurements');

handles.MeasurementsPanelContents = ...
    renderInfoTable(this, handles.MeasurementsPanel, this.MeasurementsPanel);

% Store handles
this.WidgetHandles = handles;

% Set the flag to notify that the scope face is rendered
this.Rendered = 1;

% Store the operation mode
this.Mode = opMode;

% Enable/disable list buttons
updateListButtons(this)

% Update the plot control window
if ~isempty(this.PlotCtrlWin)
    update(this.PlotCtrlWin, hEye)
end

% Check if there was an exception during rendering
checkException(this)

% Restore the font parameters to the system defaults
restoreFontParams(this, sz);
end

%-------------------------------------------------------------------------------
function pucbObjectName(hsrc, hScopeFace)
% Callback function for the eye diagram object name pop-up menu

% Get the entered value
activeIdx = get(hsrc, 'Value');

% Set the active eye diagram object.  Update the GUI.
setSelected(hScopeFace.EyeDiagramObjMgr, activeIdx);

update(hScopeFace);

end

%-------------------------------------------------------------------------------
function addAction(hScopeFace)
% Callback function for Import button

% Render the import window.  Wait until the user is done with the import window.
hGui = getappdata(hScopeFace.Parent, 'GuiObject');
renderImportEyeDiagram(hGui);
end

%-------------------------------------------------------------------------------
function delAction(hScopeFace)
% Callback function for Delete button
removeEyeDiagramObject(hScopeFace)
end

%-------------------------------------------------------------------------------
function formatAxes(ha, axesTitle, yLabel)
title(ha, axesTitle);
xlabel(ha, 'Time (s)');
ylabel(ha, yLabel);
set(ha, 'XGrid', 'on', ...
    'YGrid', 'on', ...
    'XColor', [0.2 0.2 0.2], ...
    'YColor', [0.2 0.2 0.2], ...
    'Box', 'on');

end
% [EOF]
