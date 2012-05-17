function refreshInputConstrTable(this)
% REFRESHINPUTCONSTRTABLE  Refresh the input constraint table.
%
 
% Author(s): John W. Glass 19-Jun-2006
%   Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.12.4 $ $Date: 2009/11/09 16:35:56 $

% Create the cell attributes
cellAtt = CreateCellAttrib(this.InputIndices, size(this.InputSpecTableData,1), 5);
InputConstrTableModel = this.Handles.OpCondSpecPanel.getInputConstrTableModel;
InputConstrTableModel.setDataAndUpdate(matlab2java(slcontrol.Utilities,this.InputSpecTableData), cellAtt);