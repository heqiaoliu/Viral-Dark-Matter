function DialogPanel = getDialogSchema(this, manager)
%%  getDialogSchema  Construct the dialog panel

%%  Author(s): John Glass
%%  Revised:
%% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.14 $ $Date: 2008/12/04 23:27:08 $

% Create the panel
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.LinearizationViewConfiguration.MainConfigurationInterface');

% Set the callback for the FigureSetupTableModel
PlotSetupTableModel = DialogPanel.getPlotSetupTableModel;

% Get the data if it exists, otherwise store the initial state
if isempty(this.PlotSetupTableData)
    this.PlotSetupTableData = PlotSetupTableModel.data;
else
    PlotSetupTableModel.data = this.PlotSetupTableData;
end

% Set the callback for the PlotSetupTableModel
MATLABPlotSetupTableModel = handle(PlotSetupTableModel,'callbackproperties');
listener = handle.listener(MATLABPlotSetupTableModel,'tableChanged',{@LocalPlotSetupTableModelCallback,this});
this.Handles.PlotSetupTableModel = PlotSetupTableModel;
this.Handles.MATLABPlotSetupTableModel = [MATLABPlotSetupTableModel,listener];

% Get the handle to the FigureSetupTable
this.Handles.PlotSetupTable = DialogPanel.getPlotSetupTable;

% Set the callback for the VisibleResultTableModel
VisibleResultTableModel = DialogPanel.getVisibleResultTableModel;

% Get the data if it exists, otherwise store the initial state
if isempty(this.VisibleResultTableData)
    this.VisibleResultTableData = VisibleResultTableModel.data;
else
    VisibleResultTableModel.data = this.VisibleResultTableData;
end

% Set the callback for the PlotSetupTableModel
MATLABVisibleResultTableModel = handle(VisibleResultTableModel,'callbackproperties');
listener = handle.listener(MATLABVisibleResultTableModel,'tableChanged',{@LocalVisibleResultTableModelCallback,this});
this.Handles.VisibleResultTableModel = VisibleResultTableModel;
this.Handles.MATLABVisibleResultTableModel = [MATLABVisibleResultTableModel,listener];

% Get the handle to the VisibleResultTable
this.Handles.VisibleResultTable = DialogPanel.getVisibleResultTable;

% Set the callback for the UpdateViewButton
h = handle( DialogPanel.getUpdateViewButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalUpdateViewButtonCallback,this};

% Get the handle to the auto add checkbox
this.Handles.AutoAddCheckbox = DialogPanel.getAutoAddCheckBox;

% Add listener to the analysis results above
ResultsNode = this.up.up;
this.LinearizationResultsListeners = [...
    handle.listener(ResultsNode,'ObjectChildAdded',{@LocalUpdateLinearizationResultsAdded,this});...
    handle.listener(ResultsNode,'ObjectChildRemoved',{@LocalUpdateLinearizationResultsDeleted,this});...
    handle.listener(ResultsNode,'AnalysisLabelChanged',{@LocalUpdateLinearizationResultLabel, this})];

% Initialize the table
if ~isempty(ResultsNode.getChildren)
    LocalUpdateLinearizationResultsAdded(ResultsNode,[],this);
end

% Get the visible system table column handles to be hidden
ColumnModel = this.Handles.VisibleResultTable.getColumnModel;
TableColumns = this.VisibleTableColumns;
for ct = 6:-1:1
    TableColumns{ct,1} = ColumnModel.getColumn(ct);
    if strcmpi(this.PlotConfigurations(ct,2),'None')
        TableColumns{ct,2} = false;
        ColumnModel.removeColumn(TableColumns{ct,1});
    else
        TableColumns{ct,2} = true;
    end    
end
this.VisibleTableColumns = TableColumns;

% Create a listener to delete the ltiplot
createDeleteListener(this)

% Create the right click menus
this.getPopupInterface(manager);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions 
%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultLabel
function LocalUpdateLinearizationResultLabel(ResultNode,ed,this)

%% Get the children of the analysis results
ch = ResultNode.getChildren;
%% Get the element that has been updated
row = ed.Data;
%% Update the table data.  This is always the first column.
this.Handles.VisibleResultTableModel.setValueAt(java.lang.String(ch(row).Label),row-1,0);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalPlotSetupTableModelCallback
function LocalPlotSetupTableModelCallback(es,ed,this)

%% Call the set plot configuration data method to update the ltiviewer
this.setPlotConfigurationData(this.Handles.PlotSetupTableModel.data,...
                                        ed.JavaEvent.getFirstRow,ed.JavaEvent.getColumn);

%% Set the dirty flag
this.setDirty

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultsAdded - Callback for when the available
%% analysis results are added.
function LocalUpdateLinearizationResultsAdded(ResultsNode,ed,this)

%% Get the children
Children = LocalFindAnalysisResultsChildren(ResultsNode.getChildren);

