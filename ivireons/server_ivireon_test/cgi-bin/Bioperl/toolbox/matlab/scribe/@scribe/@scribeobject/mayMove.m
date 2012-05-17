function res = mayMove(hThis,delta)
% Determines whether a scribe object may move or if this will move the
% object to an unrecoverable position. An unrecoverable position is defined
% to be when no selection handles are visible in the figure.

% Copyright 2006 The MathWorks Inc.

% Add a 4-pixel buffer to delta:
delta(1) = delta(1)+4*sign(delta(1));
delta(2) = delta(2)+4*sign(delta(2));

% Convert delta from pixels to normalized units:
hFig = ancestor(hThis,'figure');
delta = hgconvertunits(hFig,[delta 0 0],'pixels','normalized',hFig);
delta = delta(1:2);

% Get the XData and YData from the selection handles:
selRects = hThis.Srect;
selData = cell2mat([get(selRects,'XData') get(selRects,'YData')]);

% Add the delta to the data of each selection handle:
delta = repmat(delta,length(selRects),1);
selData = selData+delta;

% If all of the X or Y data is less than 0 or more than 1, this places it the
% object outside the bounds of the figure
clippedData = [~(selData(:,1) < 0), ~(selData(:,1) > 1), ...
    ~(selData(:,2) < 0), ~(selData(:,2) > 1)];
% If a selection rectange is within the figure, all entries should be "1".
% Otherwise, they will contain a "0" entry. If all rows have a "0" entry,
% none of the selection handles are visible.
res = any(min(clippedData,[],2));