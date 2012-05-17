function refreshStateConstrTable(this)
% REFRESHSTATECONSTRTABLE  Refresh the state constraint table.
%
 
% Author(s): John W. Glass 19-Jun-2006
%   Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.12.4 $ $Date: 2009/11/09 16:35:58 $

% Create the cell attributes
cellAtt = CreateCellAttrib(this.StateIndices, size(this.StateSpecTableData,1), 6);
StateConstrTableModel = this.Handles.OpCondSpecPanel.getStateConstrTableModel;
StateConstrTableModel.setDataAndUpdate(matlab2java(slcontrol.Utilities,this.StateSpecTableData), cellAtt);