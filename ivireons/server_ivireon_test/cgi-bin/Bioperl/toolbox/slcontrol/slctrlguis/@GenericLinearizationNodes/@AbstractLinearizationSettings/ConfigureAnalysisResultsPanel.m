function ConfigureAnalysisResultsPanel(this,DialogPanel)
%  ConfigureAnalysisResultsPanel  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.13 $ $Date: 2008/12/04 23:26:57 $

this.Handles.AnalysisResultsPanel = DialogPanel.AnalysisResultsPanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete Result Button
% Set the action callback for the delete button and store its
% handle
h = handle( this.Handles.AnalysisResultsPanel.getDeleteButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalDeleteResultCallback,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Table Model and Table
% Get and store the handle to the table model
this.Handles.AnalysisResultsTableModel = this.Handles.AnalysisResultsPanel.getTableModel;
% Set the callback for the AnalysisResultsTableModel
MATLABAnalysisResultsTableModel = handle(this.Handles.AnalysisResultsTableModel,'callbackproperties');
listener = handle.listener(MATLABAnalysisResultsTableModel,'tableChanged',{@LocalAnalysisResultsTableModelCallback,this});
this.Handles.MATLABAnalysisResultsTableModel = [MATLABAnalysisResultsTableModel,listener];

this.Handles.AnalysisResultsTable = this.Handles.AnalysisResultsPanel.getTable;
% Add a listener to the mouse clicked callback
h = handle( this.Handles.AnalysisResultsTable, 'callbackproperties' );
h.MouseClickedCallback = {@LocalResultTableClicked, this};

% Add a listener to the operating condition table node
this.LinearizationResultsListeners = [...
        handle.listener(this,'ObjectChildAdded',{@LocalUpdateLinearizationResultsAdded,this});...
        handle.listener(this,'ObjectChildRemoved',{@LocalUpdateLinearizationResultsRemoved,this});...
        handle.listener(this,'AnalysisLabelChanged',{@LocalUpdateLinearizationResultLabel, this})];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateLinearizationResultLabel - Update the linearization table
function LocalUpdateLinearizationResultLabel(es,ed,this)

% Set the table data get it from the linearization results
AnalysisResultsTableModel = this.Handles.AnalysisResultsTableModel;

% Disable the table data callback
hdl = this.Handles.MATLABAnalysisResultsTableModel(2);
hdl.Enabled = 'off';

% Recreate the table
Children = this.getChildren;

% Loop over all the elements to remove the not of the class
% GenericLinearizationNodes.LinearAnalysisResultNode
Children = LocalFindAnalysisResultsChildren(Children);

if ~isempty(Children)
    AnalysisResultsTableModel.data = LocalCreateAnalysisResultTable(Children);
    javaMethodEDT('fireTableDataChanged',AnalysisResultsTableModel);
end

% Restore the TableChangedCallback
drawnow
hdl.Enabled = 'on';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalAnalysisResultsTableModelCallback
function LocalAnalysisResultsTableModelCallback(es,ed,this)

% Get the row and column information
row = ed.JavaEvent.getFirstRow+1;
col = ed.JavaEvent.getColumn+1;

switch col
    case 1
        %% Get the linearization children
        ch = this.getChildren;
        ch(row).Label = this.Handles.AnalysisResultsTableModel.data(row,col);
        eventData = ctrluis.dataevent(this,'AnalysisLabelChanged',row);
        send(this, 'AnalysisLabelChanged',eventData);
    case 2
        %% Get the linearization children
        ch = this.getChildren;
        ch(row).Description = this.Handles.AnalysisResultsTableModel.data(row,col);    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalResultTableClicked - Callback the clicking of the table
function LocalResultTableClicked(es,ed,this)

rows = this.Handles.AnalysisResultsTable.getSelectedRows + 1;

if (ed.getClickCount == 2)
    Children = LocalFindAnalysisResultsChildren(this.getChildren);
    if (numel(Children) > 0) && (numel(rows) == 1)
        %% Get the frame and workspace handles
        [FRAME,WSHANDLE] = slctrlexplorer;   
        %% Expand by default to show the default operating condition
        FRAME.setSelected(Children(rows).getTreeNodeInterface);        
    end    
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeleteResultCallback - Callback for the delete button to 
% delete the selected linearization.
function LocalDeleteResultCallback(es,ed,this)

rows = this.Handles.AnalysisResultsTable.getSelectedRows;
% Call the delete result method on each node in a backwards fashion to
% deal with the new indexing
Children = this.getChildren;
for ct = length(rows):-1:1
    this.removeNode(Children(double(rows(ct))+1));
end

% Set the project dirty flag
this.setDirty

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateLinearizationResultsAdded - Update the linearization results
function LocalUpdateLinearizationResultsAdded(es,ed,this)

% Set the table data get it from the linearization results
AnalysisResultsTableModel = this.Handles.AnalysisResultsTableModel;

% Recreate the table
Children = this.getChildren;

% Loop over all the elements to remove the not of the class
% GenericLinearizationNodes.LinearAnalysisResultNode
Children = LocalFindAnalysisResultsChildren(Children);

AnalysisResultsTableModel.data = LocalCreateAnalysisResultTable(Children);
javaMethodEDT('fireTableDataChanged',AnalysisResultsTableModel);
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateLinearizationResultsRemoved - Update the linearization results
function LocalUpdateLinearizationResultsRemoved(es,ed,this)

% Set the table data get it from the linearization results
AnalysisResultsTableModel = this.Handles.AnalysisResultsTableModel;

% Get the chilren that were deleted
ChildrenDeleted = ed.Child;
% Recreate the table
Children = this.getChildren;

% Remove the children from the list for the table
for ct = 1:length(ChildrenDeleted)
    Children(ChildrenDeleted(ct) == Children) = [];
end

% Loop over all the elements to remove the not of the class
% GenericLinearizationNodes.LinearAnalysisResultNode
Children = LocalFindAnalysisResultsChildren(Children);

if ~isempty(Children)
    AnalysisResultsTableModel.data = LocalCreateAnalysisResultTable(Children);
    javaMethodEDT('fireTableDataChanged',AnalysisResultsTableModel);
else
    javaMethodEDT('clearRows',AnalysisResultsTableModel);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCreateAnalysisResultTable - Update the linearization results table
function table_data = LocalCreateAnalysisResultTable(Children)

table_data = javaArray('java.lang.Object',length(Children),2);
for ct = 1:length(Children)
    table_data(ct,1) = java.lang.String(Children(ct).Label);
    table_data(ct,2) = java.lang.String(Children(ct).Description);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalFindAnalysisResultsChildren
function Children = LocalFindAnalysisResultsChildren(Children)

% Loop over all the elements to remove the not of the class
% GenericLinearizationNodes.LinearAnalysisResultNode
for ct = length(Children):-1:1
    if ~isa(Children(ct),'GenericLinearizationNodes.LinearAnalysisResultNode')
        Children(ct) = [];    
    end
end
