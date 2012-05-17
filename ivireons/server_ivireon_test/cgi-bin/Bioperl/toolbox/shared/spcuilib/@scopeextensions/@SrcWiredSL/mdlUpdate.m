function mdlUpdate(this, hRTBlock)
%mdlUpdate Default mdlUpdate method for the wired simulink source.
%   mdlUpdate(this, hRTBlock) sets the new data to the source.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.10 $  $Date: 2010/05/20 03:07:57 $

if this.StepFwd && isRunning(this)
    % Clear stepfwd flag before sending the command since we are already in stepfwd mode.
    this.StepFwd = false;
    sendSimulationCommand(this,'pause');
end

% If the display is not frozen, update the source and visual with the new frame.
t = hRTBlock.CurrentTime;

if ~this.SnapshotMode
    this.TimeOfDisplayData = t;
end

% If the visual doesn't need the buffer, check if we need to update and
% then return.
if ~this.VisualNeedsBuffer
    this.NewData = true;
    if this.UpdateRequested
        updateVisual(this);
    end
    return;
end

% Set NewData to false to avoid updates while DataBuffer is [].
this.NewData = false;

isMultipleRates = this.IsMultipleRates;

% Get the DataBuffer out of the object and then set the DataBuffer to [] so
% that we avoid copy on write issues.
dataBuffer = this.DataBuffer;
this.DataBuffer = [];

for indx = 1:numel(dataBuffer)
    
    % Add multirate input support.  XXX
    if isMultipleRates
        if ~dataBuffer(indx).portHandle.IsSampleHit
            continue;
        end
    end
    
    % Calculate where into the circular buffer we should place the next
    % chunk of data.
    endIndex = dataBuffer(indx).end+1;
    if endIndex > dataBuffer(indx).length
        endIndex = 1;
        dataBuffer(indx).isFull = true;
    end
    
    newData = dataBuffer(indx).portHandle.DataAsDouble;
    
    % Handle VarSize
    if dataBuffer(indx).isVarSize
        newSize = size(newData);
        if ~isequal(newSize, dataBuffer(indx).maxDimensions)
            newData = slmgr.padArray(newData, NaN, dataBuffer(indx).maxDimensions);
            newSize = slmgr.padArray(newSize, 1, [1 numel(dataBuffer(indx).maxDimensions)]);
        end
        dataBuffer(indx).dimensions(:, endIndex) = newSize(:);
    end
    
    % Convert the Nth Dimensional data into a single column and place it in
    % its time slot.  This allows us to support N-Dimensional signals more
    % easily.  The visuals will also receive this reshaped data.
    dataBuffer(indx).values(:, endIndex) = newData(:);
    dataBuffer(indx).time(endIndex)      = t;
    dataBuffer(indx).end                 = endIndex;
end

this.DataBuffer = dataBuffer;
this.NewData    = true;

if this.UpdateRequested
    updateVisual(this);
end

% [EOF]
