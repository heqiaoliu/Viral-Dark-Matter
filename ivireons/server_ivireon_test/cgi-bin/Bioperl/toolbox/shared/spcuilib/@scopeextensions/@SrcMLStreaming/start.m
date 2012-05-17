function start(this)
%START   Called when the source is first started.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:49 $

hSystemObject = this.SystemObject;

% Lock the specs and reset the frame count.
this.DataSpecsLocked = true;
this.FrameCount = 0;

% Get information about the inputs.
inputInfo = getInputInfo(hSystemObject);

this.SampleTimes = getInputSampleTime(hSystemObject);
this.DataTypes   = {inputInfo.dataType};

nSignals = numel(inputInfo);

dimensions = [1 1];

for indx = 1:nSignals
    dims = inputInfo(indx).size;
    if numel(dims) > size(dimensions, 2)
        dimensions = [dimensions ones(size(dimensions, 1), numel(dims) - size(dimensions, 2))];
    end
    
    dimensions(indx, :) = dims;
    
end

this.MaxDimensions = dimensions;

% preallocate the data buffer.
allocateDataBuffer(this, nSignals);

connectToDataSource(this.Application, this);

% Update the time status back to 0.
updateTimeStatus(this);

this.LastDrawnowTime = clock;

% [EOF]
