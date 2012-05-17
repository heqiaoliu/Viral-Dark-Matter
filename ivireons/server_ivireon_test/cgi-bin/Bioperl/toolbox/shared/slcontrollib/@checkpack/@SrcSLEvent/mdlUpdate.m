function mdlUpdate(this,hRTBlock)
%POSTNEWDATA(this,data) sets the new data to the source.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:10 $

if isempty(this.DataHandler)
    return
end

knownIds = {'MATLAB:noSuchMethodOrField', 'MATLAB:UndefinedFunction', ...
    'MATLAB:class:InvalidHandle', 'MATLAB:class:noPublicFieldForClass'};

try
    if this.stepFwd && strcmp(getSimState(this),'running')
        % Clear stepfwd flag before sending the command since we are already in stepfwd mode.
        this.stepFwd = false;
        sendSimulationCommand(this,'pause');
        forceTimeUpdate = true;
    else
        forceTimeUpdate = false;
    end
catch ME
    % this means the datasource pointer is an empty handle.
    % Return without erroring.
    if any(strcmp(ME.identifier, knownIds))
        
        % The object has now been deleted.  Return early, do not try to
        % fix the stepfwd flags.
        return;
    else
        % this is an unexpected error.
        throw(ME);
    end
end

% If the display is not frozen, update the source and visual with the new frame.
if ~this.SnapShotMode
    
    % Get the run-time object for the block so that we can
    % retrieve the data.
    if nargin < 2
        hRTBlock = this.RunTimeBlock;
    end
    data  = hRTBlock.InputPort(1).Data;
    n_dims = ndims(data);
    for i = 2:hRTBlock.NumInputPorts
        data = cat(n_dims+1,data,hRTBlock.InputPort(i).Data);
    end
    try
        % When we close the UI, the datasource gets deleted via the
        % CloseRequestFcn callback. We need to protect against hard erroring
        % in this case.
        playbackObj = this.Controls;
        % Update the source with the new data.
        this.Data.FrameData = data;
        
        %Update the Time display on the UI.
        playbackObj.TimeOfDisplayData = get(getParentModel(this),'SimulationTime');
        if rem(playbackObj.FrameCount, 10) == 0 || forceTimeUpdate
            playbackObj.StatusBar.findwidget({'StdOpts','Frame'}).Text = ...
                sprintf('T=%.3f',playbackObj.TimeOfDisplayData);
        end
        playbackObj.FrameCount = playbackObj.FrameCount+1;
        
        % Send the new data to the visual.
        newData(this);
    catch ME
        % this means the datasource pointer is an empty handle.
        % Return without erroring.
        if any(strcmp(ME.identifier, knownIds))
            
            % The object has now been deleted.  Return early, do not try to
            % fix the stepfwd flags.
            return;
        else
            % this is an unexpected error.
            throw(ME);
        end
    end
end

% [EOF]
