function refresh_para_table(Editor)
%REFRESHTABLE  Refreshes the table of selected tab (index idxC) based on
%the current block parameter values

%   Author(s): C. Buhr
%   Revised by R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2006/06/20 20:03:07 $

% get handles
TableModel = Editor.Handles.ParaTabHandles.TableModel;

% if it is not a pure gain block
if Editor.idxC<=length(Editor.CompList)
    % generate new table data
    table_data = Editor.getTableData;
% if it is a pure gain block list
else
    % generate new table data
    table_data = Editor.getTableDataGainList;
end

% SimpleTableModel\setdata does not issue a fireTableDataChanged event
TableModel.setData(table_data, 0, java.lang.Integer.MAX_VALUE);
