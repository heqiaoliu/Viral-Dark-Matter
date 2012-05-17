function selectedData = getArraySelection(this)

% Extract a horizontal concatenation of the selected graphic object data
% from a dead plot

selectedData = [];
I = [];
h = handle(this.HGHandle);


I = h.BrushData>0;
if ~isempty(I)
    zdata = get(h,'ZData');
    ydata = get(h,'YData');
    xdata = get(h,'XData');
    if isvector(xdata)
        xdata = xdata(:)';
        xdata = repmat(xdata,[size(zdata,1) 1]);
    end
    if isvector(ydata)
        ydata = ydata(:);
        ydata = repmat(ydata,[1 size(zdata,2)]);
    end
    
    Icols = any(I,1);
    Irows = any(I,2);
    xdata = xdata(Irows(:),Icols(:));
    ydata = ydata(Irows(:),Icols(:));
    zdata = zdata(Irows(:),Icols(:));

    selectedData = [xdata;ydata;zdata];
end
