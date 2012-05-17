function DialogPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA Construct the dialog panel

% Author(s): John Glass
% Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/12/04 22:21:51 $

% First create the GUI panel
DialogPanel = javaObjectEDT('com.mathworks.toolbox.control.sisogui.DesignSnapshotFolderPanel');

% Get the handles
Handles = this.Handles;

% Get and configure the java elements for the available snapshots
SnapshotTable = javaObjectEDT(DialogPanel.getSnapshotTable);
Handles.SnapshotTable = SnapshotTable;

SnapshotTableModel = DialogPanel.getSnapshotTableModel;
Handles.SnapshotTableModel = SnapshotTableModel;
h = handle( SnapshotTableModel, 'callbackproperties' );
h.TableChangedCallback = {@LocalUpdateDescription,this};

DeleteShapshotButton = javaObjectEDT(DialogPanel.getDeleteShapshotButton);
Handles.DeleteShapshotButton = DeleteShapshotButton;
h = handle( DeleteShapshotButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalUpdateDeleteShapshot this};

RetrieveShapshotButton = javaObjectEDT(DialogPanel.getRetrieveShapshotButton);
h = handle( RetrieveShapshotButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRetrieveShapshot this};

StoreShapshotButton = javaObjectEDT(DialogPanel.getStoreShapshotButton);
h = handle( StoreShapshotButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalStoreShapshot this};

% Store the handles
this.Handles = Handles;

% Update the table data
LocalUpdateTableData(this,this.getChildren);

% Add a listener to the children below
this.ChildListListeners = [...
        handle.listener(this,'ObjectChildAdded',{@LocalAddTableData this});...
        handle.listener(this,'ObjectChildRemoved',{@LocalDeleteTableData, this});...
        handle.listener(this,'DesignLabelChanged',{@LocalDesignLabelChanged this})];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalStoreShapshot - Store the selected design
function LocalStoreShapshot(es, ed, this)

% Store the snapshot
this.storeSnapshot;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalRetrieveShapshot - Retrieve the selected design
function LocalRetrieveShapshot(es, ed, this)

rows = this.Handles.SnapshotTable.getSelectedRows;
if numel(rows) == 1
    row = double(rows)+1;
    %% Get the design object
    task = getSISOTaskNode(this);
    sisodb = task.sisodb;
    Design = sisodb.LoopData.History(row);
    %% Import the data
    importdesign(sisodb.LoopData,Design);
else
    errordlg(xlate('Please select a single design to be imported.'),...
        xlate('Simulink Control Design'))
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateDeleteShapshot - Delete the selected snapshots
function LocalUpdateDeleteShapshot(es, ed, this) 

% Disable the child listeners
this.ChildListListeners(1).Enabled = 'off';
this.ChildListListeners(2).Enabled = 'off';

rows = double(this.Handles.SnapshotTable.getSelectedRows) + 1;
% Call the delete view node method on each node in a backwards fashion to
% deal with the new indexing
Children = this.getChildren;
for ct = numel(rows):-1:1
    row = double(rows(ct));
    this.removeNode(Children(row));
    % Get the design object
    task = getSISOTaskNode(this);
    sisodb = task.sisodb;
    % Delete the design object
    Design = sisodb.LoopData.History(row);
    sisodb.LoopData.History(row) = [];
    delete(Design);
end
% Remove the selected rows from the child list.
Children(rows) = [];

% Update the table data
LocalUpdateTableData(this,Children);

% Enable the child listeners
this.ChildListListeners(1).Enabled = 'on';
this.ChildListListeners(2).Enabled = 'on';

% Set the project dirty flag
this.setDirty;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalAddTableData - Callback for a snapshot added
function LocalAddTableData(es, ed, this)

LocalUpdateTableData(this,this.getChildren);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeleteTableData - Callback for a snapshot deleted
function LocalDeleteTableData(es,ed,this)

% Get the children
Children = this.getChildren;

% Get the children that were deleted
ChildrenDeleted = ed.Child;

% Get the design object
task = getSISOTaskNode(this);
sisodb = task.sisodb;

% Remove the children from the list for the table
if ishandle(sisodb)
    for ct = 1:length(ChildrenDeleted)
        ind = find(ChildrenDeleted(ct) == Children);
        Children(ind) = [];
        sisodb.LoopData.History(ind) = [];
    end
end

LocalUpdateTableData(this,Children);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDesignLabelChanged - Update the table based on a name change
function LocalDesignLabelChanged(es, ed, this)

LocalUpdateTableData(this,this.getChildren);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateTableData - Create a object array for the table
function LocalUpdateTableData(this,Children)

import java.lang.*; 

% Get the design history
task = getSISOTaskNode(this);
if ~task.isBeingDestroyed
    DesignHistory = task.sisodb.Loopdata.History;


    %% Set the data
    SnapshotTableModel = this.Handles.SnapshotTableModel;

    if ~isempty(Children)
        table_data = cell(length(Children),2);
        for ct = 1:length(Children)
            table_data{ct,1} = DesignHistory(ct).Name;
            if ~isempty(DesignHistory(ct).Description)
                table_data{ct,2} = DesignHistory(ct).Description;
            else
                table_data{ct,2} = 'Stored Design.';
            end
        end
        SnapshotTableModel.setData(table_data);
    else
        SnapshotTableModel.clearRows
    end
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateDesciprtion - update design history description
function LocalUpdateDescription(es,ed,this)

import java.lang.*; 

Row = ed.getFirstRow;
Col = ed.getColumn;
if ~(isequal(Row,-1) || isequal(Col,-1))
% Get the design history
    task = getSISOTaskNode(this);
    NewString = es.getValueAt(Row,Col);
    task.sisodb.Loopdata.History(Row+1).Description = NewString;
end




