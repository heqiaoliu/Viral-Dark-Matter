function [xdata,ydata] = getExtent(h)

% Finds the graphical XData and YData for stacked barseries (which will
% differ from the xdata and ydata of the graphic objects themselves)

gObj = h.HGHandle;
patchArea = get(gObj,'Children');
if strcmpi(get(h.HGHandle,'BarLayout'),'grouped')
    if strcmp(get(h.HGHandle,'Horizontal'),'off')
        xdata = mean(get(patchArea,'XData'));
        ydata = get(gObj,'YData');
    else
        ydata = mean(get(patchArea,'YData'));
        xdata = get(gObj,'YData');
    end
else
    peers = get(gObj,'barPeers');
    peerPos = find(double(peers)==double(gObj));
    if strcmp(get(h.HGHandle,'Horizontal'),'off')
        xdata = mean(get(patchArea,'XData'));
        ydata = get(peers(1),'YData');
        for row=2:peerPos
            ydata = ydata+get(peers(row),'YData');
        end
    else
        ydata = mean(get(patchArea,'YData'));
        xdata = get(peers(1),'YData');
        for row=2:peerPos
            xdata = xdata+get(peers(row),'YData');
        end
    end
end