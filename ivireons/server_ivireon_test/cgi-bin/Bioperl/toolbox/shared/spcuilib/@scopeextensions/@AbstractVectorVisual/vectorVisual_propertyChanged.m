function vectorVisual_propertyChanged(this, propName)
%VECTORVISUAL_PROPERTYCHANGED React to changes in the properties.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/06 20:46:41 $

if ~ischar(propName)
    propName = propName.AffectedObject.Name;
end

switch lower(propName)
    
    case 'ylabel'
        this.YLabel = getPropValue(this, propName);
        if ishghandle(this.Axes)
            ylabel(this.Axes, this.YLabel);
        end
    otherwise
        lineVisual_propertyChanged(this, propName);
end

% [EOF]
