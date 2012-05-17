function propertyChanged(this, propName)
%PROPERTYCHANGED Respond to property changes.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:29:37 $

if ~ischar(propName)
    propName = propName.AffectedObject.Name;
end

switch lower(propName)
    case 'displaybuffer'
        this.DisplayBuffer = getPropValue(this, 'DisplayBuffer');
        updateXAxisLimits(this);
        onResize(this);
    otherwise
        lineVisual_propertyChanged(this, propName);
end

% [EOF]
