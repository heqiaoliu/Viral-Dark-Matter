function olddata = preserialize(this)
%PRESERIALIZE Prepare a bar plot for serialization.
  
%   Copyright 2007 The MathWorks, Inc.

% Store the bar peers as appdata:

hPeers = this.BarPeers;
hPeers = hPeers(ishandle(hPeers));
peerVals = plotedit({'getProxyValueFromHandle',hPeers});
setappdata(double(this),'SerializedBarPeers',peerVals);

olddata = [];