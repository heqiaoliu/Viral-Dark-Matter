function updateSelectionHandles(hThis)
% Given a figure, update the position of its selection handles based on its
% position.

%   Copyright 2006 The MathWorks, Inc.

% In 1-D, the selection handles are at the endpoints of the lines. The
% first two selection handles (subclasses may add more) define the
% end-points of the object.

% Don't perform the update unless necessary
if ~isempty(hThis.Srect) && all(ishandle(hThis.Srect)) && ~hThis.UpdateInProgress
    hRect = hThis.Srect;
    hFig = ancestor(hThis,'Figure');
    % Convert to normalized units:
    normPos = hgconvertunits(hFig,hThis.Position,hThis.Units,'Normalized',hFig);
    % Extract the first X,Y position. These are simply the first two
    % coordinates of the position rectange:
    set(hRect(1),'XData',normPos(1),'YData',normPos(2));
    % The second X,Y position is the sum of the position and the height and
    % width, which may be negative.
    set(hRect(2),'XData',normPos(1)+normPos(3),'YData',normPos(2)+normPos(4));
end