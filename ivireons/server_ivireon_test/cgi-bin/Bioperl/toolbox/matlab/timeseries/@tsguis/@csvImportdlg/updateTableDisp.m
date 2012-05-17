function updateTableDisplay(h) 

% Copyright 2005 The MathWorks, Inc.

if ~isempty(h.IOData.SelectedColumns) && ~isempty(h.IOData.SelectedRows)
    % change highlights
    awtinvoke(h.Handles.tsTable,'addRowSelectionInterval',h.IOData.SelectedRows(1)-1,h.IOData.SelectedRows(end)-1);
    awtinvoke(h.Handles.tsTable,'addColumnSelectionInterval',h.IOData.SelectedColumns(1)-1,h.IOData.SelectedColumns(end)-1);
    % change highlights in the uitable when editboxes are changed
    awtinvoke(h.Handles.tsTable,'scrollRectToVisible',h.Handles.tsTable.getCellRect(h.IOData.SelectedRows(end)-1,h.IOData.SelectedColumns(end)-1,true));
    h.Handles.tsTable.repaint;
end