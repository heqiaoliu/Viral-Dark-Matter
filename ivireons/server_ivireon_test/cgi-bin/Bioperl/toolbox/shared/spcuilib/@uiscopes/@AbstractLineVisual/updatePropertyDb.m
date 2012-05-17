function updatePropertyDb(this)
%UPDATEPROPERTYDB Update the LineProperties property.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:47:36 $

axesVisual_updatePropertyDb(this);

hLines = get(this, 'Lines');

% Get the default property structure.
defaultProps = uiscopes.AbstractLineVisual.getDefaultLineProperties;

% Pull out the field names so we know which properties we need to get.
linePropNames = fieldnames(defaultProps);

% Get the currently saved values from the object.
lineProperties = getPropValue(this, 'LineProperties');

if isempty(lineProperties)
    
    % Preallocate the structure.
    lineProperties = defaultProps;
end

for indx = 1:numel(hLines)
    
    % Build the line properties from the settings on the lines.
    lineProperties(indx) = cell2struct(get(hLines(indx), linePropNames), ...
        linePropNames, 2);
end

% Set the updated line properties back into the object.
setPropValue(this, 'LineProperties', lineProperties);

% [EOF]
