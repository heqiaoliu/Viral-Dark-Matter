function setupDataBuffer(this)
%SETUPDATABUFFER Setup the DataBuffer

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:18 $

d = getSignalData(this.SLConnectMgr);

this.DataTypes = {d.dtype};
dimensions = d.dims;
if isscalar(dimensions)
    dimensions = [dimensions 1];
end
if d.numComponents ~= 1
    dimensions = [dimensions d.numComponents];
end

this.MaxDimensions = dimensions;

this.SampleTimes = d.period;

allocateDataBuffer(this, 1);

this.NewData = false;
dataBuffer = this.DataBuffer;
this.DataBuffer = [];
for indx = 1:numel(dataBuffer)
    dataBuffer(indx).isVarSize = ~strcmp(d.rto(1).OutputPort(1).DimensionsMode, 'Fixed');
end
this.DataBuffer = dataBuffer;

% Determine if we need to keep track of the buffer based on the visual.
hVisual = this.Application.Visual;
if isempty(hVisual)
    visualNeedsBuffer = true;
else
    visualNeedsBuffer = needsBuffer(hVisual);
end
this.VisualNeedsBuffer = visualNeedsBuffer;

% [EOF]
