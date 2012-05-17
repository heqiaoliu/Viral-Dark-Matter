function moveDialogPanelOutline(dp,currPt)
% Move outline of info panel on screen
% currPt is the current mouse coordinate in parent reference frame

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:07 $

[~,iwidth,iheight] = getDialogPanelAndSize(dp);
lineThick = dp.PanelOutlineLineThickness;
curx = currPt(1);

% If panel in on the right, currPt represents a left-moving drag
% Mouse is the left-leading edge of panel
%
% By default, the left edge of the outline meets the cursor, and the box
% is drawn to the right of the cursor position.
topLine    = [curx iheight-lineThick+1 iwidth lineThick];
bottomLine = [curx 1 iwidth lineThick];
leftLine   = [curx 1 lineThick iheight];
rightLine  = [curx+iwidth-1-lineThick+1 1 lineThick iheight];

if strcmpi(dp.DockLocation,'left')
    % If panel in on the left, currPt represents a right-moving drag
    % Mouse is the right-leading edge of panel
    %
    % The right edge of the outline meets the cursor, and the box
    % is drawn to the left of the cursor position.
    topLine(1)    = topLine(1)    - iwidth;
    bottomLine(1) = bottomLine(1) - iwidth;
    leftLine(1)   = leftLine(1)   - iwidth;
    rightLine(1)  = rightLine(1)  - iwidth;
end
% h is a vector of frame uicontrols, each forms a line of the outline
% Elements of h are ordered: [top left bottom right]
h = dp.hPanelOutline;
set(h(1),'pos',topLine);
set(h(2),'pos',leftLine);
set(h(3),'pos',bottomLine);
set(h(4),'pos',rightLine);

