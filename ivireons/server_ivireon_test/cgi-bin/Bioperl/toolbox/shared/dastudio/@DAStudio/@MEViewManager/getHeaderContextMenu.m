function menu = getHeaderContextMenu(h, header)

if ishandle(h.ActiveView)
    menu = h.ActiveView.getHeaderContextMenu(header);
else
    menu = [];
end