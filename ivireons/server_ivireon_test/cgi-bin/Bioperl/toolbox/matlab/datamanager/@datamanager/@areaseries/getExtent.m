function [xdata,ydata,ydata_last] = getExtent(h)

% Finds the graphical XData and YData for stacked areaseries (which will
% differ from the xdata and ydata of the graphic objects themselves)

gObj = h.HGHandle;
peers = get(gObj,'areaPeers');
peerPos = find(double(peers)==double(gObj));
xdata = get(peers(1),'XData');
ydata = get(peers(1),'YData');
if peerPos==1
    ydata_last = get(gObj,'BaseValue')*ones(size(ydata));
    return
end
for row=2:peerPos-1
    ydata = ydata+get(peers(row),'YData');
end
ydata_last = ydata;
ydata = ydata+get(peers(peerPos),'YData');