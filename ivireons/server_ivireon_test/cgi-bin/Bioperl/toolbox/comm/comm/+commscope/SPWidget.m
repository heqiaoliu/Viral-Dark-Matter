classdef SPWidget < commgui.AbstractGUI
    %SPWidget Construct a scatter plot GUI widget
    %
    %   Warning: This undocumented function may be removed in a future release.
    
    % Copyright 2008-2009 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $  $Date: 2009/01/20 15:29:01 $
    
    %===========================================================================
    % Protected properties
    properties (Access = protected)
        MeasurementsTableData
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = SPWidget(hParent, percentile)
            this.Parent = hParent;
            createMeasurementsList(this);
            prepareRowNames(this, percentile)
        end
        %-----------------------------------------------------------------------
        function render(this, hPlotSettings)
            % Get the figure handle
            hParent = this.Parent;
            
            % Get sizes and spacing
            sz = guiSizes(this);
            
            %-------------------------------------------------------------------
            % Create the main grid
            hGrid = siglayout.gridbaglayout(hParent);
            hGrid.VerticalGap = sz.vff;
            
            % Create a container for the axes (upper half)
            hAxesCont = uicontainer('Parent', hParent, ...
                'ResizeFcn', @(src,edata)axesResizeFcn(src, hPlotSettings));
            add(hGrid, hAxesCont, 1, 1, 'Fill', 'Both')
            
            % Render axis
            handles.Axis = axes('Parent', hAxesCont, ...
                'NextPlot', 'add', ...
                'Units', 'pixels', ...
                'Box', 'on');
            xlabel(handles.Axis, 'In-phase (AU)');
            ylabel(handles.Axis, 'Quadrature (AU)');
            title(handles.Axis, 'Scatter Plot');
            
            % Create a container for the lower half
            hInfoCont = uicontainer('Parent', hParent);
            add(hGrid, hInfoCont, 2, 1, 'Fill', 'Both')
            hGrid.VerticalWeights = [1 0];
            
            %-------------------------------------------------------------------
            % Create the info grid
            hCtrlGrid = siglayout.gridbaglayout(hInfoCont);
            axisPos = get(handles.Axis, 'Position');
            hCtrlGrid.HorizontalGap = axisPos(1);
            
            
            % Set the minimum height for the controls
            setconstraints(hGrid, 2, 1, 'MinimumHeight', (sz.tbh + sz.vcc)*3)
            
            % Create a container for the plot controls
            hInfoGrid.HorizontalWeights = [90 10];
            
            %-------------------------------------------------------------------
            % Create the control grid
            
            % Render check boxes
            handles.ShowConstellation = uicontrol(...
                'Parent', hInfoCont,...
                'Style', 'checkbox', ...
                'Value', strncmp(hPlotSettings.Constellation, 'on', 2), ...
                'Units','pixel',...
                'String','Constellation',...
                'Callback', {@(src,evnt)cbConstellationSelector(src, hPlotSettings)}, ...
                'Tag','ConstellationSelector');
            add(hCtrlGrid, handles.ShowConstellation, 1, 1, ...
                'Fill', 'Horizontal', 'MinimumHeight', sz.tbh + sz.vcc, ...
                'MinimumWidth', sz.PlotCtrlMinWidth);
            
            handles.ShowTrajectory = uicontrol(...
                'Parent', hInfoCont,...
                'Style', 'checkbox', ...
                'Value', strncmp(hPlotSettings.SignalTrajectory, 'on', 2), ...
                'Units','pixel',...
                'String','Signal Trajectory',...
                'Callback', {@(src,evnt)cbTrajectorySelector(src, hPlotSettings)}, ...
                'Tag','TrajectorySelector');
            add(hCtrlGrid, handles.ShowTrajectory, 2, 1, ...
                'Fill', 'Horizontal', 'MinimumHeight', sz.tbh + sz.vcc, ...
                'MinimumWidth', sz.PlotCtrlMinWidth);
            
            handles.ShowGrid = uicontrol(...
                'Parent', hInfoCont,...
                'Style', 'checkbox', ...
                'Value', strncmp(hPlotSettings.Grid, 'on', 2), ...
                'Units','pixel',...
                'String','Grid',...
                'Callback', {@(src,evnt)cbGridSelector(src, hPlotSettings)}, ...
                'Tag','GridSelector');
            add(hCtrlGrid, handles.ShowGrid, 3, 1, 'Fill', ...
                'Horizontal', 'MinimumHeight', sz.tbh + sz.vcc, ...
                'MinimumWidth', sz.PlotCtrlMinWidth);
            
            % Render autoscale button
            handles.Autoscale = uicontrol(...
                'Parent', hInfoCont,...
                'Style', 'pushbutton', ...
                'Units','pixel',...
                'String', 'Autoscale Axes', ...
                'Callback', {@(src,evnt)cbAutoscale(hPlotSettings)}, ...
                'Tag','Autoscale');
            add(hCtrlGrid, handles.Autoscale, 3, 2, ...
                'Fill', 'None', ...
                'MinimumHeight', sz.bh, ...
                'MinimumWidth', sz.AutoscaleWidth, ...
                'Anchor', 'SouthEast')
            
            %-------------------------------------------------------------------
            % Update menus
            hFig = ancestor(hParent, 'figure');
            
            % Update help menu
            hHelpMenu = findall(hFig, 'type', 'uimenu', 'label', '&Help');
            handles.hHelpSP = uimenu(hHelpMenu, ...
                'label', '&Scatter Plot', ...
                'Position', 1, ...
                'Callback', @(src,edata)menucbHelp(src), ...
                'Tag', 'HelpScatterPlot');
            hHelpGH = findall(hFig, 'type', 'uimenu', 'label', '&Graphics Help');
            set(hHelpGH, 'Separator', 'on')
                
            % Update print and print preview menus to print just the axis.
            % Since Print is not translated, it is OK to look for the name.
            % However, Print Preview is translated, so we need to look for
            % the tag.
            hPrintMenu = findall(hFig, 'type', 'uimenu', 'label', '&Print...');
            set(hPrintMenu, 'Callback', {@(src,evnt)cbPrint(handles.Axis)});
            hPrintPreviewMenu = findall(hFig, 'type', 'uimenu', ...
                'Tag', 'figMenuFilePrintPreview');
            set(hPrintPreviewMenu, 'Callback', ...
                {@(src,evnt)cbPrintPreview(handles.Axis)});
                
            %-------------------------------------------------------------------
            % Update toolbar
            hPrintPushTool = findall(hFig, 'type', 'uipushtool', ...
                'tooltip', 'Print Figure');
            set(hPrintPushTool, 'ClickedCallback', ...
                {@(src,evnt)cbPrint(handles.Axis)});
            
            % Store handles
            this.WidgetHandles = handles;
            
            % Check if there was an exception during rendering
            checkException(this)
            
            % Restore the font parameters to the system defaults
            commscope.SPWidget.restoreFontParams(sz);
            
            % Set rendered
            this.Rendered = true;
        end
        %-----------------------------------------------------------------------
        function update(this) %#ok<MANU>
            %NO OP
        end
        %-----------------------------------------------------------------------
        function reset(this) %#ok<MANU>
            %NO OP
        end
        %-----------------------------------------------------------------------
        function hAxis = getAxisHandle(this)
            hAxis = this.WidgetHandles.Axis;
        end
        %-----------------------------------------------------------------------
        function showConstellation(this)
            if isRendered(this)
                set(this.WidgetHandles.ShowConstellation, 'Value', true);
            end
        end
        %-----------------------------------------------------------------------
        function hideConstellation(this)
            if isRendered(this)
                set(this.WidgetHandles.ShowConstellation, 'Value', false);
            end
        end
        %-----------------------------------------------------------------------
        function showTrajectory(this)
            if isRendered(this)
                set(this.WidgetHandles.ShowTrajectory, 'Value', true);
            end
        end
        %-----------------------------------------------------------------------
        function hideTrajectory(this)
            if isRendered(this)
                set(this.WidgetHandles.ShowTrajectory, 'Value', false);
            end
        end
        %-----------------------------------------------------------------------
        function showGrid(this)
            if isRendered(this)
                set(this.WidgetHandles.ShowGrid, 'Value', true);
            end
        end
        %-----------------------------------------------------------------------
        function hideGrid(this)
            if isRendered(this)
                set(this.WidgetHandles.ShowGrid, 'Value', false);
            end
        end
        %-----------------------------------------------------------------------
        function setParent(this, hParent)
            this.Parent = hParent;
        end
        %-----------------------------------------------------------------------
        function prepareRowNames(this, percentile)
            %Prepares a cell matrix table to use as an input to the table
            % object for the eye diagram object settings panel.

            % Get the list of items
            list = this.MeasurementsTableData.Measurements;

            itemLabelList = cell(length(list),1);
            for p=1:length(list)
                itemLabel = list(p).ScreenName;
                itemUnit = list(p).Unit;

                if ~isempty(strfind(itemLabel, 'Percentile'))
                    itemLabel = sprintf(itemLabel, percentile);
                end
                
                itemLabelList{p} = sprintf('%s (%s):', itemLabel, itemUnit);
            end
            
            this.MeasurementsTableData.RowNames = itemLabelList;
        end
        %-----------------------------------------------------------------------
        function updateMeasurementValues(this, hMeaurements)
            if 0
                % Disabled feature
                hTable = this.WidgetHandles.Measurements;
                
                if ishghandle(hTable)
                    tableData = get(hTable, 'Data');
                    measurementsList = this.MeasurementsTableData.Measurements;
                    
                    for p=1:length(measurementsList)
                        tableData{p, 2} = hMeaurements.(measurementsList(p).FieldName);
                    end
                    
                    set(hTable, 'Data', tableData);
                end
            end
        end
        %-----------------------------------------------------------------------
        function updatePercentile(this, percentile)
            if 0
                % Disabled feature
                prepareRowNames(this, percentile)
                
                % Update the table
                rowNames = this.MeasurementsTableData.RowNames;
                hTable = this.WidgetHandles.Measurements;
                if ishghandle(hTable)
                    tableData = get(hTable, 'Data');
                    tableData(:,1) = rowNames;
                    set(hTable, 'Data', tableData);
                end
            end
        end
        %-----------------------------------------------------------------------
        function updateMeasurementsTable(this, hMeasurements)
            if 0
                % Disabled feature
                updatePercentile(this, hMeasurements.Percentile)
                updateMeasurementValues(this, hMeasurements)
            end
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function sz = guiSizes(this)
            % Get the standard size information and add eye scope specific sizing
            sz = commscope.SPWidget.baseGuiSizes;
            
            % Set the font parameters
            sz = commscope.SPWidget.setFontParams(sz);
            
            % Determine minimum table column widths
            rowNames = this.MeasurementsTableData.RowNames;
            columnLabels = this.MeasurementsTableData.ColumnNames;
            margin = largestuiwidth({'s'});
            sz.FirstColWidth = largestuiwidth(rowNames) + margin;
            sz.SecondColWidth = largestuiwidth(columnLabels(2)) + margin;
            
            % Autoscale position
            sz.AutoscaleWidth = largestuiwidth({'Autoscale Axes'}) + 2*sz.hcf;

            % Plot controls minimum width
            sz.PlotCtrlMinWidth = max(largestuiwidth(...
                {'Constellation', 'Signal Trajectory', 'Grid'})+sz.cbTweak, ...
                sz.AutoscaleWidth) + sz.hff*1.5;
        end
        %-----------------------------------------------------------------------
        function createMeasurementsList(this)
            % Create a list of measurements suitable to be used in the
            % measurements table.
            %   structure with field names:
            %       'FieldName'  - name of the object property
            %       'ScreenName' - label that is displayed on the GUI for that
            %                      property
            %       'Unit'       - unit of the property
            %   Each element of the vector represents a measurement that is
            %   displayed in the GUI. 

            fieldNames = {'FieldName', 'ScreenName', 'Unit'};
            measurementsListCell = {...
                'RMSEVM', 'RMS EVM', '%';...
                'MaximumEVM', 'Maximum EVM', '%';
                'PercentileEVM', '%dth Percentile EVM', '%';...
                'MERdB', 'MER', 'dB';...
                'MinimumMER', 'Minimum MER', 'dB';...
                'PercentileMER', '%dth Percentile MER', 'dB'};
            measurementsList = cell2struct(measurementsListCell, fieldNames, 2);

            % Create a structure with field names same as the field names of the
            % measurements object.  Also add a field to store eye diagram object
            % names and column names.
            this.MeasurementsTableData.Measurements = measurementsList;
            this.MeasurementsTableData.ColumnNames = {'Measurement'; 'Value'}';
        end
    end
