function postdeserialize(this)
%POSTDESERIALIZE Post deserialize bar plot
  
%   Copyright 1984-2007 The MathWorks, Inc.

ch = get(this,'Children');

% delete extra children from serialization
delete(ch(2:end))

% find existing baseline, if any
parent = get(this,'Parent');
children = allchild(parent);
baseline = [];
for k=1:length(children)
  if isa(handle(children(k)),'specgraph.baseline')
    baseline = [baseline handle(children(k))];
  end
end

delete(baseline(2:end));

setLegendInfo(this);

hFig = ancestor(this,'Figure');

% If we are pasting into a new axes, make the peer this series to any
% existing series. If not, make sure that its peers are aware of its new
% handle:
if isappdata(hFig, 'BusyPasting')
      peers = find(handle(parent),'-class','specgraph.barseries');
      set(peers,'BarPeers',unique(peers));
else
    % Update the peers, attempting to preserve order as much as possible
    if isappdata(double(this), 'SerializedBarPeers')
        peerVals = getappdata(double(this),'SerializedBarPeers');
        tempPeers = plotedit({'getHandleFromProxyValue',hFig,peerVals});
        thisVal = plotedit({'getProxyValueFromHandle',this});
        tempPeers(peerVals == thisVal) = this;
        this.BarPeers = unique(tempPeers(ishandle(tempPeers)));
    end
    hPeers = this.BarPeers;
    hPeers = hPeers(ishandle(hPeers));
    set(hPeers,'BarPeers',hPeers);
end

if isappdata(double(this),'SerializedBarPeers')
    rmappdata(double(this), 'SerializedBarPeers');
end

set(this.BarPeers,'BaseLine',double(baseline(1)));

% Update the newly acquired siblings:
hSrc.name = 'BarLayout';
eventData.affectedObject = this;
this.SiblingUpdateFcn(hSrc,eventData);
hSrc.name = 'BarWidth';
this.SiblingUpdateFcn(hSrc,eventData);

% Refresh the object
update(handle(this));
set(this,'dirty','invalid');