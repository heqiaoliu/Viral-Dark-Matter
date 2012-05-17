function rowLength = getDataSize(h,dim)

% Copyright 2006 The MathWorks, Inc.

%% Get the number of columns for the current sheet
if ~isempty(h.Handles.ActiveX)
    rowLength = h.IOData.currentSheetSize(h.Handles.ActiveX.ActiveSheet.Index,dim);
else
    strCell = get(h.Handles.COMBdataSheet,'String');
    tmpSheet = genvarname(strCell{get(h.Handles.COMBdataSheet,'Value')});
    rowLength = size(h.IOData.rawdata.(tmpSheet),dim);
end