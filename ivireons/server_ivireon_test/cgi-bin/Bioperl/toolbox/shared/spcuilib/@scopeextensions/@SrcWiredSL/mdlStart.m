function mdlStart(this, block)
%MDLSTART Called at model start time.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/05/20 03:07:54 $

% addcomments
this.IsStarting = true;

this.TimeOfDisplayData = 0;

setSnapShotMode(this, 'off');

% If we are passed the block, use it, otherwise get it from the source.
if nargin > 1
    this.RunTimeBlock = block;
else
    block = this.RunTimeBlock;
end

% Get the number of signals based on the number of input ports.
nSignals = block.NumInputPorts;

sampleTimes = zeros(1, nSignals);
dataTypes   = cell(1, nSignals);

allDims = [1 1];

for indx = 1:nSignals
    inputPort = block.InputPort(indx);
    
    iDims = inputPort.Dimensions;
    
    % If there is a dimension mismatch, pad the array before combining them
    if size(iDims, 2) > size(allDims, 2)
        allDims = slmgr.padArray(allDims, 1, [size(allDims, 1) size(iDims, 2)]);
    elseif size(iDims, 2) < size(allDims, 2)
        iDims = slmgr.padArray(iDims, 1, [1 size(allDims, 2)]);
    end
    allDims(indx, :) = iDims;
    
    portSampleTimes = inputPort.SampleTime;
    if isempty(portSampleTimes)
        % Get the block instead
        portSampleTimes = block.SampleTimes;
    end
    sampleTimes(indx) = portSampleTimes(1);
    dataTypes{indx} = inputPort.DataType;
end

this.MaxDimensions = allDims;

allocateDataBuffer(this, nSignals);

% Cache all of the port handles with the corresponding data buffer
% structure.  This will save time because we will not be getting it each
% mdlUpdate.
dataBuffer = this.DataBuffer;
this.DataBuffer = [];
for indx = 1:nSignals
    dataBuffer(indx).portHandle = block.InputPort(indx);
    dataBuffer(indx).isVarSize  = ~strcmp(block.InputPort(indx).DimensionsMode, 'Fixed');
end
this.DataBuffer  = dataBuffer;

if numel(unique(sampleTimes)) == 1
    isMultipleRates = false;
else
    isMultipleRates = true;
end

this.IsMultipleRates = isMultipleRates;
this.SampleTimes = sampleTimes;
this.DataTypes   = dataTypes;

% Cache the handle to the Time status widget so that we can use it faster
% during mdlUpdate.
this.TimeStatus = this.Controls.StatusBar.findwidget({'StdOpts','Frame'});

% If we are already installed, make sure we update here.
if isequal(this.Application.DataSource, this)
    installDataSource(this.Application);
end

hVisual = this.Application.Visual;
if isempty(hVisual)
    visualNeedsBuffer = true;
else
    visualNeedsBuffer = needsBuffer(hVisual);
end
this.VisualNeedsBuffer = visualNeedsBuffer;

this.IsStarting = false;

% [EOF]
