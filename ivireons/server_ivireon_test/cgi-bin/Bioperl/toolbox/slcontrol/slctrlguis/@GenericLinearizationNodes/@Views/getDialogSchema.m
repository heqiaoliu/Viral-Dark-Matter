function DialogPanel = getDialogSchema(this, manager)
%%  getDialogSchema  Construct the dialog panel

%%  Author(s): John Glass
%%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2008/12/04 23:27:12 $

DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.GenericLinearizationObjects.AllViewsPanel');

% Get and configure the table for the available views
ViewTable = DialogPanel.getViewTable;
this.Handles.ViewTable = ViewTable;

ViewTableModel = DialogPanel.getViewTableModel;
this.Handles.ViewTableModel = ViewTableModel;

% Get the data if it exists, otherwise store the initial state
if isempty(this.ViewTableData)
    this.ViewTableData = ViewTableModel.data;
else
    ViewTableModel.data = this.ViewTableData;
end

% Set the callback for the ViewTableModel
h = handle( ViewTableModel, 'callbackproperties' );
h.TableChangedCallback = {@LocalViewTableModelCallback,this};

% Update the list
LocalUpdateAvailableViewsAdded([],[],this);

% Get and configure the new button for the new view callback
NewViewButton = DialogPanel.getNewViewButton;
this.Handles.NewViewButton = NewViewButton;
h = handle( NewViewButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalNewViewCallback,this};

% Get and configure the new button for the new view callback
DeleteViewButton = DialogPanel.getDeleteViewButton;
this.Handles.DeleteViewButton = DeleteViewButton;
h = handle( DeleteViewButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalDeleteViewCallback,this};

% Add a listener to the children below
this.ChildListListeners = [...
        handle.listener(this,'ObjectChildAdded',{@LocalUpdateAvailableViewsAdded, this});...
        handle.listener(this,'ObjectChildRemoved',{@LocalUpdateAvailableViewsDeleted, this})];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalPlotSetupTableModelCallback
function LocalViewTableModelCallback(es,ed,this)

if ishandle(this)
    % Get the view children
    ch = this.getChildren;

    % Get the row and column information
    row = ed.getFirstRow+1;
    col = ed.getColumn+1;

    if (col == 2)
        ch(row).Description = this.Handles.ViewTableModel.data(row,col);
        this.ViewTableData(row,col) = java.lang.String(this.Handles.ViewTableModel.data(row,col));
    end

    % Set the project dirty flag
    this.setDirty;
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateAvailableViewsAdded - Update the ViewTable 
%%
function LocalUpdateAvailableViewsAdded(es,ed,this)

% Get the handle to the view children
Children = this.getChildren;

% Set the table data get it from the views
LocalUpdateTableData(Children,this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateAvailableViewsDeleted
function LocalUpdateAvailableViewsDeleted(es,ed,this)

% Get the handle to the operating conditions node children
Children = this.getChildren;

% Get the chilren that were deleted
ChildrenDeleted = ed.Child;

% Remove the children from the list for the table
for ct = 1:length(ChildrenDeleted)
    Children(ChildrenDeleted(ct) == Children) = [];
end

% Set the table data get it from the views
LocalUpdateTableData(Children,this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUpdateTableData - Create a object array for the talbe
%% 
function LocalUpdateTableData(Children,this)

ViewTableModel = this.Handles.ViewTableModel;

if ~isempty(Children)
    table_data = javaArray('java.lang.Object',length(Children),2);
    for ct = 1:length(Children)
        table_data(ct,1) = java.lang.String(Children(ct).Label);
        table_data(ct,2) = java.lang.String(Children(ct).Description);
    end
    ViewTableModel.setData(table_data);
    this.ViewTableData = table_data;
else
    ViewTableModel.clearRows    
    this.ViewTableData = ViewTableModel.data;
end

% Set the project dirty flag
this.setDirty;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalNewViewCallback - Create a new view
%% 
function LocalNewViewCallback(es,ed,this)

% Get the handle to the explorer frame
ExplorerFrame = slctrlexplorer;

% Clear the status area
ExplorerFrame.clearText;

% Create the view settings node
ViewSettingsNode = GenericLinearizationNodes.ViewSettings(length(this.getChildren)+1);
ViewSettingsNode.Label = ViewSettingsNode.createDefaultName(sprintf('View'), this);

% Add the view settings node to the tree
this.addNode(ViewSettingsNode);
% Expand the views nodes so the user sees the new result
ExplorerFrame.expandNode(this.getTreeNodeInterface);

ExplorerFrame.postText(sprintf(' - A new view has been added.'))

% Set the project dirty flag
this.setDirty;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDeleteViewCallback - Delete the selected views
%% 
function LocalDeleteViewCallback(es,ed,this)

rows = this.Handles.ViewTable.getSelectedRows;
% Call the delete view node method on each node in a backwards fashion to
% deal with the new indexing
Children = this.getChildren;
for ct = length(rows):-1:1
    this.removeNode(Children(double(rows(ct))+1));
end

% Set the project dirty flag
this.setDirty;