end

%===============================================================================
% Callback functions
function cbConstellationSelector(src, hPlotSettings)
val = get(src, 'Value');
if val
    hPlotSettings.Constellation = 'on';
else
    hPlotSettings.Constellation = 'off';
end
end
%-------------------------------------------------------------------------------
function cbTrajectorySelector(src, hPlotSettings)
val = get(src, 'Value');
if val
    hPlotSettings.SignalTrajectory = 'on';
else
    hPlotSettings.SignalTrajectory = 'off';
end
end
%-------------------------------------------------------------------------------
function cbGridSelector(src, hPlotSettings)
val = get(src, 'Value');
if val
    hPlotSettings.Grid = 'on';
else
    hPlotSettings.Grid = 'off';
end
end
%-------------------------------------------------------------------------------
function cbAutoscale(hPlotSettings)
autoScaleAxisLimits(hPlotSettings);
end
%-------------------------------------------------------------------------------
function cbPrint(hAxes)
hfig = createPrintFigure(hAxes);
printdlg(hfig)
close(hfig)
end
%-------------------------------------------------------------------------------
function cbPrintPreview(hAxes)
hfig = createPrintFigure(hAxes);
hPP = printpreview(hfig);
addlistener(hPP, 'ObjectBeingDestroyed', @(hSrc, ed)close(hfig));
end
%-------------------------------------------------------------------------------
function hfig = createPrintFigure(hAxes)
hfig = figure('Visible', 'off');
c = copyobj(hAxes, hfig);
set(hfig, 'Position', get(c, 'OuterPosition'))
set(c, 'units', 'normalized')
end
%-------------------------------------------------------------------------------
function menucbHelp(hsrc)
% Callback function for Help menu items

