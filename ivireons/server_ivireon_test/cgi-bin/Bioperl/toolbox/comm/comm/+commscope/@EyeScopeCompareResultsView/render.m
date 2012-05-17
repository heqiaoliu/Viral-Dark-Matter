function render(this)
%RENDER Render compare results scope face

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/07/14 03:52:11 $

% Get the figure handle
hFig = this.Parent;

% Get sizes and spacing
sz = guiSizes(this);

% Start a new Handles structure
handles = struct;

% Prepare the comparison table data.  The same data will be used for plotting
% the comparison lines.
[tableData columnLabels yLabels] = ...
    formatCompareTableData(this.MeasurementsPanel, this.ShowQuadrature);

%-------------------------------------------------------
% Render axes

height = sz.PlotSectionHeight;
width = sz.PlotSectionWidth;
x = sz.PlotSectionX;
y = sz.PlotSectionY;

handles.Axes = commgui.DoubleYAxes(hFig,...
    'FontSize',get(0,'defaultuicontrolFontSize'),...
    'Units','pixel',...
    'Position',[x y width height],...
    'Tag','CompareAxes', ...
    'Title', 'Compare Measurement Results View', ...
    'XLabel', 'Eye Diagram Index');
handles.Axes.Legend = this.LegendState;
this.WidgetHandles = handles;

% Plot the selected measurements
plotMeasurements(this, tableData, columnLabels, yLabels)

%-------------------------------------------------------
% Render table
y = sz.TableY;
x = sz.TableX;
height = sz.TableHeight;
width = sz.TableWidth;

handles.Table = uitable(...
    'Parent',hFig,...
    'FontSize',get(0,'defaultuicontrolFontSize'),...
    'Units','pixel',...
    'Position',[x y width height],...
    'Data', tableData, ...
    'ColumnName', columnLabels, ...
    'CellSelectionCallback', {@cbTable, this},...
    'Tag','EyeTable');

% If there is data in the table, make sure that the column labels fit to the
% columns 
numCol = length(columnLabels);
if numCol
    columnWidths = cell(1, numCol);
    margin = largestuiwidth({'s'});
    for p=1:numCol
        columnWidths{p} = largestuiwidth(columnLabels(p)) + margin;
    end
    set(handles.Table, 'ColumnWidth', columnWidths);
end

% Render eye diagram management buttons
x = sz.ButtonX;
height = sz.ButtonHeight;
width = sz.ButtonWidth;

load('comm_add');
handles.AddButton = uicontrol(...
    'Parent',hFig,...
    'Style', 'pushbutton', ...
    'CData',commicon,...
    'Callback', {@(src,evnt)addAction(this,handles.Table)}, ...
    'Interruptible', 'off',...
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
    'Interruptible', 'off',...
    'Units','pixel',...
    'Position',[x sz.DelY width height],...
    'Tooltip', 'Remove eye diagram object', ...
    'Tag','DelButton');

load('comm_move_up');
handles.UpButton = uicontrol(...
    'Parent',hFig,...
    'Style', 'pushbutton',...
    'CData',commicon,...
    'Callback', {@(src,evnt)moveUpAction(this,handles.Table)}, ...
    'Interruptible', 'off',...
    'Units','pixel',...
    'Position',[x sz.UpY width height],...
    'Tooltip', 'Move eye diagram object up', ...
    'Tag','UpButton');

load('comm_move_down');
handles.DownButton = uicontrol(...
    'Parent',hFig,...
    'Style', 'pushbutton', ...
    'CData',commicon,...
    'Callback', {@(src,evnt)moveDownAction(this,handles.Table)}, ...
    'Interruptible', 'off',...
    'Units','pixel',...
    'Position',[x sz.DownY width height],...
    'Tooltip', 'Move eye diagram object down', ...
    'Tag','DownButton');

%-------------------------------------------------------
% Render eye diagram object settings view panel
x = sz.SettingsPanelX;
height = sz.SettingsPanelHeight;
y = sz.SettingsPanelY;
width = sz.SettingsPanelWidth;
temp = uipanel(...
    'Parent',hFig,...
    'Units','pixel',...
    'Title','Eye diagram object settings',...
    'Clipping','on',...
    'Position',[x y width height],...
    'Tag','EyeDiagramObjectSettings');

