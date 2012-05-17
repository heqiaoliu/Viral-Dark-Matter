function propertyChanged(this, propName)
%PROPERTYCHANGED Respond to property changes.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/31 18:41:20 $

if ~ischar(propName)
    propName = propName.AffectedObject.Name;
end

switch lower(propName)
    case 'normalizedfrequencyunits'
        
        isNorm = getPropValue(this, 'NormalizedFrequencyUnits');
        if isNorm
            units = 'rad/sec';
        else
            units = '<units>Hz';
        end
        this.XLabel = sprintf('Frequency (%s)', units);
        this.IsNormalized = isNorm;
        if ishghandle(this.Axes)
            xlabel(this.Axes, this.XLabel);
            updateXData(this);
            updateXAxisLimits(this);
        end
        
    case 'frequencyrange'
        
        % Setup the RangeIndex and Transform functions for later use.
        setupRange(this);
        
        % Kick off an update against the latest data to update the lines.
        update(this);
        
        % Update the XLims if we are in auto display.
        updateXAxisLimits(this);
    case 'inheritsampletime'
        this.InheritSampleRate = getPropValue(this, 'InheritSampleTime');
        updateXData(this);
        updateXAxisLimits(this);
    case 'sampletime'
        this.SampleTime = getPropValue(this, 'SampleTime');
        if ~this.InheritSampleRate
            updateXData(this);
            updateXAxisLimits(this);
        end
    case 'yaxisscaling'
        if strcmp(this.getPropValue('YAxisScaling'), 'dB')
            this.YScalingFcn = @(in) 10./log(10) .* log(abs(double(in))+eps(double(in)));
        else
            this.YScalingFcn = [];
        end
        if ~isempty(this.Application.DataSource)
            update(this);
        end
    otherwise
        lineVisual_propertyChanged(this, propName);
end

% [EOF]