% Get the source
sourceID = get(hsrc, 'Tag');

if strcmp(sourceID, 'HelpScatterPlot')
    helpview([docroot '/toolbox/comm/comm.map'], 'commscope.ScatterPlot');
else
    helpview([docroot '/toolbox/comm/comm.map'], 'scatterplot_measurements');
end
end
%-------------------------------------------------------------------------------
function axesResizeFcn(hParent, hPlotSettings)
% Resize function for the axes

% Get the axes handle
hAxis = get(hParent, 'Children');

% Get container size
contSize = get(hParent, 'Position');
[len idx] = min(contSize(3:4));
pos(3:4) = len;
if idx == 2
    pos(1) = (contSize(3) - len)/2;
    pos(2) = 0;
else
    pos(1) = 0;
    pos(2) = (contSize(4) - len)/2;
end

% Set the axes size
set(hAxis, 'OuterPosition', pos)
try
    axis(hAxis, 'equal');
catch E %#ok<NASGU>
end

% Autoscale
cbAutoscale(hPlotSettings)
end
%-------------------------------------------------------------------------------
function measTableResizeFcn(src, sz)
% Resize function for the measurements table

% Get container size
contSize = get(src, 'Position');

% Get table handle
hTable = get(src, 'Children');

% Calculate column widths
totalWidth = contSize(3);
extraWidth = totalWidth - sz.FirstColWidth - sz.SecondColWidth;
if extraWidth < 0
    extraWidth = 0;
end
colWidth{1} = floor(sz.FirstColWidth + 0.5*extraWidth);
% -4 pixels to get rid of scroll bars
colWidth{2} = floor(sz.SecondColWidth + 0.5*extraWidth) - 4;
set(hTable, 'ColumnWidth', colWidth, 'Position', [0 0  contSize(3) contSize(4)])
end