function replace(this,newValue)

h = this.HGHandle;
I = any(h.BrushData>0,1);
if ~isempty(h.findprop('ZData')) && ~isempty(h.ZData)
    zdata = get(h,'ZData');
    zdata(I) = newValue;
    set(h,'ZData',zdata);
else
    ydata = get(h,'YData');
    ydata(I) = newValue;
    set(h,'YData',ydata);
end