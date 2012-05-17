function [columns icons] = getHeaderLabels(h)

if ishandle(h.ActiveView)
    [columns icons] = h.ActiveView.getHeaderLabels();
else
    columns = {'Name'};
    icons   = {''};
end