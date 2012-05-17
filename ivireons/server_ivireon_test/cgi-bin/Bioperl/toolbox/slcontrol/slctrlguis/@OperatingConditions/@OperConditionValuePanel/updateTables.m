function updateTables(this)

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2008/03/13 17:40:24 $

%%%%%% STATE TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the cell attributes
cellAtt = CreateCellAttrib(this.StateIndices, size(this.StateTableData,1), 2);
this.Handles.StateCondTableModel.cellAtt = cellAtt;
this.Handles.StateCondTableModel.data = this.StateTableData;

% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.Handles.StateCondTableModel);
javaMethodEDT('fireTableChanged',this.Handles.StateCondTableModel,evt);

%%%%%% INPUT TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create the cell attributes
cellAtt = CreateCellAttrib(this.InputIndices, size(this.InputTableData,1), 2);
this.Handles.InputCondTableModel.cellAtt = cellAtt;
this.Handles.InputCondTableModel.data = this.InputTableData;

% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.Handles.InputCondTableModel);
javaMethodEDT('fireTableChanged',this.Handles.InputCondTableModel,evt);
