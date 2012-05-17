function selectedData = getArraySelection(this)

% Extract a horizontal concatenation of the selected graphic object data
% from a dead plot

selectedData = [];
I = [];
h = handle(this.HGHandle);
ydata = get(h,'YData');
xdata = get(h,'XData');
if ~isempty(h.findprop('ZData'))
    zdata = get(h,'ZData');
    zdata = zdata(:);
else
    zdata = [];
end
ydata = ydata(:);
xdata = xdata(:);

I = any(this.HGHandle.BrushData>0,1);
if ~isempty(I)
    if isempty(zdata)
        selectedData = [xdata(I),ydata(I)];
    else
        selectedData = [xdata(I),ydata(I),zdata(I)];
    end
end

