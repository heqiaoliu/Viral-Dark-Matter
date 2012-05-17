function outval = newvar(this)

gobj = this.HGHandle;
xdata = get(gobj,'XData');
ydata = get(gobj,'YData');
I = (get(gobj,'BrushData')>0);
outval = [xdata(I)' ydata(I)'];
%assignin('base',varname,[xdata(I)' ydata(I)']);




       


