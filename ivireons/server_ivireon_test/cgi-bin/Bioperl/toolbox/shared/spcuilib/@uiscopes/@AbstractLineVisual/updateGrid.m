function updateGrid(this)
%UPDATEGRID Update the grid for the visual.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/04/27 19:55:34 $

grid = uiservices.logicalToOnOff(getPropValue(this, 'Grid'));

hAxes = get(this, 'Axes');
if ishghandle(hAxes)

    set(hAxes, 'YGrid', grid, 'XGrid', grid);
end

hGUI = getGUI(this.Application);
hMenu = findwidget(hGUI, 'Menus', 'View', 'LineVisual', 'Grid');
set(hMenu, 'Checked', grid);

% [EOF]
