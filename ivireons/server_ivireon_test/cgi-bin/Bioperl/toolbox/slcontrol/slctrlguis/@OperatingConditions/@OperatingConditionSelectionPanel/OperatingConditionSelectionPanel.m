function this = OperatingConditionSelectionPanel(DialogPanel,OpCondNode)
%  OperatingConditionSelectionPanel Constructor for @OperatingConditionSelectionPanel class
%
%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/12/04 23:27:33 $

% Create class instance
this = OperatingConditions.OperatingConditionSelectionPanel;
% Store the operating conditions node
this.OpCondNode = OpCondNode;
% Store the java panel handle
this.Handles.JavaPanel = DialogPanel;

% Configure the panel

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Operating Condition Selection Table
%  Get the handle to the operating condition selection table
OpCondTableModel = DialogPanel.getOpCondTableModel;
this.Handles.OpCondTableModel = OpCondTableModel;

% Set the table data get it from the operating conditions below
LocalUpdateAvailableOperatingConditionsAdded(OpCondNode,[],this)

% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(OpCondTableModel);
javaMethodEDT('fireTableChanged',OpCondTableModel,evt);

% Add a listener to the operating condition table node
this.OperatingConditionsListeners = [...
        handle.listener(OpCondNode,'ObjectChildAdded',{@LocalUpdateAvailableOperatingConditionsAdded, this});...
        handle.listener(OpCondNode,'ObjectChildRemoved',{@LocalUpdateAvailableOperatingConditionsDeleted, this});...
        handle.listener(OpCondNode,'OpPointDataChanged',{@LocalUpdateData, this});...
        ];

% Set the callback for the AnalysisResultsTableModel
UDD_hdl = handle(OpCondTableModel,'callbackproperties');
listener = handle.listener(UDD_hdl,'tableChanged',{@LocalOpCondTableModelCallback,this});
this.Handles.MATLABOpCondTableModel = [UDD_hdl,listener];

% Set the first row to be selected
javaMethodEDT('setRowSelectionInterval',DialogPanel.getOpCondTable,0,0)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LocalUpdateData(OpCondNode,ed,this)

% Get the handle to the operating conditions node children
Children = this.OpCondNode.getChildren;
OpCondTableModel = this.Handles.OpCondTableModel;

% Disable the table data callback
hdl = this.Handles.MATLABOpCondTableModel;
hdl(2).Enabled = 'off';

% Set the table data get it from the operating conditions below
OpCondTableModel.setData(LocalCreateOperatingConditionsTable(Children));

% Set the first row to be selected
javaMethodEDT('setRowSelectionInterval',this.Handles.JavaPanel.OpCondTable,0,0)

% Clear the event queue
drawnow

% Renable the table data changed callback
hdl(2).Enabled = 'on';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOpCondTableModelCallback
function LocalOpCondTableModelCallback(es,ed,this)

%% Get the view children
if ishandle(this) && ...
    isa(this.OpCondNode,'OperatingConditions.OperatingConditionTask')
    ch = this.OpCondNode.getChildren;
    %% Get the row and column information
    row = ed.JavaEvent.getFirstRow+1;
    col = ed.JavaEvent.getColumn+1;

    switch col
        case 1
            ch(row).Label = this.Handles.OpCondTableModel.data(row,col);
        case 2
            ch(row).Description = this.Handles.OpCondTableModel.data(row,col);            
    end
    send(this.OpCondNode, 'OpPointDataChanged');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalUpdateAvailableOperatingConditionsAdded - Update the available operating
%  conditions table
function LocalUpdateAvailableOperatingConditionsAdded(OpCondNode,ed,this)

%% Get the handle to the operating conditions node children
Children = OpCondNode.getChildren;

%% Set the table data get it from the operating conditions below
OpCondTableModel = this.Handles.OpCondTableModel;
OpCondTableModel.setData(LocalCreateOperatingConditionsTable(Children));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalUpdateAvailableOperatingConditionsDeleted - Update the available operating
%  conditions table
function LocalUpdateAvailableOperatingConditionsDeleted(OpCondNode,ed,this)

%% Get the handle to the operating conditions node children
Children = OpCondNode.getChildren;

%% Get the chilren that were deleted
ChildrenDeleted = ed.Child;

%% Remove the children from the list for the table
for ct = 1:length(ChildrenDeleted)
    Children(ChildrenDeleted(ct) == Children) = [];
end

%% Set the table data get it from the operating conditions below
OpCondTableModel = this.Handles.OpCondTableModel;
OpCondTableModel.setData(LocalCreateOperatingConditionsTable(Children));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCreateOperatingConditionsTable - Create a table containing a list
%  of the available operating conditions
function table_data = LocalCreateOperatingConditionsTable(Children)

if ~isempty(Children)
    table_data = javaArray('java.lang.Object',length(Children),2);
    for ct = 1:length(Children)
        table_data(ct,1) = java.lang.String(Children(ct).Label);
        table_data(ct,2) = java.lang.String(Children(ct).Description);
    end
else
    table_data = javaArray('java.lang.Object',1,2);
    table_data(1,1) = java.lang.String('No operating point available');
    table_data(1,2) = java.lang.String('');
end
