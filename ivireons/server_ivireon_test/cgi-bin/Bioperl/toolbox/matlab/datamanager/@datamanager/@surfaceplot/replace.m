function replace(this,newValue)

h = this.HGHandle;
zdata = get(h,'ZData');
zdata(h.BrushData>0) = newValue;
set(h,'ZData',zdata);
