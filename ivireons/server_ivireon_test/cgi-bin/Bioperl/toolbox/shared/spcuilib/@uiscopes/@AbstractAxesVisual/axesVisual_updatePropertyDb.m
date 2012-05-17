function axesVisual_updatePropertyDb(this)
%AXESVISUAL_UPDATEPROPERTYDB 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:43:31 $

% Define the list of properties we want to save.
axesPropNames = {'Color' ...
    'XColor' 'YColor' 'ZColor' ...
    'XGrid' 'YGrid' 'ZGrid' ...
    'Box' ...
    'XScale' 'YScale' 'ZScale' ...
    'XDir' 'YDir' 'ZDir' ...
    'XTickMode' 'YTickMode' 'ZTickMode' ...
    'XTick' 'YTick' 'ZTick' ...
    'XTickLabelMode' 'YTickLabelMode' 'ZTickLabelMode' ...
    'XTickLabel' 'YTickLabel' 'ZTickLabel' ...
    'FontName' 'FontSize' 'FontUnits' 'FontWeight'};

hAxes = this.Axes;

% Convert the list of properties to a structure with the values pulled from
% the stored axes handle.
axesProperties = cell2struct(get(hAxes, axesPropNames), axesPropNames, 2);

if strcmp(axesProperties.XTickMode, 'auto')
    axesProperties = rmfield(axesProperties, 'XTick');
end
if strcmp(axesProperties.YTickMode, 'auto')
    axesProperties = rmfield(axesProperties, 'YTick');
end
if strcmp(axesProperties.ZTickMode, 'auto')
    axesProperties = rmfield(axesProperties, 'ZTick');
end

if strcmp(axesProperties.XTickLabelMode, 'auto')
    axesProperties = rmfield(axesProperties, 'XTickLabel');
end
if strcmp(axesProperties.YTickLabelMode, 'auto')
    axesProperties = rmfield(axesProperties, 'YTickLabel');
end
if strcmp(axesProperties.ZTickLabelMode, 'auto')
    axesProperties = rmfield(axesProperties, 'ZTickLabel');
end

% Pull out the various labels from their Text objects.
axesProperties.Title  = get(get(hAxes, 'Title'),  'String');
axesProperties.XLabel = get(get(hAxes, 'XLabel'), 'String');
axesProperties.YLabel = get(get(hAxes, 'YLabel'), 'String');
axesProperties.ZLabel = get(get(hAxes, 'ZLabel'), 'String');

% Save the axes properties back into the object.
setPropValue(this, 'AxesProperties', axesProperties);


% [EOF]
