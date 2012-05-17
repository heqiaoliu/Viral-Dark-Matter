function updateIOTables(this); 
% UPDATEIOTABLES  Update the IO table(s) and fire an update event.
%
 
% Author(s): John W. Glass 06-Sep-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:31:16 $

%% Set the table data for the linearization ios
table_data = this.getIOTableData;
                    
AnalysisIOTableModel = this.Handles.AnalysisIOTableModel;
if ~isempty(table_data)
    AnalysisIOTableModel.setData(table_data);
else
    AnalysisIOTableModel.clearRows;
end
