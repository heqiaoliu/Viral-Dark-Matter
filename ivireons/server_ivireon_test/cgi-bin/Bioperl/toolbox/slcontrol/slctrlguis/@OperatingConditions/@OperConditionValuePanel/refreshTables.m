function refreshTables(this)
% REFRESHTABLES  Refresh the table data given using the operating point
% in the node.
 
% Author(s): John W. Glass 25-Jun-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:30 $

cellAtt = CreateCellAttrib(this.StateIndices, size(this.StateTableData,1), 2);
this.Handles.StateCondTableModel.setDataAndUpdate(matlab2java(slcontrol.Utilities,this.StateTableData), cellAtt);

cellAtt = CreateCellAttrib(this.InputIndices, size(this.InputTableData,1), 2);
this.Handles.InputCondTableModel.setDataAndUpdate(matlab2java(slcontrol.Utilities,this.InputTableData), cellAtt);