function updateDataCursor(this,hDataCursor,target)

% Copyright 2003-2006 The MathWorks, Inc.

ch = get(this,'children');
updateDataCursor(hDataCursor,handle(ch),hDataCursor,target);
pf = get(hDataCursor,'InterpolationFactor');
ind = get(hDataCursor,'DataIndex');

% On a stair plot, only odd data vertices represent actual data.
% Therefore, if the user selected an even data point then snap 
% the cursor position up or down.
if isequal(mod(ind,2),0)
    if pf > .5
        ind = ind + 1;
    else
        ind = ind - 1;
    end
    xdata = get(ch,'xdata');
    ydata = get(ch,'ydata');
    if ind <= length(xdata) && ind > 0
        pos = [xdata(ind),ydata(ind)];
        set(hDataCursor,'Position',pos);
        set(hDataCursor,'TargetPoint',pos);
    end
end

set(hDataCursor,'Target',this);
set(hDataCursor,'DataIndex',floor(ind/2)+1);
