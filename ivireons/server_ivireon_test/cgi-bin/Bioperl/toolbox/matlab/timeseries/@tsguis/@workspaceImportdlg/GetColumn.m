function tmpCell = GetColumn(h)
% GETCOLUMN returns a cell array with column letters for active spreadsheet

% Author: Rong Chen 
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:12:36 $

% check platform
if ~isempty(h.IOData.SelectedVariableInfo)
    columnLength = h.IOData.SelectedVariableInfo.objsize(2);
    % reset the h.IOData.checkLimitColumn
    h.IOData.checkLimitColumn=20;
    % if too many columns available, return column letters plus 'More'
    if (columnLength>h.IOData.checkLimitColumn)
        tmpCell=num2cell(1:h.IOData.checkLimitColumn);
        tmpCell(h.IOData.checkLimitColumn+1)={xlate('More ...')};
    else
        tmpCell=num2cell(1:columnLength);
    end
else
    tmpCell={' '};
end

