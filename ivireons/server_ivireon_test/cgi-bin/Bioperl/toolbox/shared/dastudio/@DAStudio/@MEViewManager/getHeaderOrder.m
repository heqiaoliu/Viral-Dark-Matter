function acceptedColumns = getHeaderOrder(h, proposedColumns)

if ishandle(h.ActiveView)
    acceptedColumns = h.ActiveView.getHeaderOrder(proposedColumns);
else
    acceptedColumns = proposedColumns;
end