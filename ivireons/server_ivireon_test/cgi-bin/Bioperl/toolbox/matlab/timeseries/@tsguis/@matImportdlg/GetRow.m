function tmpCell = GetRow(h)
% GETROW returns a cell array with row numbers for active spreadsheet

% Author: Rong Chen 
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:10:36 $
 
% check platform
if ~isempty(h.IOData.SelectedVariableInfo)
    rowLength=h.IOData.SelectedVariableInfo.objsize(1);
    % reset the h.IOData.checkLimitColumn
    h.IOData.checkLimitRow=20;
    % if too many rows available, return row numbers plus 'More'
    if (rowLength>h.IOData.checkLimitRow)
        % too many rows, put 'More ...' option at the end of the list
        tmpCell=num2cell(1:h.IOData.checkLimitRow);
        tmpCell(h.IOData.checkLimitRow+1)={xlate('More ...')};
    else
        tmpCell=num2cell(1:rowLength);
    end
else
    tmpCell={' '};
end


