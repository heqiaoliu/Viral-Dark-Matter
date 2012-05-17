function tmpCell = GetColumn(h)
% GETCOLUMN returns a cell array with column letters for active spreadsheet

% Author: Rong Chen 
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2005/11/27 22:42:11 $

% check platform
if  ~isempty(h.Handles.ActiveX)
    % activex is used
    columnLength=h.IOData.currentSheetSize(h.Handles.ActiveX.ActiveSheet.Index,2);
else
    % uitable is used
    strCell=get(h.Handles.COMBdataSheet,'String');
    tmpSheet=genvarname(strCell{get(h.Handles.COMBdataSheet,'Value')});
    columnLength=size(h.IOData.rawdata.(tmpSheet),2);
end
% reset the h.IOData.checkLimitColumn
h.IOData.checkLimitColumn=20;
% if too many columns available, return column letters plus 'More'
if (columnLength>h.IOData.checkLimitColumn)
    tmpCell=cell(h.IOData.checkLimitColumn+1,1);
    for k=1:h.IOData.checkLimitColumn
        tmpCell(k)={h.findcolumnletter(k)};
    end
    tmpCell(h.IOData.checkLimitColumn+1)={xlate('More ...')};
else
    tmpCell=cell(columnLength,1);
    for k=1:columnLength
        tmpCell(k)={h.findcolumnletter(k)};
    end
end


