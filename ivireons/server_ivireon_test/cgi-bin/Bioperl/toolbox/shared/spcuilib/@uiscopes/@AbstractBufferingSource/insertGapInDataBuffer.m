function insertGapInDataBuffer(this, time)
%INSERTGAPINDATABUFFER Inserts a gap in the data buffer via a NaN value.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:45 $

% Set the newData to false so that we won't get visual updates here.
oldNewData = this.NewData;
this.NewData = false;
dataBuffer = this.DataBuffer;
this.DataBuffer = [];

% If the time is not passed in, get the current time.
if nargin > 1
    time = getTimeOfDisplayData(this);
end

% Loop over every signal and add a nan.
for indx = 1:numel(dataBuffer)
    
    % Increment the circular buffer.
    endIndex = dataBuffer(indx).end+1;
    if endIndex > dataBuffer(indx).length
        dataBuffer(indx).isFull = true;
        endIndex = 1;
    end
    
    % Add the nan.
    dataBuffer(indx).values(:, endIndex) = NaN(prod(dataBuffer(indx).maxDimensions), 1);
    dataBuffer(indx).time(endIndex)      = time;
    dataBuffer(indx).end                 = endIndex;
end

% Reset the state.
this.DataBuffer = dataBuffer;
this.NewData = oldNewData;

% [EOF]
