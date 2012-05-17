function runtimeData(this, hSLSignalData)
%RUNTIMEDATA handle simulink runtime

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/05/20 03:07:53 $

playbackObj = this.Controls;

% Process step-forward mode
% Note 1: always execute, even if snapshot is turned on
% Note 2: the "isa" check protects us from an empty Source that is "pulled
%         out from under us" if Scope is closed or Simulink Source is
%         disabled while connected and running with Simulink concurrently
%         the reason we check this one, and not the earlier access, is that
%         MATLAB can process code one when HG updates the image and the
%         only Source access after that point is here.
if isa(this, 'scopeextensions.SrcSL') && this.stepFwd  % singleStep
    % If stepFwd mode is enabled, pause simulation after showing the
    % current frame (if snapshot off)
    pause(playbackObj);
    
    % This is an expensive operation, but we're single-stepping,
    % and user-interaction takes a lot of time anyway:
    setPendingSimTimeReadout(this);
end

% If we have been flagged that we're in a bad state, turn off the flag and
% disconnect.  Check if we're in stepfwd mode and pause before
% disconnecting.
if strcmp(this.ErrorStatus, 'failure')
    
    disconnectState(this);
    return;
end

t = hSLSignalData.time;

if ~this.SnapshotMode
    this.TimeOfDisplayData = t;
end

if ~this.VisualNeedsBuffer
    this.RawData = {hSLSignalData.UserData};
    this.NewData = true;
    
    if this.UpdateRequested
        updateVisual(this);
    end

    return;
end

dataBuffer = this.DataBuffer;
this.NewData = false;
this.DataBuffer = [];

newData = [];
for indx = 1:numel(dataBuffer)
    
    endIndex = dataBuffer(indx).end+1;
    if endIndex > dataBuffer(indx).length
        endIndex = 1;
        dataBuffer(indx).isFull = true;
    end
    
    newData = hSLSignalData.UserData;
    
    % Handle VarSize
    if dataBuffer(indx).isVarSize
        newSize = size(newData);
        if ~isequal(newSize, dataBuffer(indx).maxDimensions)
            oldSize = dataBuffer(indx).maxDimensions;
            
            % Fill out any dimensions that are completely missing with 1.
            newSize = [newSize ones(1, numel(oldSize)-numel(newSize))]; %#ok<AGROW>
            
            % Pad the missing dimensions with NaNs.
            newData = slmgr.padArray(newData, NaN, oldSize);
        end
        dataBuffer(indx).dimensions(:, endIndex) = newSize;
    end
    
    % Convert the Nth Dimensional data into a single column and place it in
    % its time slot.  This allows us to support N-Dimensional signals more
    % easily.  The visuals will also receive this reshaped data.
    dataBuffer(indx).values(:, endIndex) = newData(:);
    dataBuffer(indx).time(endIndex)      = t;
    dataBuffer(indx).end                 = endIndex;
end

this.RawDataCache = {newData};

this.DataBuffer = dataBuffer;
this.NewData    = true;

if this.UpdateRequested
    updateVisual(this);
end



% [EOF]
