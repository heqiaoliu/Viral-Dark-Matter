function resetDataBuffer(this)
%RESETDATABUFFER 

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:47 $

dataBuffer = this.DataBuffer;
this.DataBuffer = [];

for indx = 1:numel(dataBuffer)
    dataBuffer(indx).values = NaN(size(dataBuffer(indx).values));
    dataBuffer(indx).time   = NaN(size(dataBuffer(indx).time));
    dataBuffer(indx).end    = 0;
    dataBuffer(indx).isFull = false;
end

this.DataBuffer = dataBuffer;

% [EOF]
