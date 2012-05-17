function configureInputConstraintTable(this)
%  configureInputConstraintTable  Construct the input constraint table panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.14 $ $Date: 2008/10/31 07:36:37 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input Constraint Table
% Set the action callback for the input constraint table model and store its
% handle
InputConstrTableModel = this.Handles.OpCondSpecPanel.getInputConstrTableModel;
this.Handles.InputConstrTableModel = InputConstrTableModel;
h = handle( InputConstrTableModel, 'callbackproperties' );
h.TableChangedCallback = {@LocalUpdateSetInputConstrTableData,this};

% Set the callback for when the user double clicks to inspect a block
h = handle(this.Handles.OpCondSpecPanel.getInputConstrTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalTableClick this};

% Set the action callback for the input constraint table fixed column
% header.
InputConstrTableFixedCheckBox = this.Handles.OpCondSpecPanel.getInputFixedColumnCheckBox;
this.Handles.InputConstrTableFixedCheckBox = InputConstrTableFixedCheckBox;
h = handle( InputConstrTableFixedCheckBox, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalUpdateSetInputConstrTableFixedCheckBox,this};

% Get the table data for the input constraint table data
[input_table,input_ind] = this.getInputConstrTableData;
if isempty(this.InputSpecTableData)
    % Store the initial table data
    this.InputSpecTableData = input_table;
end
% Store the input indices
this.InputIndices = input_ind;

% Refresh the table
refreshInputConstrTable(this);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalTableClick - Callback for when a user clicks on a table
function LocalTableClick(es,ed,this)

if ed.getClickCount == 2
    % es is the table
    row = es.getSelectedRow;
    % Determine if a block was selected
    ind = find(this.InputIndices == row);

    if ~isempty(ind) && (numel(this.OpSpecData.Inputs) > 0)
        block = this.InputSpecTableData{this.InputIndices(ind)+1,1};
        try
            dynamicHiliteSystem(slcontrol.Utilities,block)
        catch Ex %#ok<NASGU>
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetInputConstrTableData - Callback for updating the information
% from the input constraint table
function LocalUpdateSetInputConstrTableData(es,ed,this)

% Get the row and column indices
row = ed.getFirstRow;
col = ed.getColumn;

% Call the linearize model method only if the row > 0
if (row > 0)
    InputIndices = this.InputIndices;

    this.setInputConstrTableData(this.Handles.InputConstrTableModel.data,InputIndices,row,col);
    % Uncheck the Fixed column if one of the rows in the fixed column has been
    % checked.
    if (col == 2 && row ~= 0)
        this.Handles.OpCondSpecPanel.setInputFixedColumnCheckBoxSelected(false)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetInputConstrTableFixedCheckBox - Callback for updating the information
% from the input constraint table fixed column checkbox
function LocalUpdateSetInputConstrTableFixedCheckBox(es,ed,this)

% Get the value of the checkbox
if (this.Handles.InputConstrTableFixedCheckBox.isSelected)
    val = true;
else
    val = false;
end

% Update the Java table model and constraint data.  This is the 3rd column.
for ct = 1:size(this.InputSpecTableData,1)
    this.InputSpecTableData{ct,3} = val;
end
refreshInputConstrTable(this);