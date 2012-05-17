function tmpCell = GetRow(h)
% GETROW returns a cell array with row numbers for active spreadsheet

% Author: Rong Chen 
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2006/12/20 07:18:48 $
 
% check platform
if  isfield(h.Handles,'ActiveX') && ~isempty(h.Handles.ActiveX)
    % activex is used
    rowLength=h.IOData.currentSheetSize(h.Handles.ActiveX.ActiveSheet.Index,1);
else
    % uitable is used
    strCell=get(h.Handles.COMBdataSheet,'String');
    tmpSheet=genvarname(strCell{get(h.Handles.COMBdataSheet,'Value')});
    rowLength=size(h.IOData.rawdata.(tmpSheet),1);
end
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


