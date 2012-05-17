function outvar = newvar(this)

gobj = this.HGHandle;
xdata = get(gobj,'XData');
ydata = get(gobj,'YData');
zdata = get(gobj,'ZData');
I = (get(gobj,'BrushData')>0);
Icols = any(I,1);
Irows = any(I,2);
zdata = zdata(Irows(:),Icols(:));
xdata = xdata(Icols);
ydata = ydata(Irows);
selectedData = [0 xdata(:)';...
                ydata(:) zdata];
outvar = selectedData;
%assignin('base',varname,selectedData);




       


