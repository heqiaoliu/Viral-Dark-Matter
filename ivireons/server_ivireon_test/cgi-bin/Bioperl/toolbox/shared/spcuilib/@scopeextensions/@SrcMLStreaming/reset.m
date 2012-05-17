function reset(this)
%RESET    Reset the states.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:03 $

this.NewData = false;

% Reset the data buffer back to no data.
resetDataBuffer(this);

% We need to reset the raw data to all zeros.
maxDims = getMaxDimensions(this);
nInputs = size(maxDims, 1);
rawData = this.RawData;
dataTypes = getDataTypes(this);
for indx = 1:nInputs
    rawData{indx} = zeros(maxDims(indx, :));
end
this.RawData = rawData;

this.FrameCount = 0;
this.NewData = true;

reset(this.Application.Visual);

% Update the visual to blank out the axes, image, lines, etc.
updateVisual(this);
updateTimeStatus(this);

postReset(this.Application.Visual);

% [EOF]