[handles.SettingsPanelContents me] = ...
    renderInfoTable(this, temp, this.SettingsPanel);
% Store the panel last so that it will be deleted last in the unrender method.
handles.EyeObjSettingPanel = temp;
%-------------------------------------------------------
% Render measurements selection panel
x = sz.MeasurementsPanelX;
y = sz.MeasurementsPanelY;
width = sz.MeasurementsPanelWidth;
height = sz.MeasurementsPanelHeight;
temp = uipanel(...
    'Parent',hFig,...
    'Units','pixel',...
    'Title','Measurements selector',...
    'Clipping','on',...
    'Position',[x y width height],...
    'Tag','MeasurementsSelector');

handles.MeasurementsPanelContents = ...
    renderSelector(this, temp, sz);

x = sz.IQSelectorX;
y = sz.IQSelectorY;
height = sz.IQSelectorHeight;
width = sz.IQSelectorWidth;
handles.IQSelector = uicontrol(...
    'Parent',temp,...
    'Style', 'checkbox', ...
    'Value', this.ShowQuadrature, ...
    'Units','pixel',...
    'String','Show quadrature (imaginary) data',...
    'Callback', {@(src,evnt)cbIQSelector(src,this)}, ...
    'Position',[x y width height],...
    'Tag','IQSelector');
% Store the panel last so that it will be deleted last in the unrender method.
handles.MeasurementsPanel = temp;

% Store handles
this.WidgetHandles = handles;

% Enable/disable the table buttons
updateTableButtons(this)

% Set the flag to notify that the scope face is rendered
this.Rendered = 1;

if ~isempty(me)
    commscope.notifyWarning(this.Parent, me);
end

% Restore the font parameters to the system defaults
restoreFontParams(this, sz);
end

%-------------------------------------------------------------------------------
function cbTable(hsrc, edata, hScopeFace)
% Store the last selected cell
if ~isempty(edata.Indices)
    set(hsrc, 'UserData', edata.Indices(1));

    % Enable/disable the table buttons
    updateTableButtons(hScopeFace)
    
    % Update the Remove eye diagram object menu item
    updateMenu(hScopeFace)
end
end

%-------------------------------------------------------------------------------
function addAction(hScopeFace, hTable)
% Callback function for Import button

% Render the import window.  Wait until the user is done with the import window.
hGui = getappdata(hScopeFace.Parent, 'GuiObject');
renderImportEyeDiagram(hGui);

% Reset the selected item index since uitable removes the highlight.
set(hTable, 'UserData', []);

end

%-------------------------------------------------------------------------------
function delAction(hScopeFace)
% Callback function for Delete button
removeEyeDiagramObject(hScopeFace)

end

%-------------------------------------------------------------------------------
function moveUpAction(hScopeFace, hTable)
% Move the selected eye diagram object up

moveAction(hScopeFace, hTable, 1);
end
%-----------------------------------------------------------------------
function moveDownAction(hScopeFace, hTable)
% Move the selected eye diagram down

moveAction(hScopeFace, hTable, 2);
end

%-----------------------------------------------------------------------
function cbIQSelector(hsrc, this)
this.ShowQuadrature = get(hsrc, 'Value');
update(this);
end

%-----------------------------------------------------------------------
function moveAction(hScopeFace, hTable, direction)
    
% Get the eye diagram object manager
hEyeMgr = hScopeFace.EyeDiagramObjMgr;

% Get the selected item index and move up
success = false;
selectedIdx = get(hTable, 'UserData');
if ~isempty(selectedIdx)
    switch direction
        case 1
            success = moveup(hEyeMgr, selectedIdx);
        case 2
            success = movedown(hEyeMgr, selectedIdx);
    end
end

% Update the data
if success
    eyeObjs = getEyeObjects(hScopeFace.EyeDiagramObjMgr);
    me = prepareCompareTableData(hScopeFace.MeasurementsPanel, eyeObjs);
    if ~isempty(me)
        setException(hScopeFace, me);
    end
    update(hScopeFace);
end

% Reset the selected item index since uitable removes the highlight.
set(hTable, 'UserData', []);

% Update the table buttons
updateTableButtons(hScopeFace)

% Update the Remove eye diagram object menu item
updateMenu(hScopeFace)
end


% [EOF]
