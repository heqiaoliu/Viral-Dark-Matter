function allocateDataBuffer(this, nSignals)
%ALLOCATEDATABUFFER Preallocate the data buffer.
%   allocateDataBuffer(this, dimensions)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:38 $

maxPoints = getPropValue(this, 'PointsPerSignal');

% values - stores the values of the buffer
% time - stores the time stamp corresponding to the values
% dimensions - stores the raw dimensions corresponding to the values
% length - stores the maximum length of the data buffer.
% maxDimensions - stores the maximum expected dimensions of any data
% isFull - stores if the buffer is full and has started to wrap around
% end - stores the end index for the last added data
% sampleTime - stores the sample time of the data.
dataBuffer = repmat(struct( ...
    'values', {[]}, ...
    'time', [], ...
    'length', 0, ...
    'maxDimensions', [], ...
    'isFull', false, ...
    'end', 0, ...
    'dimensions', []), 1, nSignals);

for portIndex = 1:nSignals
    
    maxDims = getMaxDimensions(this, portIndex);
    
    % Calculate the length of the buffer based on the size of the input.
    channelSize = prod(maxDims);
    maxLength   = ceil(maxPoints/channelSize);
    
    dataBuffer(portIndex).maxDimensions = maxDims;
    dataBuffer(portIndex).length        = maxLength;
    dataBuffer(portIndex).dimensions    = repmat(maxDims(:), 1, maxLength);
    dataBuffer(portIndex).values        = NaN(channelSize, maxLength);
    dataBuffer(portIndex).time          = NaN(1, maxLength);
end

this.DataBuffer = dataBuffer;

% [EOF]
