function olddata = preserialize(this)
%PRESERIALIZE Prepare object for serialization

%   Copyright 1984-2007 The MathWorks, Inc.

olddata = [];

% remove data containing function handles that won't load
delete(get(this,'UIContextMenu'));
set(this,'ButtonDownFcn','');
set(this.ItemText,'ButtonDownFcn','');
setappdata(double(this),'PlotChildren',double(this.PlotChildren));
setappdata(double(this),'PeerAxes',double(this.Axes));
% For undo/redo support, also store the proxies:
objects = [this.Axes; this.PlotChildren];
objects = objects(ishandle(objects));
if ~isempty(objects)
    proxyVals = plotedit({'getProxyValueFromHandle',objects});
    setappdata(double(this),'PlotChildrenProxy',proxyVals(2:end));
    setappdata(double(this),'PeerAxesProxy',proxyVals(1));
end
