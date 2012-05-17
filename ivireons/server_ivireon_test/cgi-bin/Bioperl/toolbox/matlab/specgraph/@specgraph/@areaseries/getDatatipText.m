function str = getDatatipText(this,dataCursor)

% Copyright 2003-2006 The MathWorks, Inc.

ind = dataCursor.DataIndex;
pos = dataCursor.Position;
hPeers = this.AreaPeers;

% If there is only one peer, don't print the stacked information:
if length(hPeers) == 1
    str = {['X = ' num2str(pos(1))], ...
        ['Y = ' num2str(pos(2))]};
else
    str = {['X = ' num2str(pos(1))], ...
        ['Y = ' num2str(pos(2)) ' (Stacked)'], ...
        ['Y = ' num2str(this.ydata(ind)) ' (Segment)']};
end
