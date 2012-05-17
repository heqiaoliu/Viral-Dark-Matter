function propertyChanged(this, propName)
%PROPERTYCHANGED React to propertyDb changes.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/09/09 21:29:39 $

if ~ischar(propName)
    propName = propName.AffectedObject.Name;
end

switch lower(propName)
    case 'displaybuffer'
        lNewBuffer = getPropValue(this, propName);
        this.DisplayBuffer = lNewBuffer;
        updateXAxisLimits(this);
        onResize(this);
    case 'xlabel'
        this.XLabel = getPropValue(this, propName);
        if ishghandle(this.Axes)
            xlabel(this.Axes, this.XLabel);
        end
    case 'inheritsampleincrement'
        this.InheritSampleRate = getPropValue(this, 'InheritSampleIncrement');
        updateXData(this);
        updateXAxisLimits(this);
    case 'xoffset'
        this.XOffset = getPropValue(this, 'XOffset');
        updateXData(this);
        updateXAxisLimits(this);
    case 'incrementpersample'
        this.SampleTime = getPropValue(this, 'IncrementPerSample');
        updateXData(this);
        updateXAxisLimits(this);
    case {'framenumber', 'persistent'}
        % NO OP, these are not implemented.
    otherwise
        vectorVisual_propertyChanged(this, propName);
end

% [EOF]
