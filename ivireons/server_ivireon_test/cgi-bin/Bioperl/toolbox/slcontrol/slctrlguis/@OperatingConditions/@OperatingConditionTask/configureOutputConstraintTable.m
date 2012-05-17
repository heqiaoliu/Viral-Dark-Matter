function configureOutputConstraintTable(this)
%  configureOutputConstraintTable  Construct the output constraint table panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.15 $ $Date: 2009/03/23 16:44:25 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Constraint Table
% Set the action callback for the output constraint table model and store its
% handle
OutputConstrTableModel = this.Handles.OpCondSpecPanel.getOutputConstrTableModel;
this.Handles.OutputConstrTableModel = OutputConstrTableModel;
h = handle(this.Handles.OutputConstrTableModel, 'callbackproperties');
h.TableChangedCallback = {@LocalUpdateSetOutputConstrTableData this};

% Set the callback for when the user double clicks to inspect a block
h = handle(this.Handles.OpCondSpecPanel.getOutputConstrTable, 'callbackproperties');
h.MouseClickedCallback = {@LocalTableClick this};

% Refresh the table data
% Get the table data for the input constraint table data
[output_table,output_ind] = this.getOutputConstrTableData;
if isempty(this.OutputSpecTableData)
    % Store the initial table data
    this.OutputSpecTableData = output_table;
end
% Store the output indices
this.OutputIndices = output_ind;
refreshOutputConstrTable(this);

% Set the action callback for the output constraint table fixed column
% header.
this.Handles.OutputConstrTableFixedCheckBox = this.Handles.OpCondSpecPanel.getOutputFixedColumnCheckBox;
h = handle(this.Handles.OutputConstrTableFixedCheckBox, 'callbackproperties');
h.ActionPerformedCallback = {@LocalUpdateSetOutputConstrTableFixedCheckBox this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalTableClick - Callback for when a user clicks on a table
function LocalTableClick(es,ed,this)

if ed.getClickCount == 2
    % es is the table
    row = es.getSelectedRow;
    % Determine if a block was selected
    ind = find(this.OutputIndices == row);
    
    if ~isempty(ind) && (numel(this.OpSpecData.Outputs) > 0)
        block = this.OutputSpecTableData{this.OutputIndices(ind)+1,1};
        try
            dynamicHiliteSystem(slcontrol.Utilities,block)
        catch Ex %#ok<NASGU>
            str = sprintf('The block %s is no longer in the model',block);
            errordlg(str,'Simulink Control Design')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetOutputConstrTableData - Callback for updating the information
% from the output constraint table
function LocalUpdateSetOutputConstrTableData(es,ed,this)

% Get the row and column indices
row = ed.getFirstRow;
col = ed.getColumn;

% Call the linearize model method only if the row > 0
if (row > 0)
    OutputIndices = this.OutputIndices;

    this.setOutputConstrTableData(this.Handles.OutputConstrTableModel.data,OutputIndices,row,col);
    % Uncheck the Fixed column if one of the rows in the fixed column has
    % been checked.
    if (col == 2 && row ~= 0)
        this.Handles.OpCondSpecPanel.setOutputFixedColumnCheckBoxSelected(false)
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetOutputConstrTableFixedCheckBox - Callback for updating the information
% from the output constraint table fixed column checkbox
function LocalUpdateSetOutputConstrTableFixedCheckBox(es,ed,this)

% Get the value of the checkbox
if (this.Handles.OutputConstrTableFixedCheckBox.isSelected)
    val = true;
else
    val = false;
end

% Update the Java table model and constraint data.  This is the 3rd column.
for ct = 1:size(this.OutputSpecTableData,1)
    this.OutputSpecTableData{ct,3} = val;
end
refreshOutputConstrTable(this);