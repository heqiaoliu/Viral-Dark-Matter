function configureStateConstraintTable(this)
%  configureStateConstraintTable  Construct the output constraint table panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.15 $ $Date: 2008/10/31 07:36:42 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State Constraint Table
% Set the action callback for the state constraint table model and store its
% handle
StateConstrTableModel = this.Handles.OpCondSpecPanel.getStateConstrTableModel;
this.Handles.StateConstrTableModel = StateConstrTableModel;
h = handle(this.Handles.StateConstrTableModel, 'callbackproperties');
h.TableChangedCallback = {@LocalUpdateSetStateConstrTableData this};

% Set the callback for when the user double clicks to inspect a block
h = handle(this.Handles.OpCondSpecPanel.getStateConstrTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalTableClick this};

% Set the action callback for the state constraint table fixed column
% header.
this.Handles.StateConstrTableFixedCheckBox = this.Handles.OpCondSpecPanel.getStateFixedColumnCheckBox;
h = handle(this.Handles.StateConstrTableFixedCheckBox, 'callbackproperties');
h.ActionPerformedCallback = {@LocalUpdateSetStateConstrTableFixedCheckBox this};

% Set the action callback for the output constraint table steady state
% column header.
this.Handles.StateConstrTableSteadyStateCheckBox = this.Handles.OpCondSpecPanel.getStateSteadyStateColumnCheckBox;
h = handle(this.Handles.StateConstrTableSteadyStateCheckBox, 'callbackproperties');
h.ActionPerformedCallback = {@LocalUpdateSetStateConstrTableSteadyStateCheckBox this};

% Refresh the table
% Get the table data for the input constraint table data
[state_table,state_ind] = this.getStateConstrTableData;
if isempty(this.StateSpecTableData)
    % Store the initial table data
    this.StateSpecTableData = state_table;
end
% Store the state indices
this.StateIndices = state_ind;
refreshStateConstrTable(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalTableClick - Callback for when a user clicks on a table
function LocalTableClick(es,ed,this)

if ed.getClickCount == 2
    % es is the table
    row = es.getSelectedRow;
    % Determine if a block was selected
    ind = find(this.StateIndices == row);

    if ~isempty(ind) && (numel(this.OpSpecData.States) > 0)
        state = this.OpSpecData.States(ind);
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
% LocalUpdateSetStateConstrTableData - Callback for updating the information
% from the state constraint table
function LocalUpdateSetStateConstrTableData(es,ed,this)

% Get the row and column indices
row = ed.getFirstRow;
col = ed.getColumn;

% Call the linearize model method only if the row > 0
if (row > 0)
    StateIndices = this.StateIndices;

    this.setStateConstrTableData(this.Handles.StateConstrTableModel.data,StateIndices,row,col);
    % Uncheck the Fixed column if one of the rows in the fixed column has
    % been checked.  Do the same for the steady state column.
    if (col == 2 && row ~= 0)
        this.Handles.OpCondSpecPanel.setStateFixedColumnCheckBoxSelected(false)
    elseif (col == 3 && row ~= 0)
        this.Handles.OpCondSpecPanel.setStateSteadyStateColumnCheckBoxSelected(false)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetStateConstrTableFixedCheckBox - Callback for updating the information
% from the state constraint table fixed column checkbox
function LocalUpdateSetStateConstrTableFixedCheckBox(es,ed,this)

% Get the value of the checkbox
if (this.Handles.StateConstrTableFixedCheckBox.isSelected)
    val = true;
else
    val = false;
end

% Update the Java table model and constraint data.  This is the 3rd column.
for ct = 1:size(this.StateSpecTableData,1)
    this.StateSpecTableData{ct,3} = val;
end
refreshStateConstrTable(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetStateConstrTableSteadyStateCheckBox - Callback for updating the information
% from the state constraint table fixed column checkbox
function LocalUpdateSetStateConstrTableSteadyStateCheckBox(es,ed,this)

% Get the value of the checkbox
if (this.Handles.StateConstrTableSteadyStateCheckBox.isSelected)
    val = true;
else
    val = false;
end

% Update the Java table model and constraint data.  This is the 4rd column.
for ct = 1:size(this.StateSpecTableData,1)
    this.StateSpecTableData{ct,4} = val;
end
refreshStateConstrTable(this);
