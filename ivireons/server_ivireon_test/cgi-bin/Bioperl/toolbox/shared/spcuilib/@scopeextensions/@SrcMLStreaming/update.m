function update(this, varargin)
%UPDATE   Respond to output events from the System Object.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:50 $

% If the display is not frozen, update the source and visual with the new frame.
% thisTime = clock;

dataBuffer = this.DataBuffer;
this.NewData = false;
this.DataBuffer = [];

this.FrameCount = this.FrameCount+1;

for portIndex = 1:numel(varargin)
    
    % Add multirate input support.

    % Calculate where into the circular buffer we should place the next
    % chunk of data.
    endIndex = dataBuffer(portIndex).end+1;
    if endIndex > dataBuffer(portIndex).length
        endIndex = 1;
        dataBuffer(portIndex).isFull = true;
    end
    
    newData = varargin{portIndex};
    
    % Handle VarSize, uncomment when variable sizing is supported.
%     newSize = size(newData);
%     if ~isequal(newSize, dataBuffer(portIndex).maxDimensions)
%         oldSize = dataBuffer(portIndex).maxDimensions;
%         
%         % Fill out any dimensions that are completely missing with 1.
%         newSize = [newSize ones(1, numel(oldSize)-numel(newSize))]; %#ok<AGROW>
%         
%         % Pad the missing dimensions with NaNs.
%         newData = padarray(newData, oldSize-newSize, NaN, 'post');
%     end
        
    % Convert the Nth Dimensional data into a single column and place it in
    % its time slot.  This allows us to support N-Dimensional signals more
    % easily.  The visuals will also receive this reshaped data.
    dataBuffer(portIndex).values(:, endIndex)     = double(newData(:));
    dataBuffer(portIndex).time(endIndex)          = getTimeOfDisplayData(this);
%     dataBuffer(portIndex).dimensions(:, endIndex) = newSize;
    dataBuffer(portIndex).end   = endIndex;
end

this.RawData = varargin;
this.DataBuffer = dataBuffer;
this.NewData = true;

if ~this.Controls.Snapshot
    
    updateVisual(this);
    
    % Update the time status every time step.  Once we have an asynchronous
    % update here, we can do this less often.
    updateTimeStatus(this);
end

lastTime = this.LastDrawnowTime;
thisTime = clock;

if etime(thisTime, lastTime) > .25
    
    % Do a full drawnow every quarter second to flush button and resize
    % events from the graphics queue.
    drawnow;
    
    % Reset the last drawnow time.
    this.LastDrawnowTime = thisTime;
end

% lastTime = this.ClockTimeOfLastUpdate;
% 
% if this.SynchronousUpdate
%     updateVisual(this);
%     updateTimeStatus(this);
%     if 1/(etime(thisTime, lastTime)) > (20*.25)
%         this.SynchronousUpdate = false;
%         hUpdater = uiscopes.VisualUpdater.Instance;
%         hUpdater.attach(this);
%     end
% else
%     if this.UpdateRequested
%         updateVisual(this);
%     end
% end
% 
% this.ClockTimeOfLastUpdate = thisTime;

% [EOF]

% LocalWords:  Ns
