function DialogPanel = getDialogSchema(this, manager)
%  GETDIALOGSCHEMA  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.16 $ $Date: 2008/12/04 23:27:26 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.GenericSimulinkSettingsObjects.OperatingConditionResultsPanel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the table model for the input results table
this.Handles.InputResultsTableModel = DialogPanel.getInputResultsTableModel;

% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getInputResultsTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalInputTableClick this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the table model for the output results table
this.Handles.OutputResultsTableModel = DialogPanel.getOutputResultsTableModel;

% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getOutputResultsTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalOutputTableClick this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the table model for the state results table
this.Handles.StateResultsTableModel = DialogPanel.getStateResultsTableModel;

% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getStateResultsTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalStateTableClick this};

% Update the tables with fresh data
LocalUpdateTables(this)

% Configure a listener to the label changed event
this.addListeners(handle.listener(this,this.findprop('Label'),'PropertyPostSet',...
                        {@LocalLabelChanged, this}));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLabelChanged
function LocalLabelChanged(es,ed,this)
% Get the parent node
parent = this.up;
if isa(parent,'OperatingConditions.OperatingConditionTask');
    send(parent, 'OpPointDataChanged');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalStateTableClick - Callback for when a user clicks on a table
function LocalStateTableClick(es,ed,this)

if ed.getClickCount == 2
    % es is the table
    row = es.getSelectedRow;
    % Get the valid rows to click on
    blocks = cell(this.StateIndices);
    % Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind) && (numel(this.OpReport.States) > 0)
        state = this.OpReport.States(ind);
        if isa(state,'opcond.StateReport')
            block = state.Block;
        else
            block = state.SimMechBlock;
        end
        try
            dynamicHiliteSystem(slcontrol.Utilities,block)
        catch Ex
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalInputTableClick - Callback for when a user clicks on a table
function LocalInputTableClick(es,ed,this)

if ed.getClickCount == 2
    % es is the table
    row = es.getSelectedRow;
    % Get the valid rows to click on
    blocks = cell(this.InputIndices);
    % Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind) && (numel(this.OpReport.Inputs) > 0)
        block = this.Handles.InputResultsTableModel.data(blocks{ind}+1,1);
        try
            dynamicHiliteSystem(slcontrol.Utilities,block)
        catch Ex
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalOutputTableClick - Callback for when a user clicks on a table
function LocalOutputTableClick(es,ed,this)

if ed.getClickCount == 2
    %% es is the table
    row = es.getSelectedRow;
    %% Get the valid rows to click on
    blocks = cell(this.OutputIndices);
    %% Determine if a block was selected
    ind = find([blocks{:}] == row);

    if ~isempty(ind) && (numel(this.OpReport.Outputs) > 0)
        block = this.Handles.OutputResultsTableModel.data(blocks{ind}+1,1);
        try
            dynamicHiliteSystem(slcontrol.Utilities,block)
        catch Ex
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCALUPDATETABLES - Function to update the results tables with the new
%% data.
function LocalUpdateTables(this)

%%%%%% INPUT TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the table data for the input results table
table_data = this.getInputResultsTableData;

% Create the cell attributes
cellAtt = CreateCellAttrib(table_data(2), size(table_data(1),1), 3);
this.Handles.InputResultsTableModel.setDataAndUpdate(table_data(1), cellAtt);
this.InputIndices = table_data(2);

%%%%%% OUTPUT TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the table data for the output results table
table_data = this.getOutputResultsTableData;

% Create the cell attributes
cellAtt = CreateCellAttrib(table_data(2), size(table_data(1),1), 3);
this.Handles.OutputResultsTableModel.setDataAndUpdate(table_data(1), cellAtt);
this.OutputIndices = table_data(2);

%%%%%% STATE TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the table data for the state results table
table_data = this.getStateResultsTableData;

% Create the cell attributes
cellAtt = CreateCellAttrib(table_data(2), size(table_data(1),1), 5);
this.Handles.StateResultsTableModel.setDataAndUpdate(table_data(1), cellAtt);
this.StateIndices = table_data(2);
