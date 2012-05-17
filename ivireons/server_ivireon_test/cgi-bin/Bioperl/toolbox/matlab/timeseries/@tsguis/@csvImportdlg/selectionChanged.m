function selectionChanged(h,selectedRows,selectedCols)

% Copyright 2005-2008 The MathWorks, Inc.

% Table selection callback method
 
% Get starting row and column number
if isempty(h.Handles.tsTable)
    return
end

if length(selectedRows)<1 || length(selectedCols)<1
    return
end
selrow  = selectedRows(1)+1;
selcolumn = selectedCols(1)+1;
selsize(1) = length(selectedRows);
selsize(2) = length(selectedCols);


% Deal with the first column/row for smart selection
ignored=0;
if get(h.Handles.COMBdataSample,'Value')==1
    % Time vector is stored as a column
    if selrow==1
        % first row is selected
        ignored = h.IgnoreFirstColumnRow;
        if ~isempty(ignored) && ignored>0
            selrow = ignored+1;
            selsize(1) = selsize(1)-ignored;
        end
    end
else
    % Time vector is stored as a row
    if selcolumn==1
        % first row is selected
        ignored = h.IgnoreFirstColumnRow;
        if ~isempty(ignored) && ignored>0
            selcolumn = ignored+1;
            selsize(2) = selsize(2)-ignored;
        end
    end
end

% Update selected block parameters
ioData = h.IOData;
selectedCols = ioData.SelectedColumns;
selectedRows = ioData.SelectedRows;
if length(selectedCols)>=2 && length(selectedRows)>=2 && ...
        selectedCols(1)==selcolumn && ...
        selectedCols(end)==selcolumn+selsize(2)-1 && ...
        selectedRows(1) == selrow && ...
        selectedRows(end) == selrow+selsize(1)-1     
      return
end
ioData.SelectedColumns = selcolumn:selcolumn+selsize(2)-1;
ioData.SelectedRows = selrow:selrow+selsize(1)-1;
h.IOData = ioData;
% Update displays in the editboxes
set(h.Handles.EDTFROM,'String',[h.findcolumnletter(selcolumn) num2str(selrow)]);
set(h.Handles.EDTTO,'String',[h.findcolumnletter(selcolumn+selsize(2)-1) num2str(selrow+selsize(1)-1)]);

% Check if a valid time vector exists (first and last elements)
if get(h.Handles.COMBdataSample,'Value')==1
    % Time vector is stored as a column
    h.updateStartEndTime(selrow,selrow+selsize(1)-1);
else
    % Time vector is stored as a row
    h.updateStartEndTime(selcolumn,selcolumn+selsize(2)-1);
end

updateTableDisp(h)
if ignored==h.IOData.checkLimit
    msgbox(sprintf('The first %d time values are invalid.',...
        h.IOData.checkLimit),'Time Series Tools');
end
