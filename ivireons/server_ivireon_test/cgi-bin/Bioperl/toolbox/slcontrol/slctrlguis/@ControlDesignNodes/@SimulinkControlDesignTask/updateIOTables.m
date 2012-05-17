function updateIOTables(this)
% UPDATEIOTABLES  Update the IO Tables
%
 
% Author(s): John W. Glass 06-Sep-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:31:13 $

%% Get the table data for the linearization ios
[input_table_data,output_table_data] = this.getIOTableData;

this.Handles.MATLABInputIOTableModel(2).Enabled = 'off';
InputIOTableModel = this.Handles.InputIOTableModel;
if ~isempty(input_table_data)
    InputIOTableModel.setData(input_table_data);
else
    InputIOTableModel.clearRows;
end
drawnow
this.Handles.MATLABInputIOTableModel(2).Enabled = 'on';

%% Create a table model event to update the table
this.Handles.MATLABOutputIOTableModel(2).Enabled = 'off';
OutputIOTableModel = this.Handles.OutputIOTableModel;
if ~isempty(output_table_data)
    OutputIOTableModel.setData(output_table_data);
else
    OutputIOTableModel.clearRows;
end
drawnow
this.Handles.MATLABOutputIOTableModel(2).Enabled = 'on';
