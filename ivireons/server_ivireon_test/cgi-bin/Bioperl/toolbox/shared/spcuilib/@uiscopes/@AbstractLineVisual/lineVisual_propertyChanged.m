function lineVisual_propertyChanged(this, eventData)
%LINEVISUAL_PROPERTYCHANGED React to the line specific property changes.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/01/25 22:47:30 $

if ~ischar(eventData)
    eventData = get(eventData.AffectedObject, 'Name');
end

switch lower(eventData)
    case 'grid'
        updateGrid(this);
    case {'legend', 'linenames'}
        updateLegend(this);
    case 'compact'
        updateAxesLocation(this);
    case {'minylim', 'maxylim'}
        if ishghandle(this.Axes)
            updateYAxisLimits(this);
            onResize(this);
        end
    case {'minxlim', 'maxxlim', 'autodisplaylimits'}
        if ishghandle(this.Axes)
            updateXAxisLimits(this);
            onResize(this);
        end
    case 'lineproperties'
        updateLineProperties(this);
    case 'ylabel'
        ylabel(this.Axes, getPropValue(this, 'YLabel'));
end

% -------------------------------------------------------------------------
function updateAxesLocation(this)

newValue = getPropValue(this, 'Compact');

% Update the context menu's checked value.
hMenu = findobj(this.AxesContextMenu, 'Tag', 'LineVisualCompactDisplay');
set(hMenu, 'Checked', uiservices.logicalToOnOff(newValue));

% Update the menuitem.
hGUI = getGUI(this.Application);
hMenu = findwidget(hGUI, 'Menus', 'View', 'LineVisual', 'Compact');
set(hMenu, 'Checked', uiservices.logicalToOnOff(newValue));

% Call the onResize function to redefine the compact display's tick labels.
onResize(this);

if newValue
    positionProp = 'Position';
else
    positionProp = 'OuterPosition';
end

set(this.Axes, 'Units', 'Normalized', positionProp, [0 0 1 1]);

% [EOF]
