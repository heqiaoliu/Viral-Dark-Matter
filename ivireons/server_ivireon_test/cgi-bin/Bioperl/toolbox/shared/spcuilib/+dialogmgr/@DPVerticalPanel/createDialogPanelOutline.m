function createDialogPanelOutline(dp)
% Create drag-able outline of the InfoPanel
% Leave it invisible

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:37 $

hParent = dp.hParent;
lineThick = dp.PanelOutlineLineThickness;

% Use four frame-style uicontrols
hTop    = createOneLine(hParent,'horiz',lineThick);
hLeft   = createOneLine(hParent,'vert',lineThick);
hBottom = createOneLine(hParent,'horiz',lineThick);
hRight  = createOneLine(hParent,'vert',lineThick);

dp.hPanelOutline = [hTop hLeft hBottom hRight];

function h = createOneLine(hParent,side,lineThick)
% Create one black line
% Parent the lines to the hParent object
% We need to move across the entire area, not just the info panel

% Establish width/heights, but leave dummy positions for x,y,length
% The x,y,length settings get filled in by moveDialogPanelOutline()
%
switch side
    case 'vert'
        pos = [1 1 lineThick 1];
    case 'horiz'
        pos = [1 1 1 lineThick];
end
h = uicontrol('parent',hParent, ...
    'fore','k', ...
    'backgr','k', ...
    'style','frame', ...
    'units','pix', ...
    'pos',pos, ...
    'vis','off');

