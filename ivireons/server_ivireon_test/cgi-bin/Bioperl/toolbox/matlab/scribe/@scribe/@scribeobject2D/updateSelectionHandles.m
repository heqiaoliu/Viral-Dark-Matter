function updateSelectionHandles(hThis)
% Given a figure, update the position of its selection handles based on its
% position.

%   Copyright 2006 The MathWorks, Inc.

% In 2-D, the selection handles are at the edges of the bounding box. The
% first eight selection handles (subclasses may add more) define the
% bounds of the object.

% Don't perform the update unless necessary
if ~isempty(hThis.Srect) && all(ishandle(hThis.Srect)) && ~hThis.UpdateInProgress
    hRect = hThis.Srect;
    hFig = ancestor(hThis,'Figure');
    % Convert to normalized units:
    normPos = hgconvertunits(hFig,hThis.Position,hThis.Units,'Normalized',hFig);
    % Given the position, compute the bounding box.
    lx = normPos(1); rx = normPos(1)+normPos(3); cx = normPos(1)+normPos(3)/2;
    px = [lx rx rx lx lx cx rx cx cx];
    uy = normPos(2); ly = normPos(2)+normPos(4); cy = normPos(2)+normPos(4)/2;
    py = [uy ly uy ly cy uy cy ly cy];
    for i=1:length(hRect)
        set(hRect(i),'XData',px(i),'YData',py(i));
    end
end