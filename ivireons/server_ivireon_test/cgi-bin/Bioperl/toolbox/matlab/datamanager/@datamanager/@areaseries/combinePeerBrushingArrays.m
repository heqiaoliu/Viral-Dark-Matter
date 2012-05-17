function combinePeerBrushingArrays(h)

% Brushing arrays for AreaSeries peers must be the same before thay can be
% used to remove points or the peers will go out of sync

I = h.HGHandle.BrushData;
peers = handle(get(h.HGHandle,'AreaPeers'));
for k=1:length(peers)
    if ~isempty(peers(k).findprop('BrushData')) && ~isempty(peers(k).BrushData)
       I = I | peers(k).BrushData;
    end
end
for k=1:length(peers)
    if ~isempty(peers(k).findprop('BrushData'))
       set(peers(k),'BrushData',I);
    end
end
