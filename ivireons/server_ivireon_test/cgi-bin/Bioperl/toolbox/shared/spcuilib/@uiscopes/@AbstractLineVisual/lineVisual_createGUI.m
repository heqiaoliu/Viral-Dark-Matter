function plan = lineVisual_createGUI(this)
%LINEVISUAL_CREATEGUI Create the Line specific GUI components.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/10/29 16:09:36 $

hGridMenu = uimgr.uimenu('Grid', 1, '&Grid');
hGridMenu.WidgetProperties = { ...
    'Checked', uiservices.logicalToOnOff(getPropValue(this, 'Grid')), ...
    'Callback', @(hcbo, ev) toggleProp(this, 'Grid')};

hLegendMenu = uimgr.uimenu('Legend', 1, '&Legend');
hLegendMenu.WidgetProperties = { ...
    'Checked', uiservices.logicalToOnOff(getPropValue(this, 'Legend')), ...
    'Callback', @(hcbo, ev) toggleProp(this, 'Legend')};

% hCompactMenu = uimgr.uimenu('Compact', 1, '&Compact Display');
% hCompactMenu.WidgetProperties = { ...
%     'Checked', uiservices.logicalToOnOff(getPropValue(this, 'Compact')), ...
%     'Callback', @(hcbo, ev) toggleProp(this, 'Compact')};

hLineProps = uimgr.uimenugroup('LineProperties', 50, 'Line &Properties');

hVisualMenu = uimgr.uimenugroup('LineVisual', -Inf, ...
    hGridMenu, hLegendMenu, hLineProps); % hCompactMenu

plan = {hVisualMenu 'Base/Menus/View'};

% -------------------------------------------------------------------------
function toggleProp(this, prop)

hProp = findProp(this, prop);
hProp.Value = ~hProp.Value;

% [EOF]
