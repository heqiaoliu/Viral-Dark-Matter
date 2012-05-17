function configureTablePanels(this,DialogPanel)
% CONFIGURETABLEPANELS  Configure the state and input panels
%
 
% Author(s): John W. Glass 19-Sep-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/10/31 07:36:24 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State Condition Table
% Set the action callback for the state condition table model and store its
% handle
StateCondTableModel = DialogPanel.getStateCondTableModel;
this.Handles.StateCondTableModel = StateCondTableModel;

% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getStateCondTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalStateTableClick, this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Condition Table
% Set the action callback for the input condition table model and store its
% handle
InputCondTableModel = DialogPanel.getInputCondTableModel;
this.Handles.InputCondTableModel = InputCondTableModel;

% Set the callback for when the user double clicks to inspect a block
h = handle(DialogPanel.getInputCondTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalInputTableClick, this};

% Refresh the tables
% Get the initial state table data
[state_table,state_ind] = this.getStateTableData;
if isempty(this.StateTableData)
    this.StateTableData = state_table;
end
this.StateIndices = state_ind;

% Get the initial input table data
[input_table,input_ind] = this.getInputTableData;
if isempty(this.InputTableData)
    this.InputTableData = input_table;
end
this.InputIndices = input_ind;
refreshTables(this);

% Set the table changed callbacks
h = handle(StateCondTableModel, 'callbackproperties');
h.TableChangedCallback = {@LocalsetStateTableData, this};
h = handle(InputCondTableModel, 'callbackproperties');
h.TableChangedCallback = {@LocalsetInputTableData, this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalsetStateTableData - Callback for when a user changes a table
function LocalsetStateTableData(es,ed,this)

% Get the row and column Indices
row = ed.getFirstRow;
col = ed.getColumn;
setStateTableData(this,this.Handles.StateCondTableModel.data,row,col);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalsetInputTableData - Callback for when a user changes a table
function LocalsetInputTableData(es,ed,this)

% Get the row and column Indices
row = ed.getFirstRow;
col = ed.getColumn;
setInputTableData(this,this.Handles.InputCondTableModel.data,row,col);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalStateTableClick - Callback for when a user clicks on a table
function LocalStateTableClick(es,ed,this)

if ed.getClickCount == 2
    % es is the table
    row = es.getSelectedRow;
    % Determine if a block was selected
    ind = find(this.StateIndices == row);

    if ~isempty(ind) && (numel(this.OpPoint.States) > 0)
        state = this.OpPoint.States(ind);
        block = state.Block;

        try
            dynamicHiliteSystem(slcontrol.Utilities,block)
        catch Ex %#ok<NASGU>
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalInputTableClick - Callback for when a user clicks on a table
function LocalInputTableClick(es,ed,this)

if ed.getClickCount == 2
    % es is the table
    row = es.getSelectedRow;
    % Determine if a block was selected
    ind = find(this.InputIndices == row);

    if ~isempty(ind) && (numel(this.OpPoint.Inputs) > 0)
        input = this.OpPoint.Inputs(ind);
        block = input.Block;
        try
            dynamicHiliteSystem(slcontrol.Utilities,block)
        catch Ex %#ok<NASGU>
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end
