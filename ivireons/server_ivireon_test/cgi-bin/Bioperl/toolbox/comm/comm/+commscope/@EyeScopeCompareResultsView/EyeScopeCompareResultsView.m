classdef EyeScopeCompareResultsView < commscope.ScopeFace
    %EyeScopeCompareResultsView Construct a compare results scope face for EyeScope
    %
    %   Warning: This undocumented function may be removed in a future release.

    % Copyright 2008-2009 The MathWorks, Inc.
    % $Revision: 1.1.6.5 $  $Date: 2009/07/14 03:52:09 $

    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        ShowQuadrature = false;     % Flag to determine if the quadrature data 
                                    % will be displayed
        LegendState = 'on';         % Determines if the legend is on or off
    end

    %===========================================================================
    % Public methods
    methods
        render(this)
        update(this)
        %-----------------------------------------------------------------------
        function this = EyeScopeCompareResultsView(parent, eyeObjMgr, ...
                sPanelMgr, mPanelMgr)
            % Constructor
            this.Parent = parent;
            this.SettingsPanel = sPanelMgr;
            this.MeasurementsPanel = mPanelMgr;
            this.EyeDiagramObjMgr = eyeObjMgr;
        end
        %-----------------------------------------------------------------------
        function cbSelectionTableTest(this, edata)
            % This function is for the uitable callback test.
            updateSelected(this.MeasurementsPanel, edata.Indices, edata.NewData);
            updateCompareTablePlot(this)
        end
        %-----------------------------------------------------------------------
        function plotToFigure(this)
            % Plot the compare results figure to an independent figure window 
            handles = this.WidgetHandles;
            doubleYAxes = handles.Axes;
            hFig = figure('Visible', 'off', ...
                'Tag', 'EyeScopeComparePlot');

            % Delete colorbar, pan, and rotate buttons from the figure
            delete(findall(hFig, 'Tag', 'Annotation.InsertColorbar'))
            delete(findall(hFig, 'Tag', 'Exploration.Pan'))
            delete(findall(hFig, 'Tag', 'Exploration.Rotate'))
            
            copyobj(doubleYAxes, hFig);
            
            % Make figure visible
            set(hFig, 'NextPlot', 'new')
            set(hFig, 'Visible', 'on')
        end
        %-----------------------------------------------------------------------
        function setLegend(this, value)
            this.LegendState = value;
            handles = this.WidgetHandles;
            if isvalid(handles.Axes)
                handles.Axes.Legend = value;
            end
        end
        %-----------------------------------------------------------------------
        function value = getLegend(this)
            value = this.LegendState;
        end
        %-----------------------------------------------------------------------
        function reset(this)
            this.ShowQuadrature = false;
            this.LegendState = 'on';
        end
        %-----------------------------------------------------------------------
        function idx = getSelectedEyeObj(this)
            % Return the index of the selected eye object.
            hTable = this.WidgetHandles.Table;
            idx = get(hTable, 'UserData');
        end
        %-----------------------------------------------------------------------
        function removeEyeDiagramObject(this)
            % Remove the selected eye diagram object
            idx = getSelectedEyeObj(this);
            hGui = getappdata(this.Parent, 'GuiObject');
            deleteEyeDiagramObject(hGui, idx);

            % Reset the selected item index since uitable removes the highlight.
            set(this.WidgetHandles.Table, 'UserData', []);
            
            % Update the table buttons
            updateTableButtons(this)
            
            % Update the Remove eye diagram object menu item
            updateMenu(this)
        end
    end
    
    %===========================================================================
    % Private methods
    methods (Access = private)
        sz = guiSizes(this)
        %-----------------------------------------------------------------------
        function [hTable exception] = renderInfoTable(this, hPanel, hInfo)
            % Render the contents of the info panel

            eyeObjs = getEyeObjects(this.EyeDiagramObjMgr);

            [tableData columnLabels exception] = ...
                prepareTableData(hInfo, eyeObjs);

            hTable = commgui.table(...
                'Parent', hPanel, ...
                'ColumnLabels', columnLabels, ...
                'TableData', tableData);
        end
        %-----------------------------------------------------------------------
        function exception = updateInfoTable(this, hTable, hInfo)
            % Update the contents of the info panel

            eyeObjs = getEyeObjects(this.EyeDiagramObjMgr);

            [tableData columnLabels exception] = ...
                prepareTableData(hInfo, eyeObjs);

            set(hTable, 'TableData', tableData, 'ColumnLabels', columnLabels);

        end
        %-----------------------------------------------------------------------
        function hTable = renderSelector(this, hPanel, sz)
            % Render the selector measurements panel

            tableData = prepareSelectedTableData(this.MeasurementsPanel);

            x = sz.SelectorTableX;
            y  = sz.SelectorTableY;
            width = sz.SelectorTableWidth;
            height = sz.SelectorTableHeight;
            hTable = uitable(...
                'Parent', hPanel, ...
                'ColumnFormat', {'logical', 'char'}, ...
                'ColumnName', [], ...
                'RowName', [], ...
                'Units', 'pixels', ...
                'Position', [x y width height], ...
                'ColumnWidth', {18 width-18-8}, ...
                'ColumnEditable', [true false], ...
                'Data', tableData, ...
                'CellEditCallback', {@(hsrc, edata)cbSelectionTable(edata, this)}, ...
                'Tag', 'MeasurementsSelectorTable');
        end
        %-----------------------------------------------------------------------
        function updateCompareTablePlot(this)
            [tableData columnLabels yLabels] = ...
                formatCompareTableData(this.MeasurementsPanel, ...
                this.ShowQuadrature);

            handles = this.WidgetHandles;
            set(handles.Table, ...
                'Data', tableData, ...
                'ColumnName', columnLabels);

            % If there is data in the table, make sure that the column labels
            % fit to the columns
            numCol = length(columnLabels);
            if numCol
                columnWidths = cell(1, numCol);
                margin = largestuiwidth({'s'});
                for p=1:numCol
                    columnWidths{p} = largestuiwidth(columnLabels(p)) + margin;
                end
                set(handles.Table, 'ColumnWidth', columnWidths);
            end
            
            % Remove all the lines
            deleteAll(handles.Axes)
            % Plot the selected measurements
            plotMeasurements(this, tableData, columnLabels, yLabels)
        end
        %-----------------------------------------------------------------------
        function updateSelector(this)
            % Update the selector measurements panel
            tableData = prepareSelectedTableData(this.MeasurementsPanel);
            set(this.WidgetHandles.MeasurementsPanelContents, 'Data', tableData);
        end
        %-----------------------------------------------------------------------
        function updateTableButtons(this)
            % Update the 'X', '+', up, and down buttons of the measurements
            % results table
            handles = this.WidgetHandles;
            hTable = handles.Table;

            selectedIdx = get(hTable, 'UserData');
            if isempty(selectedIdx)
                set(handles.AddButton, 'Enable', 'on');
                set(handles.DelButton, 'Enable', 'off');
                set(handles.UpButton, 'Enable', 'off');
                set(handles.DownButton, 'Enable', 'off');
            else
                set(handles.AddButton, 'Enable', 'on');
                set(handles.DelButton, 'Enable', 'on');
                if selectedIdx == 1
                    set(handles.UpButton, 'Enable', 'off');
                else
                    set(handles.UpButton, 'Enable', 'on');
                end
                numRows = size(get(hTable, 'Data'), 1);
                if selectedIdx == numRows
                    set(handles.DownButton, 'Enable', 'off');
                else
                    set(handles.DownButton, 'Enable', 'on');
                end
            end
        end
    end
end

%===============================================================================
% Helper/Callback functions
function cbSelectionTable(edata, this)
updateSelected(this.MeasurementsPanel, edata.Indices, edata.NewData);
updateCompareTablePlot(this)
end
