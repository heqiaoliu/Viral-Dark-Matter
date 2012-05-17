function refreshOutputConstrTable(this)
% REFRESHOUTPUTCONSTRTABLE  Refresh the output constraint table.
%
 
% Author(s): John W. Glass 19-Jun-2006
%   Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.12.4 $ $Date: 2009/11/09 16:35:57 $

% Create the cell attributes
cellAtt = CreateCellAttrib(this.OutputIndices, size(this.OutputSpecTableData,1), 5);
OutputConstrTableModel = this.Handles.OpCondSpecPanel.getOutputConstrTableModel;
OutputConstrTableModel.setDataAndUpdate(matlab2java(slcontrol.Utilities,this.OutputSpecTableData), cellAtt);