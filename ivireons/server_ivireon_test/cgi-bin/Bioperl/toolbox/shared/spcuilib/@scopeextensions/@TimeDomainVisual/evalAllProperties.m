function evalAllProperties(this)
%EVALALLPROPERTIES Evaluate all of the evaluatable properties.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:42:58 $

if strcmp(this.getPropValue('InputProcessing'), 'FrameProcessing')
    
    if strcmp(this.getPropValue('TimeRangeFrames'), 'Spcuilib:scopes:TimeRangeInputSampleTime')
        this.TimeRange = max(this.SampleTimes);
    else
        evalProperty(this, 'TimeRangeFrames', 'TimeRange')
    end
else
    % Reapply the time range and time display offset
    evalProperty(this, 'TimeRangeSamples', 'TimeRange')
end

evalProperty(this, 'TimeDisplayOffset');

% Apply the YAxis limits
updateYAxisLimits(this);

% [EOF]
