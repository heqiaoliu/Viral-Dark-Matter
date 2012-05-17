function remove(this,keepflag)

% Find brushed points for this object
h = this.HGHandle;
if ~isempty(h.BrushData)
    I = (h.BrushData(1,:)>0);
    for j=2:size(h.BrushData,1)
        I = I | (h.BrushData(j,:)>0);
    end
end  
if isempty(I)
    return
end

% Invert if keep
if keepflag
    I = ~I;
end

% Remove brushed data from arrays
xdata = get(h,'XData');
ydata = get(h,'YData');
xdata(I) = [];
ydata(I) = [];
if ~isempty(h.findprop('ZData')) && ~isempty(h.ZData)
    zdata = get(h,'ZData');
    zdata(I) = [];
else
    zdata = [];
end

% Apply modified data to graphic objects
manMode = true;
try 
    manMode = strcmp(get(h,'XDataMode'),'manual');
end
if manMode
    if isempty(zdata)
        set(h,'XData',xdata,'YData',ydata);
    else
        set(h,'XData',xdata,'YData',ydata,'ZData',zdata);
    end
else
    if isempty(zdata)
        set(h,'YData',ydata);
    else
        set(h,'YData',ydata,'ZData',zdata);
    end
end
