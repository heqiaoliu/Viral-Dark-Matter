function UpdateTableDisplay(h) 
% UPDATETABLEDISPLAY is called when start/end time edit boxes are updated

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
if ~isempty(h.Handles.ActiveX)
    % change highlights in the activex control when editboxes are changed
    if ~isempty(h.Handles.ActiveX.eventlisteners)
        h.Handles.ActiveX.unregisterallevents;
    end
    if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
        tmpStr=strcat(h.findcolumnletter(h.IOData.SelectedColumns(1)),num2str(h.IOData.SelectedRows(1)),':',...
            h.findcolumnletter(h.IOData.SelectedColumns(end)),num2str(h.IOData.SelectedRows(end)));
        h.Handles.ActiveX.ActiveSheet.Range(tmpStr).Select;
    end
    h.Handles.ActiveX.registerevent({'SelectionChange' @(a,b,c,d) tsExcelActiveXCellActivate(h,a,b,c,d); ...
        'EndEdit' @(a,b,c,d,e,f,g,j) tsExcelActiveXCellEdit(h,a,b,c,d,e,f,g,j); ...
        'SheetActivate' @(a,b,c,d,e) tsExcelActiveXSheetActivate(h,a,b,c,d,e)});
end
if ~isempty(h.Handles.tsTable)
    if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
        % change highlights
        awtinvoke(h.Handles.tsTable.getTable,'addRowSelectionInterval',h.IOData.SelectedRows(1)-1,h.IOData.SelectedRows(end)-1);
        awtinvoke(h.Handles.tsTable.getTable,'addColumnSelectionInterval',h.IOData.SelectedColumns(1)-1,h.IOData.SelectedColumns(end)-1);
        % change highlights in the uitable when editboxes are changed
        awtinvoke(h.Handles.tsTable.getTable,'scrollRectToVisible',h.Handles.tsTable.getTable.getCellRect(h.IOData.SelectedRows(end)-1,h.IOData.SelectedColumns(end)-1,true));
        h.Handles.tsTable.getTable.repaint;
    end
end

