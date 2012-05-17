function onDataSourceChanged(this)
%ONDATASOURCECHANGED 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:41:15 $

% Clear the buffer any time the data source changes.
clearBuffer(this);

source = this.Application.DataSource;
if ~isempty(source) && ~isDataEmpty(source)
    
    % Set the new SamplesPerFrame value.  This will let us know the size of
    % the frame at any point without having to carry the data around.
    maxDims    = getMaxDimensions(source);
    sampleTime = getSampleTimes(source);
    frameSize = max(maxDims(:, 1));
    this.SamplesPerFrame = frameSize;
    this.DataSampleRate  = frameSize/max(sampleTime);
end

% Update the XAxis Limits based on the new frame size.
if ishghandle(this.Axes)
    updateXAxisLimits(this);
end

% [EOF]