if length(Children) > 0
    %% Find the children that have been added
    old_table_data = this.Handles.VisibleResultTableModel.data;

    %% Get the number of new elements
    n_new_elements = length(Children) - size(old_table_data,1);

    if n_new_elements > 0
        %% Create data for a new row for each new child
        new_table_data = javaArray('java.lang.Object', n_new_elements, 7);

        %% Determine if the new result should be added
        showplot = this.Handles.AutoAddCheckbox.isSelected;

        %% Get the new children
        NewChildren = Children(length(Children)-n_new_elements+1:end);

        %% Get the storage of the analysis results pointers
        AnalysisResultPointers = this.AnalysisResultPointers;

        %% Add the results to the new table data
        for ct = 1:n_new_elements
            new_table_data(ct,1) = java.lang.String(NewChildren(ct).Label);
            %% Store a pointer to the analysis result node
            AnalysisResultPointers{end+1,1} = NewChildren(ct);
            %% Add the system to the viewer if needed
            if (isa(this.LTIViewer,'viewgui.ltiviewer') && showplot)
                this.DeleteViewListeners.Enabled = 'off';
                this.LTIViewer.importsys(sprintf('%s',NewChildren(ct).Label),NewChildren(ct).LinearizedModel);
                %% Store a pointer to the ltisource for tracking later
                AnalysisResultPointers{end,2} = this.LTIViewer.Systems(end);
                this.DeleteViewListeners.Enabled = 'on';
            else
                AnalysisResultPointers{end,2} = handle(0);
            end
        end

        %% Set the storage of the analysis results pointers
        this.AnalysisResultPointers = AnalysisResultPointers;

        %% Set the new data visible boolean values
        new_table_data(:,2:7) = java.lang.Boolean(showplot);

        %% Concatinate the table data
        this.Handles.VisibleResultTableModel.setData([old_table_data; new_table_data]);
        
        %% Update the listeners for the visible systems
        if isa(this.LTIViewer,'viewgui.ltiviewer')
            createVisibilityListeners(this)
        end
    end
end
            
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateLinearizationResultsDeleted - Callback for when the available
%% analysis results are deleted.
function LocalUpdateLinearizationResultsDeleted(ResultsNode,ed,this)

%% Get the children
Children = LocalFindAnalysisResultsChildren(ResultsNode.getChildren);

%% Get the child the has been deleted
DeletedChild = ed.Child;

%% Get the number of current Children
nChildren = length(Children);

%% Find the index of the row that has been deleted
index = find(DeletedChild == Children);

%% Delete the result from the pointer storage
this.AnalysisResultPointers = this.AnalysisResultPointers([1:index-1,index+1:end],:);

%% Remove the system to the viewer if needed
if isa(this.LTIViewer,'viewgui.ltiviewer')
    this.DeleteViewListeners.Enabled = 'off';
    this.LTIViewer.deletesys(sprintf('%s',DeletedChild.Label));
    this.DeleteViewListeners.Enabled = 'on';
end

%% Get the old table data
old_table_data = this.Handles.VisibleResultTableModel.data;

%% Create a new java.lang.Object for the table
if (nChildren-1) > 0
    new_table_data = javaArray('java.lang.Object', nChildren-1, 7);
    
    %% Populate the table data.  Need to handle the case where indexing a
    %% single row of a java.lang.Object[][] returns a java.lang.Object[]
    %% where the vector is now a column vector.
    if (nChildren-1 == 1)
        new_table_data(1) = old_table_data([1:index-1,index+1:nChildren],:);    
    else
        new_table_data(:,:) = old_table_data([1:index-1,index+1:nChildren],:);
    end
    % Store the data in the table model
    this.Handles.VisibleResultTableModel.setData(new_table_data);
else
    % Clear the rows
    this.Handles.VisibleResultTableModel.clearRows;
end

%% Update the listeners for the visible systems
if isa(this.LTIViewer,'viewgui.ltiviewer')
    createVisibilityListeners(this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                        
%% LocalUpdateViewButtonCallback - Callback for the update view button
function LocalUpdateViewButtonCallback(es,ed,this)   

this.DisplayView;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                        
%% LocalVisibleResultTableModelCallback - Callback for the visible result
%% table.
function LocalVisibleResultTableModelCallback(es,ed,this)

this.setVisibleSystemTableData(ed.JavaEvent.getFirstRow, ed.JavaEvent.getColumn);

%% Set the dirty flag
this.setDirty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalFindAnalysisResultsChildren
function Children = LocalFindAnalysisResultsChildren(Children);

%% Loop over all the elements to remove the not of the class
%% GenericLinearizationNodes.LinearAnalysisResultNode
for ct = length(Children):-1:1
    if ~isa(Children(ct),'GenericLinearizationNodes.LinearAnalysisResultNode')
        Children(ct) = [];    
    end
end
